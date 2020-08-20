function createReportFigs(ptCloud, saveFName)
%% function createReportFigs(disparmap, colourdata)
%   Creates a set of images to be used in the report.
% INPUT:
%   -ptCloud    - PointCloud class object drawing the face
%   -saveFName  - If the result is to be saved, define a name

% Create plots from different angles
figure('Position', [530 320 640 396]);
    CreateAxes(2,3,1,-0.1);
pcshow(ptCloud);
camproj('perspective')
view(150,55);
axis off;
    CreateAxes(2,3,2);
pcshow(ptCloud);
camproj('perspective')
view(180,70);
axis off;
    CreateAxes(2,3,3,-0.1);
pcshow(ptCloud);
camproj('perspective')
view(-150,55);
axis off;

    CreateAxes(2,2,3,0);
pcshow(ptCloud);
camproj('perspective')
view(-88,10);
axis off;
    CreateAxes(2,2,4,-0.2,[0,0],[0.1,0.1]);
pcshow(ptCloud);
camproj('perspective')
view(88,35);
axis off;



%% Save?

if nargin==2 
        fprintf('\nSaving the figure to current dir\n')
        SaveCurrentFig(1, 1, '.', saveFName,'-dpng');
end








end