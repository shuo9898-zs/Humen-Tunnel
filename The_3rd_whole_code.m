clear ; close all; clc;

% Create a set of calibration images.
path = 'C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\相机矫正目录';
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
% figure; 
% showExtrinsics(cameraParams, 'CameraCentric');
% figure; 
% showExtrinsics(cameraParams, 'PatternCentric');
% displayErrors(estimationErrors, cameraParams);
%Remove lens distortion and display results-2
Path='C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.3_folder-training';
S=dir(fullfile(Path,'*.jpg'));
for k=1:numel(S)
    F=fullfile(Path,S(k).name);
    I=imread(F);
    J= undistortImage(I,cameraParams);    
    imwrite(J,['C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.4_folder-training\',int2str(k),'.jpg']);
end
%start image processing
D='C:\Users\张硕\Documents\MATLAB\Examples\R2020a\images\No.4_folder-training';
S=dir(fullfile(D,'*.jpg'));
A = imread('矫正第二张.jpg');
R=A(:,:,3);
xWorldLimits = [0 500];
yWorldLimits = [0 500];
RA = imref2d(size(R),xWorldLimits,yWorldLimits);
for k=1:numel(S)
    F=fullfile(D,S(k).name);
    I=imread(F);
    rgb=I;
    g=rgb(:,:,2);
    r=rgb(:,:,1);
    % binize the image
    bw=im2bw(r);
    bw=~bw;
    bw=bwareaopen(bw,60);
    % find out centers
    stats=regionprops(bw);
    stats=regionprops(bw,'all');
    [centers,radii]=imfindcircles(bw,[6 20]);
    xIntrinsic = centers(1,1);
    yIntrinsic = centers(1,2);
    [xWorld,yWorld] = intrinsicToWorld(RA,xIntrinsic,yIntrinsic);
    centers=[xWorld,yWorld];
    display(centers);
    %output as txt form
     textname=[datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'),'.txt'];
     fid=fopen(textname,'w');
     fprintf(fid,'%f %f\n',[xWorld,yWorld]); 
     fclose(fid);
     save(['C:\Users\张硕\Documents\MATLAB\transfor station test\' textname]);
end
%order text files and plot them in figure
Path = 'C:\Users\张硕\Documents\MATLAB\transfor station test'; 
listing = dir(fullfile(Path,'*.txt'));
B={listing.name};
B = sort( B); 
figure(2);
hold on
for i=1:numel(B)
    filename=B{1,i};
    fileID = fopen(filename);
    C = textscan(fileID,'%f %f');
    fclose(fileID);
    display(C);
    x=i;
    x1=10*i
    y1=C{1,1};
    y2=C{1,2};
    subplot(2,1,1);
    plot(x,y1,'*r');
    hold on
    subplot(2,1,2);
    plot(x1,y2,'*r');
    hold on
end
xlim([0, 500]);
ylim([0,500]);
axis equal
hold off