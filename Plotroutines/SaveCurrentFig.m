function SaveCurrentFig(saveflag,scale,directory,filename,format)
% function SaveCurrentFig(saveflag,scale,directory,filename,format)
% 	format: '-dpng' or something like that...
%
% v160923 Matti Stenroos

if ~saveflag
    return;
end
pos=get(gcf,'position');
if nargin==1 ||isempty(scale)
    scale=1;
end
pos=scale*pos(3:4);
set(gcf,'paperunits','points','papersize',pos,'paperposition',[0 0 pos]);
if nargin<4 || isempty(filename)
    filename=get(gcf,'name');
end
if nargin<3 || isempty(directory)
    directory='./';
end
savepath=fullfile(directory,filename);

mkdir(fileparts(savepath));
if nargin<5 ||isempty(format)
    format='-dpng';
end
print(gcf,format,savepath);
