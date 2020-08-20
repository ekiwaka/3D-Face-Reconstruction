function [dfilt,glapl] = laplacianFilter(dmap,threshold,gv)
% === Laplacian Filter for disparity maps ===
% Computes a gaussian blurred absolute laplacian.
% Replaces values that are above given threshold.
% (Disparity map is normalized beforehand.)
%
% Input arguments:
%  - dmap:      Disparity map to be filtered.
%  - threshold: Threshold value. Values above this
%               value are replaced.
%  - gv:        Gap value. Values above threshold
%               are replaced by this value.
%
% Output:
%  - dfilt:     Filtered disparity map.
%  - glapl:     Laplacian filtering image.

% Settings
s = 7;
sigma = 1.8;
visualise = true;

% Calculate discrete laplacian of normalized disparity map
ndisparmap = dmap / mean(dmap(:));    % normalize with average
lapl = del2(dmap);

% Construct and apply gaussian filter
fgauss = fspecial('gauss',[s s],sigma);
glapl = imfilter(abs(lapl),fgauss);

% 
dfilt = dmap;
dfilt(glapl>threshold) = gv;

if visualise
    figure; imshow(glapl,[])
    title('Absolute Laplacian gaussian filtered')
end
