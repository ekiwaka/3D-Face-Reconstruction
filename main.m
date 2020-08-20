%% The main function for IPCV project 3

%3D Face Reconstruction
%Karan Rawat
%s1748211
%M-EMSYS

%% Initialize the project directory

[PROJ_DIR, mname, mext] = fileparts(mfilename('fullpath'));
PROJ_DIR = [PROJ_DIR, '/'];
cd(PROJ_DIR);

addpath(genpath(PROJ_DIR));

%% Start by camera calibration

    % Define subject and calibration paths
    SUBJ = 'subject1';      % Possibilities 1,2,4
    CALIB= 'Calibratie 2/'; % Possibilities 1,2
    IMG  = '_2';            % Possibilties 1,2,365,729,1093,1457

    % Load stereo calibration 
load([PROJ_DIR, CALIB, 'sP_MR.mat'])
load([PROJ_DIR, CALIB, 'sP_ML.mat'])
load([PROJ_DIR, CALIB, 'sP_LR.mat'])

    % Load face images
im_L = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Left/',   SUBJ, '_Left',  IMG,'.jpg']);
im_M = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Middle/', SUBJ, '_Middle',IMG,'.jpg']);
im_R = imread([PROJ_DIR, SUBJ, '/', SUBJ, 'Right/',  SUBJ, '_Right', IMG,'.jpg']);

    % Show the original images
figure(1); clf
    subplot(1,3,1);
        imshow(im_L)
    subplot(1,3,2);
        imshow(im_M)
        title('Original images')
    subplot(1,3,3);
        imshow(im_R)

        
%% Remove background in im_*_noBG and store the mask to mask_*
%   (in mask_* BG pixels are 0 and face 1)

    % Select good settings for the subject
switch SUBJ(end);
    case '1'
        edgeThresh  = 0.1;
        strelVal    = 2;
    case '2'
        edgeThresh  = 0.05;
        strelVal    = 4;
    case '4'
        edgeThresh  = 0.03;
        strelVal    = 5;
end
    
    % Remove the backgrounds from each image
plotFlag = false;
[im_L_noBG, mask_L] = removeBackground(im_L, edgeThresh, strelVal, plotFlag);
[im_M_noBG, mask_M] = removeBackground(im_M, edgeThresh, strelVal, plotFlag);
[im_R_noBG, mask_R] = removeBackground(im_R, edgeThresh, strelVal, plotFlag);

    % Show the result
figure; 
    imshow(im_L_noBG);
figure; 
    imshow(im_M_noBG);
figure; 
    imshow(im_R_noBG);
    
    
%% Normalize image intesities to correspond middle image

im_L_norm = normalizeImages(im_L, im_M);
im_R_norm = normalizeImages(im_R, im_M);

    
%% Rectify

    % How'd you like the recitification viewed?
OutpView = 'full';

    % Rectify the images
[im_Mr_rec, im_R_rec] = rectifyStereoImages(im_M, im_R_norm, sP_MR,...
                            'OutputView',OutpView);
[im_Ml_rec, im_L_rec] = rectifyStereoImages(im_M, im_L_norm, sP_ML,...
                            'OutputView',OutpView);

	% Do the same for masks
[mask_Mr_rec, mask_R_rec] = rectifyStereoImages(mask_M, mask_R, sP_MR,...
                            'OutputView',OutpView);
[mask_Ml_rec, mask_L_rec] = rectifyStereoImages(mask_M, mask_L, sP_ML,...
                            'OutputView',OutpView);

	% Apply the masks to see everything's fine
masked_Mr_rec = im_Mr_rec .* uint8(repmat(mask_Mr_rec,[1,1,3]));
masked_R_rec  = im_R_rec  .* uint8(repmat(mask_R_rec,[1,1,3]));
                        
masked_Ml_rec = im_Ml_rec .* uint8(repmat(mask_Ml_rec,[1,1,3]));
masked_L_rec  = im_L_rec  .* uint8(repmat(mask_L_rec,[1,1,3]));

    % And visualise
figure;
    CreateAxes(3,1,1);
        imshow(stereoAnaglyph(masked_Mr_rec, masked_R_rec));
	CreateAxes(3,1,2);
        imshow(stereoAnaglyph(masked_Ml_rec, masked_L_rec));

        
%% Disparity

    % Choose from predetermined disparity range
    %   These don't really matter, but I'm afraid to touch
 switch SUBJ(end);
    case '1'
        dispar_values_R = [ 230,  350];
        dispar_values_L = [-550, -200];
    case '2'
        dispar_values_R = [ 230,  380];
        dispar_values_L = [-580, -300];
    case '4'
        dispar_values_R = [ 150,  600];
        dispar_values_L = [-560, -150];
 end

    % Calculate the disparities
	%   There's some stupid flipping and multiplying, because the disparity
	%   seems to operate on black magick.
disparmap_R = mapDisparity(im_R_rec, im_Mr_rec, flip(dispar_values_R).*-1) .* -1;
disparmap_L = mapDisparity(im_Ml_rec, im_L_rec, dispar_values_L).*-1;

    % And visualise
figure;
    imshow(disparmap_R)
figure;
    imshow(disparmap_L)

%% Erode the masks to cut a bit of the image border

er_fact = 30;

