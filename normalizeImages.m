function [im_out] = normalizeImages(im_norm, im_ref)
%% function normalizeImages(im_norm, im_ref)
%   Normalises the mean and variance of im_norm to correspond those of
%   im_ref.
%   INPUT:  Two colour images im_norm and im_ref
%   OUTPUT: im_out; im_norm with normalised mean and var


%% Break the image to each colour component

im_norm_rgb = { im_norm(:,:,1),...
            im_norm(:,:,2),...
            im_norm(:,:,3) };

im_ref_rgb = { im_ref(:,:,1),...
            im_ref(:,:,2),...
            im_ref(:,:,3) };

        
% figure; 
%     subplot(2,1,1);
%     imhist(im_norm_rgb{1})
%     subplot(2,1,2);
%     imhist(im_ref_rgb{1})
% figure; 
%     subplot(2,1,1);
%     imhist(im_norm_rgb{2})
%     subplot(2,1,2);
%     imhist(im_ref_rgb{2})
% figure; 
%     subplot(2,1,1);
%     imhist(im_norm_rgb{3})
%     subplot(2,1,2);
%     imhist(im_ref_rgb{3})


%% Normalize

for i = 1:3;
        % The variance
    ref_var = std( double( im_ref_rgb{i}(:)  ) );
    norm_var= std( double( im_norm_rgb{i}(:) ) );
    
    im_norm_rgb{i} = im_norm_rgb{i} .* (ref_var/norm_var);
    
        % The mean
    ref_mean = mean(im_ref_rgb{i}(:));
    im_norm_rgb{i} = im_norm_rgb{i} - (mean(im_norm_rgb{i}(:)) - ref_mean);

end

im_out = cat(3, im_norm_rgb{1}, im_norm_rgb{2}, im_norm_rgb{3});

end