
filename = '220919 Dive 5.txt';

DataStructure = loadDrifter(filename);

nSamples = length(DataStructure);

DataMatrix = zeros(10, nSamples);

%Generate Headers
headers = {'Time[s]','Fx[N]','Fy[N]','Depth[m]','Phi[deg]','Theta[deg]', 'Psi[deg]','Control Enable','Volume[L]','Set Volume'};

%csvwrite_with_headers('text.csv', DataMatrix, headers)

keyboard;