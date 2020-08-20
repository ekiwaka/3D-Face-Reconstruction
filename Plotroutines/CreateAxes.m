function ha=CreateAxes(Nrows, Ncols, index,gap,offset,leftover,posdebug)
% CREATEAXES makes tiled plot axes (see also SUBPLOT)
% function ha=CREATEAXES(Nrows, Ncols, index,gapspace,offset,leftover)
%   Nrows:  Number of "tile rows"
%   Ncols:  Number of "tile colums"
%   gapspace:   relative spacing between tiles (optional, default 0.1)
%   offset:     [x_offset y_offset], offset for the first column/row
%               (optional, default [0 0])
%   leftover:   [x_leftover y_leftover], empty space left after the last
%               column/row (optional, default [0 0]
% v160923
% (c) Matti Stenroos, matti.stenroos@aalto.fi

xoff=0;
yoff=0;
xleft=0;
yleft=0;
if nargin<4 || isempty(gap)
    gap=.1;
end
if nargin>4 && ~isempty(offset)
    if ~isempty(offset(1))
        xoff=offset(1);
    end
    if length(offset)==2 && ~isempty(offset(2))
        yoff=offset(2);
    end
end
if nargin>5 && ~isempty(leftover)
    if ~isempty(leftover(1))
        xleft=leftover(1);
    end
    if length(leftover)==2 && ~isempty(leftover(2))
        yleft=leftover(2);
    end
end

boxw=(1-xoff-xleft)/Ncols;
boxh=(1-yoff-yleft)/Nrows;

boxoffsetw=.5*gap*boxw;
boxoffseth=.5*gap*boxh;

w=boxw*(1-gap);
h=boxh*(1-gap);


rowindex=ceil(index/Ncols);
colindex=index-(rowindex-1)*Ncols;
axes('position',[(colindex-1)*boxw+boxoffsetw+xoff (Nrows-rowindex)*boxh+boxoffseth+yleft  w h]);
if nargin==7 && posdebug
    fprintf('Position: ');
    fprintf('%.3f\t',[(colindex-1)*boxw+boxoffsetw (Nrows-rowindex)*boxh+boxoffseth  w h]);
    fprintf('\n');
end
ha=gca;