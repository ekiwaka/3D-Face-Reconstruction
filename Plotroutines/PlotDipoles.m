function h=PlotDipoles(r,P,linewidth,scale)
%function h=PlotDipoles(positions,moments,linewidth,scalefactor)
%positions, moments: dim = N x 3
%linewidth optional
%scale optional
%see help of quiver3 function
%h: plot handle
%
% v160923 Matti Stenroos

x=r(:,1);
y=r(:,2);
z=r(:,3);
Px=P(:,1);
Py=P(:,2);
Pz=P(:,3);

if nargin==4
    h=quiver3(x,y,z,Px,Py,Pz,scale);
else
    h=quiver3(x,y,z,Px,Py,Pz);
end
if nargin>2
    set(h,'LineWidth',linewidth);
end
