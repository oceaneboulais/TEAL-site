function delta = angleDiff(alpha,beta)

A = exp(1i*alpha*pi/180).*exp(-1i*beta*pi/180);
delta = angle(A)*180/pi;