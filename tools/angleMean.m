function mu = angleMean(alpha,dim)
% delta = angleMean(alpha,dim)
% get the difference in the angles alpha and beta in degrees

N = size(alpha,dim);
A = prod(exp(1i*alpha*pi/(180*N)),dim);
mu = angle(A)*180/pi;