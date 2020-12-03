%获取相机
webcamlist
cam = webcam;
preview(cam);
img = snapshot(cam);
imshow(img);
closePreview(cam);
%矫正图片
% Create a set of calibration images.
path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\距离对精度影响检测\No.8_camera_precision';
images = imageDatastore(path);
imageFileNames = images.Files;
% Detect calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
% Generate world coordinates of the corners of the squares.
squareSize = 31; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% Calibrate the camera.
I = readimage(images, 1); 
imageSize = [size(I, 1), size(I, 2)];
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, ...
    worldPoints, 'ImageSize', imageSize);
%undistort the images 
Path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\距离对精度影响检测\No.8_rare_images';
S=dir(fullfile(Path,'*.jpg'));
for k=1:numel(S)
    F=fullfile(Path,S(k).name);
    I=imread(F);
    J= undistortImage(I,cameraParams);    
    imwrite(J,['C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\距离对精度影响检测\No.8_undistorted_images\',int2str(k),'.jpg']);
end
% %相机矫正的代码，用来提供cameraParams数据
% path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\距离对精度影响检测\No.7_camera_precision';
% images = imageDatastore(path);
% imageFileNames = images.Files;
% % Detect calibration pattern.
% [imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
% % Generate world coordinates of the corners of the squares.
% squareSize = 31; % millimeters
% worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% % Calibrate the camera.
% I = readimage(images, 1); 
% imageSize = [size(I, 1), size(I, 2)];
% [cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, ...
%     worldPoints, 'ImageSize', imageSize);

%计算in/ex参数
path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\距离对精度影响检测\No.7_undistorted_images';
images = imageDatastore(path);
imageFileNames = images.Files;
imagePoints = detectCheckerboardPoints(imageFileNames);
intrinsics = cameraParams.Intrinsics;
[R,t] = extrinsics(imagePoints(:,:,1),worldPoints,intrinsics);
%直接转换pixels into 世界坐标系
imagePoints1=imagePoints(:,:,1);
newWorldPoints1 = pointsToWorld(intrinsics,R,t,imagePoints1);
imagePoints2=imagePoints(:,:,2);
newWorldPoints2 = pointsToWorld(intrinsics,R,t,imagePoints2);
imagePoints3=imagePoints(:,:,3);
newWorldPoints3 = pointsToWorld(intrinsics,R,t,imagePoints3);
%保存数据并计算平均值
fid1=fopen('Displacement1.txt','w');
fid2=fopen('Displacement2.txt','w');
for i = 1:88
  differenceA=newWorldPoints2(i,2)-newWorldPoints1(i,2);
  differenceB=newWorldPoints3(i,2)-newWorldPoints2(i,2);
  fprintf(fid1,'%f %f\n',differenceA);
  fprintf(fid2,'%f %f\n',differenceB);
end
 fclose('all');
 D1=load('Displacement1.txt');
 D2=load('Displacement2.txt');
 D1=mean(D1)
 D2=mean(D2)
 D1-38
 D2-38