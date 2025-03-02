function J = redwhiteblue(m)
%REDWHITEBLUE    Variant of HSV
%   REDWHITEBLUE(M), a variant of HSV(M), is an M-by-3 matrix containing
%   the default colormap used by CONTOUR, SURF and PCOLOR.
%   The colors begin with dark blue, range through shades of
%   blue, cyan, white, yellow and red, and end with dark red.
%   REDWHITEBLUE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   See also HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT, JET

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end
n = ceil(m/4);

tmp = (1:1:n)/n * 2; tmp(find(tmp>=1)) = 1; 

ur = [tmp ones(1,n-1) (n:-1:1)/n]';
ug = [(1:1:n)/n ones(1,n-1) (n:-1:1)/n]';
ub = [(1:1:n)/n ones(1,n-1) fliplr(tmp)]';
g = ceil(n/2) - (mod(m,4)==1) + (1:length(ug))';
r = g + n;
b = g - n;
g(g>m) = [];
r(r>m) = [];
b(b<1) = [];
J = zeros(m,3);
J(r,1) = ur(1:length(r));
J(g,2) = ug(1:length(g));
J(b,3) = ub(end-length(b)+1:end);
