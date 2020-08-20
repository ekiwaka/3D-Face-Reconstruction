function hp=PlotMesh(mesh,varargin)
% function hp=PlotMesh(mesh,plotoptions)
% plotoptions: 
%   'view', <viewangle>
%   'figure', <number of figure>
%   'position', <position, [originx,originy,widthx,widthy]>
%   'inflated', <use inflated mesh? 1 or 0 (mesh.pinf is then needed)>
%   any parameter--value -pairs supported by the patch command
%           ('facecolor','r',etc...)
%
% v160923
% (c) Matti Stenroos, matti.stenroos@aalto.fi
%defaults:
deffacecolor=[1 .7 .7];
deffacealpha=.3;
defview=[-90 0];

%parsing:
if iscell(varargin) && length(varargin)==1 && iscell(varargin{1})
    varargin=varargin{1};
end

removeind=[];

[viewangle,isview,ind]=GetValue(varargin,'view');
if isview, removeind=[ind ind+1];else viewangle=defview;end

[fignr,isfignr,ind]=GetValue(varargin,'figure');
if isfignr,removeind=[removeind, ind, ind+1];figure(fignr);end

[pos,ispos,ind]=GetValue(varargin,'position');
if ispos, removeind=[removeind, ind ind+1];set(gcf,'position',pos);end

[infflag,isinfflag,ind]=GetValue(varargin,'inflated');
if isinfflag, removeind=[removeind, ind ind+1];end

keepind=setdiff(1:length(varargin),removeind);
plotopt=varargin(keepind);

%and draw:
if infflag
hp = patch('faces',mesh.e,'vertices',mesh.pinf,'facecolor',deffacecolor,'edgecolor','none',...,
    'facealpha',deffacealpha);
else
    hp = patch('faces',mesh.e,'vertices',mesh.p,'facecolor',deffacecolor,'edgecolor','none',...,
    'facealpha',deffacealpha);
end
%set options:
if ~isempty(plotopt);
    set(hp,plotopt{:});
end

%and apply camera & material
view(viewangle);
axis tight equal off; material dull;lighting gouraud;
if isempty(findobj(gca,'Type','light'));
    camlight
end

function [val,IsItThere,Index]=GetValue(input,parameter)
% function [val,IsItThere,Index]=GetValue(input,parameter)
% Gets a value from a parameter/value list
% input: parameter/value list; X1,Y1,X2,Y2,...
% parameter: the parameter to find
% val: value of the parameter

paralist=input;

test=strcmpi(paralist,parameter);
if ~any(test)
    val=[];
    IsItThere=0;
    Index=[];
else
    ind=find(test);
    val=paralist{ind+1};
    IsItThere=1;
    Index=ind;
end

    