function Data = downloadDrifter(comm_port, filename)
%DOWNLOADDRIFTER download Drifter data
%function Data = downloadDrifter(comm_port, filename)
%inputs:
%   comm_port = communications port (eg. "COM3")
%   filename = string name of text file to save data (eg. 'Test1.mat')
%
%outputs:
%   Data = dropcam data
%
%dependencies:
%
%Eric Berkenpas
%10/31/2023
%
%See also DOWNLOAD_DATA
progress_bar = true;
s = serialport(comm_port, 57600);
s.Timeout = 10;
configureTerminator(s,"CR/LF");

%Get Total Samples (reg 166)

n_samples = get_register(s,166);
if progress_bar
    no_samples_str = num2str(n_samples);
    f = waitbar(0, 'Starting Download');
end

sample_index = 0;
while(sample_index<n_samples-1)
    sample_index = sample_index + 1;
    Data(sample_index) = get_sample(s,sample_index);
    
    %Update Progress Bar
    if (progress_bar)
        prog_str = ['Downloading sample ', num2str(sample_index), ' of ', no_samples_str];
        waitbar(sample_index/n_samples, f, prog_str);
    end
end

waitbar(1,f,'Finishing up');
close(f);

%Plot data
%keyboard;
%plotDrifter(Data);

%saveDrifter(filename, Data);
save(filename, 'Data');  %Save the file as a MAT file to save space
