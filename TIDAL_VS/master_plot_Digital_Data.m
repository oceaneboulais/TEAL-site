%%%%%%master_plot_Digital_Data.m%%%
%  Jan 31,2024
clear
close all

addpath EnumClass/ functions/

%%%%Enter the directory with files here.
keyword='Firmware_benchtest_Aug2024';
for TiDAL_ID=1:1

    data_path=load_directory_locations(keyword,TiDAL_ID);

    toffset=datenum(0,0,0,1,0,0);  %Convert from Mountain time to local time
    mydir=pwd;
    cd(data_path)
    fnames=dir('Digital*mat');
    Nsamples_estimated=30*length(fnames);
    DigitalDataMeas=zeros(Nsamples_estimated,18);

    Iptr=1;
    for Iname=1:length(fnames)
        disp(fnames(Iname).name);
        data_one=load(fnames(Iname).name);
        Npt=size(data_one.DigitalDataMeas,1);
        DigitalDataMeas(Iptr+(1:Npt)-1,:)=data_one.DigitalDataMeas;
        Iptr=Iptr+Npt;

        if Iname==1
            tabs=datenum(data_one.DigitalPar.Header.CurrentTime);
            tabs=tabs+datenum(0,0,0,0,0,10*(0:(Nsamples_estimated-1)));
        end
    end
    cd(mydir)

    %%%Correct for possible offset (Mountain time to Central time)
    tabs=tabs-toffset;

    figure('Position',[50,50,1200,600]);
    CalPlot = tiledlayout(2,1,'TileSpacing','Compact');
    % Plot raw magnetometer values
    nexttile
    plot(tabs,DigitalDataMeas(:,7),'-b')
    hold on;
    plot(tabs,DigitalDataMeas(:,8),'-r')
    plot(tabs,DigitalDataMeas(:,9),'-g')
    datetick('x',14);xtickangle(60);
    hold off;
    ylabel('Magnetic (nT)')
    %ylim([-60000,-70]);
    ax = gca;
    ax.YAxis.Exponent = 0;
    ytickformat('%,.0f')
    %ylim([-50000 50000]);
    title('Raw Magnetometer Values')
    legend('Ch. X','Ch. Y','Ch. Z','Location','eastoutside')
    grid on

    axx(1)=ax;
    %
    % Plot Values before Calibration
    nexttile
    plot(tabs,DigitalDataMeas(:,4),'-b')
    hold on;
    plot(tabs,DigitalDataMeas(:,5),'-r')
    plot(tabs,DigitalDataMeas(:,6),'-g')
    ylabel('Acceleration [g]')
    hold off;
    title('Raw Accelerometer Values')
    legend('Ch. X','Ch. Y','Ch. Z','Location','eastoutside')
    datetick('x',14);xtickangle(60);
    grid on
    xlabel('Local Time')
    %ylim([-1.5 1.5])
    axx(2)=gca;

    linkaxes(axx,'x');

    orient landscape
    xtickk=get(gca,'Xtick');
    xtickk=xtickk(1):datenum(0,0,0,1,0,0):xtickk(end);
    set(gca,'xtick',xtickk)
    datetick('x',0,'keeplimits','keepticks');
    drawnow

    print('-djpeg',sprintf('%s_NAS_%i.jpg',keyword,TiDAL_ID));
    pause(1)
    save(sprintf('%s_NAS_%i.mat',keyword,TiDAL_ID),'tabs','DigitalDataMeas')
    %save DigitalDataMeas_01262024.mat tabs DigitalDataMeas

    
    %close

end