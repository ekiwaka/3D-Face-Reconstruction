function ptCloud = facemesh(disparmap,rgbmap)

[W,H] = size(disparmap);
[X,Y] = meshgrid(1:H,1:W);

% Gathering point data
xyzPoints = [X(disparmap > 0) Y(disparmap > 0) 4*disparmap(disparmap > 0)];
rmap = rgbmap(:,:,1);
gmap = rgbmap(:,:,2);
bmap = rgbmap(:,:,3);
rgbPoints = [rmap(disparmap > 0) gmap(disparmap > 0) bmap(disparmap > 0)];

% Construct point cloud
figure
ptCloud = pointCloud(xyzPoints,'Color',rgbPoints);
pcshow(ptCloud);
camproj('perspective')

end