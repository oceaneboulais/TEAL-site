function make_HYCOM_forecast_figure(figtype,zoomoption,datapath,data);
% Plot the current HYCOM velocity field, as well as a target of what we think a good deployment location is
%
%
% Alex Andriatis
% 2021-05-02
 
figpath = fullfile(datapath,'Figures');

dmean = 200;

if strcmp(figtype,'movie')
  timevec = data.time(1):3/24:data.time(end);
else
  timevec = getUTC_3h;
end

switch zoomoption
    case 1
        figname = 'HYCOM_forecast_200';
        xl = [-127 -116];
        yl = [26.5 35];       
    case 2
        figname = 'HYCOM_forecast_200_zoom';
        xl = [-124 -120];
        yl = [30 34];
end

lonc = -122;
latc = 32;
oprad = 140; %kilometers

lontar = -122.36;
lattar = 32.82;
lontarget = [lontar-0.1 lontar+0.1];
lattarget = [lattar-0.1 lattar+0.1];


scaledist = 50000;
scalelabel = '100 km';
quiverdist = 2;

tvec = data.time;
[~,depthI]=closest(data.depth,dmean);

if strcmp(figtype,'movie');
  vidfile = VideoWriter(fullfile(figpath,figname),'Motion JPEG AVI');
  %vidfile = VideoWriter(fullfile(figpath,figname),'MPEG-4');
  vidfile.FrameRate=6;
  vidfile.Quality=100;
  open(vidfile);
  framename = fullfile(figpath,[figname '_tmpmovieframe.jpg']);

  %vidfile = VideoWriter(fullfile(figpath,figname),'MPEG-4');
  %vidfile.FrameRate=6;
  %open(vidfile);
end

f = figure('visible','off');
  width = 1024; height = 768;
  set(f,'Position', [width/2 height/2 width height]);

  for movietime = 1:length(timevec)
    clf
    
    xlim(xl);
    ylim(yl);
    map_aspectratio;
    hold on;

    disp(['Writing frame ' num2str(movietime) ' of ' num2str(length(timevec))]);

    targettime = timevec(movietime);
    [~,t]=closest(tvec,targettime);
   
       [~,latI]=closest(data.latitude,yl);
       [~,lonI]=closest(data.longitude,xl);
       latitude = data.latitude(latI(1):latI(2));
       longitude = data.longitude(lonI(1):lonI(2));
       
       u = squeeze(mean(data.u(lonI(1):lonI(end),latI(1):latI(end),1:depthI,t),3));
       v = squeeze(mean(data.v(lonI(1):lonI(end),latI(1):latI(end),1:depthI,t),3));
      
        % Contour plot of velocity
        speed = (u.^2+v.^2);
        speed = sqrt(speed);
        speedcont = linspace(1e-4,0.5,100);
        speedplot = imagescnan(longitude,latitude,speed',[speedcont(1) speedcont(end)]); 
        speedplot.HandleVisibility = 'off';
        axis xy;
        cmocean('speed',100);
        c = colorbar;
        c.Label.String = 'Current Speed [m/s]';
        c.HandleVisibility='off';
        
        [XG,YG]=meshgrid(longitude(1:quiverdist:end),latitude(1:quiverdist:end));


          % Plot flow field
          q1(1)=quiver(XG,YG,u(1:quiverdist:end,1:quiverdist:end)',v(1:quiverdist:end,1:quiverdist:end)','Color','r','HandleVisibility','off');
          q1(2)=quiver(-119,34.5,0.5,0,'linewidth',2,'Color','r','HandleVisibility','off');
          scale_quivers(q1,0.1) %you might have to play around with the scaling factor to make them the appropriate size for your figure, this is just what worked when I was making my FLEAT plots
          text(-119,34.6,'0.5 m/s','VerticalAlignment','bottom','HorizontalAlignment','center','Color','r','HandleVisibility','off');

        % Plot scale bars
         % Northwest corner
         scalex = (xl(1)+xl(2))/2;
         scaley = (yl(1)+yl(2))/2;
         [~,dlat] = xy2ll(0,scaledist,scalex,scaley);
         dlat = dlat-scaley; 
         [dlon,~] = xy2ll(scaledist,0,scalex,scaley);
         dlon = dlon-scalex;

         scalex = xl(2)-dlon;
         scaley = yl(2)-dlat;

         % Horizontal scale bar
         line([scalex-dlon scalex+dlon],[scaley scaley],'HandleVisibility','off','Color','r');
         text(scalex-dlon/2,scaley,scalelabel,'VerticalAlignment','bottom','HorizontalAlignment','left','Color','r','HandleVisibility','off');

         % Vertical scale bar
         line([scalex scalex],[scaley-dlat scaley+dlat],'HandleVisibility','off','Color','r');
         text(scalex,scaley+dlat/2,scalelabel,'VerticalAlignment','bottom','HorizontalAlignment','left','Color','r','HandleVisibility','off');
         
        theta = 0:pi/50:2*pi;
        r = oprad*1000; % meters circle radius
        [circlon,circlat] = xy2ll(r*cos(theta),r*sin(theta),lonc,latc);
        patch(circlon,circlat,'k','EdgeColor','red','FaceColor','none','DisplayName','Operational Region')

         % Box around proposed TFO region
         plot([lontarget(1) lontarget(1) lontarget(2) lontarget(2) lontarget(1)],[lattarget(1) lattarget(2) lattarget(2) lattarget(1) lattarget(1)],'Color','k','LineWidth',2,'HandleVisibility','off')

         % Point in center
         centerpoint = scatter(mean(lontarget),mean(lattarget),70,'mp','MarkerFaceColor','flat','DisplayName',sprintf('%0.2f N , %0.2f W',mean(lattarget),mean(lontarget)));
         legend('Location','southoutside','NumColumns',3);
        % Current timestamp
          c = data.time(t);

        % Make limits well behaved
            xlim(xl);
            ylim(yl);

        % Title with current timestamp
        timestr = datestr(c,'yyyy-mm-dd HH:MM:SS');
        title(['200m Velocities at ' timestr]);

        drawnow;

        if strcmp(figtype,'movie')

           % Save frame
           exportgraphics(f,framename,'Resolution',200);

           % Make sure the movie frames are all the same size by padding with
           % zeros
           movieframe = imread(framename);
           currentsize = size(movieframe);
           if movietime==1
             framesize = currentsize;
             moviesize = 2*ceil(framesize./2);
           end
           if any(currentsize~=framesize)
             disp(['Skipping frame ' num2str(t)]);
             continue
           end
           % Pad frame with whitespace if frame size is not even
           newframe = 255*ones([moviesize(1),moviesize(2),3]);
           newframe(1:currentsize(1),1:currentsize(2),:)=movieframe;
           newframe = uint8(newframe);

           % Save movie file
           writeVideo(vidfile, newframe);
           delete(q1);
         end
     
  end
  savepath = fullfile(figpath,figname);
  if strcmp(figtype,'figure');  
    saveas(f,savepath,'png');
    saveas(f,savepath,'fig');
  elseif strcmp(figtype,'movie')
    close(vidfile);
  end
  close(f);
  disp(['Saved figure in ' savepath]);
