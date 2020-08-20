function [M,its] = relaxgaps(M,gv,a,imax,dmax,vis)
% === relaxgaps ===
% Fills in gaps of an input matrix using overrelaxation
%
% Input:
%  - Mg:    Matrix gaps
%  - gv:    gap value
%  - a:     over relaxation value (should be 1<a<2)
%           a<1 will only be slower in almost all cases
%           1<a<2 can be unstable
%           a<0 or a>2 will be unstable
%  - imax:  max number of iterations
%  - dmax:  target convergence value
%  - vis:   Visualise the algorithm
%
% Output:
%  - Mf:    Matrix filled
%  - its:   Number of iterations needed
%
% Computes sensible values for which laplacian -> 0
% Known values will be used as boundary conditions
% Convergence value e is squared sum of difference 
% with previous iteration.
%
% Shifted matrices are padded with continuous values
% in perpendicular direction, causing a dv/dn -> 0
% where n is either horizontal or vertical direction
% depending on the edge.

% Spawn figure for visualisation if applicable
if vis; figure; end

% Generate Gap Mask Matrix (1 if there's a gap, 0 otherwise)
G = zeros(size(M));
G(M == gv) = 1;

% Compute initial gap value and fill in gaps with this value
igv = mean(M(G==0));
M(G==1) = igv;

% Perform iterative over relaxation
for i = 1:imax
    % Create shifted matrices
    M1 = [M(2:end,:);    M(end,:)];
    M2 = [M(1,:);    M(1:end-1,:)];
    M3 = [M(:,2:end)     M(:,end)];
    M4 = [M(:,1)     M(:,1:end-1)];
    
    % Relaxation computations
    DM = (0.25 * (M1+M2+M3+M4) - M) .* G;   % Compute difference matrix
    M = M + a*DM;                           % Calculate new matrix
    
    % Check target convergence
    if sum(DM.^2) < dmax                    % If target convergence reached
        break                               % Break out of loop
    end
    
    % Visualise algorithm if set by 'visualise'
    if vis
        imagesc(M)
        title(sprintf('Over relaxation, i = %i',i))
        [row,col] = find(G);
        hold on
        plot(col,row,'sk')
        hold off
        colorbar
        drawnow
        pause(0.01)
    end
end

its = i;