mask_Mr_eroded = imerode(mask_Mr_rec, strel('diamond', er_fact));
mask_R_eroded = imerode(mask_R_rec  , strel('diamond', er_fact));
mask_Ml_eroded = imerode(mask_Ml_rec, strel('diamond', er_fact));
    
%% Fill Gaps with relaxation
%   This part is for writing the report images later on
gv = -1;

disparmap = disparmap_R.*mask_Mr_rec;
disparmap(isnan(disparmap)) = 0;
disparmap(mask_Mr_rec==1 & disparmap==0) = gv;
disparmap_f = relaxgaps(disparmap,gv,1,300,0.001,0);
disparmap_R(isnan(disparmap_R)) = 0;
disparmap_L(isnan(disparmap_L)) = 0;

disparmap_R(mask_R_rec==1  & disparmap_R==0) = -1;
disparmap_L(mask_Ml_rec==1 & disparmap_L==0) = -1;

disparmap_fR = relaxgaps(disparmap_R ,gv,1,300,0.001,0);
disparmap_fL = relaxgaps(disparmap_L ,gv,1,300,0.001,0);

figure; imshow(disparmap_fR,[])
figure; imshow(disparmap_fL,[])


%% Laplacian filter plus new relaxation

    % This part again for later images
threshold = 1;
[disparmap_fl,lapfilt] = laplacianFilter(disparmap_f,threshold,gv);
figure; imshow(disparmap_fl,[]); title('Laplacian filtered')
[disparmap_flf,its] = relaxgaps(disparmap_fl,gv,1,400,0.001,0);

figure; imshow(disparmap_flf,[]); title('Relaxed Laplacian filtered')

    % And these for pointCloud computations
disparmap_fR_lap = laplacianFilter(disparmap_fR, threshold, gv);
figure; imshow(disparmap_fR_lap,[]); title('Laplacian filtered')
disparmap_fR_2 = relaxgaps(disparmap_fR_lap,gv,1,300,0.001,0);
figure; imshow(disparmap_fR_2,[]); title('Relaxed Laplacian filtered')

    % Above for Right, below for Left
disparmap_fL_lap = laplacianFilter(disparmap_fL, threshold, gv);
figure; imshow(disparmap_fL_lap,[]); title('Laplacian filtered')
disparmap_fL_2 = relaxgaps(disparmap_fL_lap, gv,1,300,0.001,0);
figure; imshow(disparmap_fL_2,[]); title('Relaxed Laplacian filtered')


%% Plot Face Mesh
ptCloud_R = facemesh(disparmap_fR_2.*mask_R_eroded, im_R_rec );
ptCloud_L = facemesh(disparmap_fL_2.*mask_Ml_eroded, im_Ml_rec);


%% Write Report Images
writeReportImages = true;

if writeReportImages
    % Crop parameters
    x = 800;
    y = 100;
    w = 600;
    h = 700;
    
    % Crop images and adjust range for export
    disparitygaps_c = mat2gray(imcrop(disparmap,    [x y w h]));
    disparityfill_c = mat2gray(imcrop(disparmap_f,  [x y w h]));
    disparitylapf_c = mat2gray(imcrop(lapfilt,      [x y w h]));
    disparityflf_c  = mat2gray(imcrop(disparmap_flf,[x y w h]));
    
    % Write images
    imwrite(disparitygaps_c,'./out/disparity-gaps.png')
    imwrite(disparityfill_c,'./out/disparity-fill.png')
    imwrite(disparitylapf_c,'./out/disparity-lapf.png')
    imwrite(disparityflf_c, './out/disparity-flf.png')
end

%% Point cloud figure creation
ptCloud_R_ds = pcdownsample(ptCloud_R, 'random',.2);
ptCloud_L_ds = pcdownsample(ptCloud_L, 'random',.2);

    % Read the location
pts_R.Location = ptCloud_R_ds.Location;
pts_L.Location = ptCloud_L_ds.Location;

    % And colour info
pts_R.Color    = ptCloud_R_ds.Color;
pts_L.Color    = ptCloud_L_ds.Color;

    % Weed out parts very close and far
include_R      = pts_R.Location(:,3) > 1000 & pts_R.Location(:,3) < 1400; 
include_L      = pts_L.Location(:,3) > 1000 & pts_L.Location(:,3) < 1400;

    % Reconstruct the pointCloude 
ptCloud_R_include = pointCloud(pts_R.Location(include_R,:),...
                        'Color',pts_R.Color(include_R,:));
ptCloud_L_include = pointCloud(pts_L.Location(include_L,:),...
                        'Color',pts_L.Color(include_L,:));

	% Try to align the two meshes 
    %   Spoiler alert: doesn't work
[tform,movingReg] = pcregrigid(ptCloud_L_include, ptCloud_R_include, 'Extrapolate', true);


%% And visualize the outcome, once more
figure; 
    CreateAxes(2,2,1); axis off
pcshow(ptCloud_R_include);
    CreateAxes(2,2,2); axis off
pcshow(ptCloud_L_include);
    CreateAxes(2,2,3); axis off
pcshow(ptCloud_L); hold on;
pcshow(ptCloud_R)
    CreateAxes(2,2,4); axis off
pcshow(ptCloud_R_include); hold on;
pcshow(  movingReg );
