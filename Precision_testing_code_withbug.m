% Create a set of calibration images.
path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.5_folder_precision_calibration_images';
images = imageDatastore(path);
imageFileNames = images.Files;
% Detect calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
% Generate world coordinates of the corners of the squares.
squareSize = 30; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% Calibrate the camera.
I = readimage(images, 1); 
imageSize = [size(I, 1), size(I, 2)];
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, ...
    worldPoints, 'ImageSize', imageSize);
%undistort the images 
Path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.5_folder_precision_images';
S=dir(fullfile(Path,'*.jpg'));
for k=1:numel(S)
    F=fullfile(Path,S(k).name);
    I=imread(F);
    J= undistortImage(I,cameraParams);    
    imwrite(J,['C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.5_folder_precision_undistorted\',int2str(k),'.jpg']);
end
%get the world coordinates of the test
D='C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.5_folder_precision_undistorted';
S=dir(fullfile(D,'*.jpg'));
A = imread('矫正第二张.jpg');
R=A(:,:,3);
xWorldLimits = [0 500];
yWorldLimits = [0 500];
RA = imref2d(size(R),xWorldLimits,yWorldLimits);
%detect the checkerboard 
path ='C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.5_folder_precision_undistorted';
images = imageDatastore(path);
imageFileNames = images.Files;
[imagePoints, boardSize,imagesUsed] = detectCheckerboardPoints(imageFileNames);
%plot checkboard detected and show detected points 
imageFileNames = imageFileNames(imagesUsed);
for i = 1:numel(imageFileNames)
  I = imread(imageFileNames{i});
  subplot(2, 2, i);
  imshow(I);
  hold on;
  plot(imagePoints(:,1,i),imagePoints(:,2,i),'ro');
end
%transfer pixels to world coordinate, do it trip times
xIntrinsic = imagePoints(1,1,1);
yIntrinsic = imagePoints(1,2,1);
[xWorld1,yWorld1] = intrinsicToWorld(RA,xIntrinsic,yIntrinsic);
%second position
xIntrinsic = imagePoints(1,1,2);
yIntrinsic = imagePoints(1,2,2);
[xWorld2,yWorld2] = intrinsicToWorld(RA,xIntrinsic,yIntrinsic);
%third position
xIntrinsic = imagePoints(1,1,3);
yIntrinsic = imagePoints(1,2,3);
[xWorld3,yWorld3] = intrinsicToWorld(RA,xIntrinsic,yIntrinsic);
%test transferation of difference of pixel to world 
xIntrinsic = 3.6063;
yIntrinsic = 0.175;
[xWorld4,yWorld4] = intrinsicToWorld(RA,xIntrinsic,yIntrinsic);
%draw the conclusion
differenceA=yWorld2-yWorld1
differenceB=yWorld3-yWorld2