function make_HYCOM_forecast_advection_figure(figtype,zoomoption);
% Plot the advection of the HYCOM field for a deployment at the most recent runtime
%
% Alex Andriatis
% 2021-05-02

datapath = '/home/aandriat/Data/HYCOM';
filename='TFO2_Hycom_Timeseries_advection.mat';
%filename='test.mat';

fpath = fullfile(datapath,filename);
data = load(fpath);

figpath = fullfile(datapath,'Figures');

dmean = 200;

% Movie time runs from "deployment" to end of advection
timevec = data.time;
timestr_i =  datestr(timevec(1),'yyyy-mm-dd HH:MM:SS');
if ~strcmp(figtype,'movie')
  timevec = timevec(end);
end

switch zoomoption
    case 1
        figname = 'HYCOM_forecast_200_advection';
        xl = [-127 -116];
        yl = [26.5 35];       
    case 2
        figname = 'HYCOM_forecast_200_advection_zoom';
        xl = [-124 -120];
        yl = [30 34];
end

lonc = -122;
latc = 32;
oprad = 140; %kilometers

% Operational region
theta = 0:pi/50:2*pi;
r = oprad*1000; % meters circle radius
[circlon,circlat] = xy2ll(r*cos(theta),r*sin(theta),lonc,latc);

lontar = -122.36;
lattar = 32.82;
lontarget = [lontar-0.1 lontar+0.1];
lattarget = [lattar-0.1 lattar+0.1];


scaledist = 50000;
scalelabel = '100 km';
quiverdist = 2;

dispcont = linspace(0,max(sum(data.displacement,3),[],'all'),100);
dispcont=dispcont/1000;

XGt = data.XGt;
YGt = data.YGt;

% Data grid        
[XG,YG]=meshgrid(data.longitude(1:quiverdist:end),data.latitude(1:quiverdist:end));

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
    %[~,t]=closest(tvec,targettime);
    t=movietime;
   

       displacement = squeeze(sum(data.displacement(:,:,1:t),3));
       displacement=displacement/1000;
       displacementplot = imagescnan(data.longitude,data.latitude,displacement,[dispcont(1) dispcont(end)]);
       displacementplot.HandleVisibility = 'off';
       
        axis xy;
        cmocean('turbid',100);
        c = colorbar;
        c.Label.String = 'Advected Distance from Deployment [km]';
        c.HandleVisibility='off';
        

          % Plot flow field
          XGd = XGt(1:quiverdist:end,1:quiverdist:end,t)-XGt(1:quiverdist:end,1:quiverdist:end,1);
          YGd = YGt(1:quiverdist:end,1:quiverdist:end,t)-YGt(1:quiverdist:end,1:quiverdist:end,1);
          q1(1)=quiver(XG,YG,XGd,YGd,0,'Color','b','HandleVisibility','off');

        % Operational Region
        patch(circlon,circlat,'k','EdgeColor','red','FaceColor','none','DisplayName','Operational Region')

         % Box around proposed TFO region
         plot([lontarget(1) lontarget(1) lontarget(2) lontarget(2) lontarget(1)],[lattarget(1) lattarget(2) lattarget(2) lattarget(1) lattarget(1)],'Color','k','LineWidth',2,'HandleVisibility','off')

         % Point in center
         centerpoint = scatter(mean(lontarget),mean(lattarget),70,'mp','MarkerFaceColor','flat','DisplayName',sprintf('%0.2f N , %0.2f W',mean(lattarget),mean(lontarget)));
         legend('Location','southoutside','NumColumns',3);
         
        % Current timestamp
          c = timevec(t);

        % Make limits well behaved
            xlim(xl);
            ylim(yl);

        % Title with current timestamp
        timestr = datestr(c,'yyyy-mm-dd HH:MM:SS');
        
        title(['Integrated Displacement at 200m from ' timestr_i ' to ' timestr]);
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
  if strcmp(figtype,'png');  
    saveas(f,savepath,'png');
  elseif strcmp(figtype,'fig');
    saveas(f,savepath,'fig');
  elseif strcmp(figtype,'movie')
    close(vidfile);
  end
  close(f);
