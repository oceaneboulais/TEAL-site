function mu = angleMean(alpha, dim)
%ANGLEMEAN  Mean of angles in degrees (circular mean)
%   mu = angleMean(alpha, dim)
%
%   Computes the mean direction accounting for wrap-around.

A = mean(exp(1i * alpha * pi / 180), dim);  % take the mean of unit vectors
mu = angle(A) * 180 / pi;                   % convert back to degrees