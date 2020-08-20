function disparmap = mapDisparity(im1, im2, dispar_values)
% Calculate the disparity map between two RGB images
% Disparity is calculated for each color separately
visualise = true;

% Calculate disparity map for each color separately
for rgb = 1:3                               % Loop over RGB index (1, 2 or 3)
    img1 = im1(:,:,rgb);
    img2 = im2(:,:,rgb);

    % Calculate disparity map
    disparRange = [-640 480];
    disparmap_rgb(:,:,rgb) = disparity(img1, img2,...
        'BlockSize', 5, 'DisparityRange', disparRange);
    
    % Assume: face values are in predefined range
    disparmap_rgb(disparmap_rgb<dispar_values(1) | disparmap_rgb>dispar_values(2)) = 0;       % remove other stuff
end

%% Combine color channels into one image: mean of nonzero values
zeromap    = sum(disparmap_rgb == 0, 3);
summap     = sum(disparmap_rgb, 3);
disparmap    = summap./(3 - zeromap);

% Visualisation
if visualise
    figure
    
    % Show disparity map RGB
    subplot(2,2,1)
    imshow((disparmap_rgb-200)/200);
    title('Disparity map - RGB');
    
    % Show histogram
    subplot(2,2,2)
    histvals = disparmap_rgb(:);
    histvals(histvals == 0) = NaN;
    hist(histvals,40)
    title('Disparity Histogram')
    
    % Show disparity map
    subplot(2,2,3)
    imshow(zeromap,[1 3]);
    title('Disparity map - Zeromap');
    
    % Show disparity map
    subplot(2,2,4)
    imshow(disparmap,[]);
    title('Mean Disparity map');
    
    % Show disparity map RGB
    figure;
    imshow(disparmap_rgb./max(disparmap(:)));
    title('Disparity map - RGB');
end



