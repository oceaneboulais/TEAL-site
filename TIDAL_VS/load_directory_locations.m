function base_dir=load_directory_locations(keyword,Inumber)


switch keyword
    case 'Piertest'
        base_dir='C:/Users/kcsou/Desktop/DURIP TiDAL/TiDAL SIO Pier Test Sept 2024/Unit002_VS097/2024-09-24T0950';
        if exist('Inumber','var')
            base_dir=sprintf(base_dir,Inumber);
        end
     case 'R3D_July2024'
        base_dir='/Volumes/R3D_V2/R3D_SecondDeployment_July2024/TiDAL/Unit00%i';
        if exist('Inumber','var')
            base_dir=sprintf(base_dir,Inumber);
        end
    case 'R3D_June2024'
        base_dir='/Volumes/R3D_V2/R3D_FirstDeployment_June2024/TiDAL/Tidal00%i';
        base_dir='/Volumes/Shared/DARPA_R3D_REEFENSE/R3D_FirstDeployment_June2024/TiDAL/Tidal00%i';
        if exist('Inumber','var')
            base_dir=sprintf(base_dir,Inumber);
        end
    otherwise
        base_dir='~/Desktop/2024-01-26T1120/';
        base_dir='/Users/thode/Projects/Equipment/VectorSensors/TIDAL_AVS/DiagnosticData/DoD SAFE-dRtK7WHg9cHh7EPv/VS209_Data/Sensor104';
        %base_dir='/Volumes/Untitled/2024-06-02T0302/';
        base_dir='/Volumes/Untitled/2024-06-02T0632/';


end