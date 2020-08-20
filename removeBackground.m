function [im_noBG, mask] = removeBackground(im, edgeThresh, strelVal, plotFlag)
%% function [im_BG] = removeBackground(im, thresh, strel)
%   Removes the background of an image and returns that plus a binary mask
%   of foreground.
%   Converts the image to grayscale, performs Canny edge detection,
%   morphological closing and image filling.
%   INPUT:
%       im          - The colour image to be masked
%       edgeThresh  - Thesholding value for Canny edge detection (0<x<1)
%       strelVal    - Strel thickness for closing
%       plotFlag    - Binary flag for plotting
%   OUTPUT:
%       im_noBG     - Colour image where background pixels are 0
%       mask        - Binary mask where foreground pixels are 1
   

    % Convert to grayscale
im_g = rgb2gray(im);

    % Detect edges
edge = ut_edge(im_g, 't', edgeThresh);
    % Close the image morphologically
edge_closed = imclose(edge, strel('sphere',strelVal));
    % Fill the image by symmetric padding
bw_filled   = imfill(padarray(edge_closed,size(edge_closed),'symmetric'),'holes');
mask = bw_filled(   size(edge_closed,1)+(1:size(edge_closed,1)),...
                    size(edge_closed,2)+(1:size(edge_closed,2)) );
                
    % FAILSAFE: Padarray can fail in case the subject fills the image to
    % edges
if sum(mask(:)) > 4/5 * numel(mask)
    bw_filled   = imfill(edge_closed, 'holes');
    mask = bw_filled;
end
    % Extract the BG mask from filled image


	%% Search for the largest connected component in the mask (Supposed to
	% be the person)
CC = bwconncomp(mask);

if CC.NumObjects > 1;
    [biggest,idx] = max( cellfun(@numel,CC.PixelIdxList) );
    for i = 1:CC.NumObjects;
        if i ~= idx;
            mask(CC.PixelIdxList{i}) = 0;
        end
    end
end

    % Remove the background from the image by masking
im_noBG = im(:,:,:) .* repmat(uint8(mask), [1,1,3]);

    %% Plot if plotFlag allows
if plotFlag
    txt_pos = [60,60];
    figure('Position',[472 108 689 632]) ;
	CreateAxes(2,2,1, 0.1,[0,0],[0,0]);
        imshow(im_g);
        text(txt_pos(1), txt_pos(2), '(a)',...
            'Color', 'w', 'Fontsize', 16);
    CreateAxes(2,2,2, 0.1,[0,0],[0,0]);
        imshow(edge);
        text(txt_pos(1), txt_pos(2), '(b)',...
            'Color', 'w', 'Fontsize', 16);
	CreateAxes(2,2,3, 0.1,[0,0],[0,0]);
        imshow(edge_closed);
        text(txt_pos(1), txt_pos(2), '(c)',...
            'Color', 'w', 'Fontsize', 16);
    CreateAxes(2,2,4, 0.1,[0,0],[0,0]);
        imshow(mask);
        text(txt_pos(1), txt_pos(2), '(d)',...
            'Color', 'w', 'Fontsize', 16);
end


end