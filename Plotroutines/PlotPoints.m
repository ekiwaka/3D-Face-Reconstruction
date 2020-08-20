function h=PlotPoints(points,style,pointsize)
%function PlotPoints(points,style,pointsize)
%points is a N x 3-vector
%pointsize and style are optional; see help of plot3 function
%h: plot handle
%
% v160923 Matti Stenroos

if nargin==2 
    h=plot3(points(:,1),points(:,2),points(:,3),style);
elseif nargin ==3
    h=plot3(points(:,1),points(:,2),points(:,3),style);
    set(h,'MarkerSize',pointsize);
else
    h=plot3(points(:,1),points(:,2),points(:,3),'k.');
end
