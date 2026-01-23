function delta = angleDiff(alpha,beta)
% delta = angleDiff(alpha,beta)
% get the difference in the angles alpha and beta in degrees

A = exp(1i*alpha*pi/180).*exp(-1i*beta*pi/180);
delta = angle(A)*180/pi;