function dg = degminsec2deg(D,M,S)
SGN = sign(D);
dg = SGN.*(abs(D) + abs(M)/60 + abs(S)/3600);