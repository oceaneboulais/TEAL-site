function checkoutDrifterProgram(filename,deploy_time)
% drifter program verification and planning tool 
% reads in drifter program and plots expected drift profile 
% INPUTS 
%   filename: path to the drifter program
%   deploy_time:(optional) deployment time will set the x-axis in terms of time
%       otherwise it will be hours

if nargin==0
    filename = '/Volumes/Laferriere/ONR_DRIFTER/Example_Drifter_Programs/230906 September SIO Deployment.ttl';
    deploy_time = datetime(2023,9,6,9,0,0); 
end

surfaceVelocity = -0.1; % guess the surface velocity 

filetext = fileread(filename);

platformID = str2double(extractBetween(filetext,'''w1 ',''''));

missionStartSetpoint = str2double(extractBetween(filetext,'''w2 ',''''));

missionStartTimer = str2double(extractBetween(filetext,'''w3 ',''''));

missionEndSetpoint = str2double(extractBetween(filetext,'''w4 ',''''));

missionEndTimer = str2double(extractBetween(filetext,'''w5 ',''''));

lampsEnable = str2double(extractBetween(filetext,'''w9 ',''''));

lampsTon = str2double(extractBetween(filetext,'''w10 ',''''));

lampsToff = str2double(extractBetween(filetext,'''w11 ',''''));

cameraEnable = str2double(extractBetween(filetext,'''w12 ',''''));

cameraEnableRecord = str2double(extractBetween(filetext,'''w13 ',''''));

cameraTon = str2double(extractBetween(filetext,'''w14 ',''''));

cameraToff = str2double(extractBetween(filetext,'''w15 ',''''));

for diveIdx = 1:15

    diveStartTime(diveIdx) = str2double(extractBetween(filetext,sprintf('''w%i ',diveIdx + 20 -1),''''));

    diveDepth(diveIdx) = str2double(extractBetween(filetext,sprintf('''w%i ',diveIdx + 256 -1),''''));

    diveVelocity(diveIdx) = str2double(extractBetween(filetext,sprintf('''w%i ',diveIdx + 271 -1),''''));

end

for surfIdx = 1:10

    surfaceStartTime(surfIdx) = str2double(extractBetween(filetext,sprintf('''w%i ',surfIdx + 35 -1),''''));

    surfaceDuration(surfIdx) = str2double(extractBetween(filetext,sprintf('''w%i ',surfIdx + 45 -1),''''));

end

endMissionDepthEnable = str2double(extractBetween(filetext,'''w59 ',''''));

endMissionDepthThreshold = str2double(extractBetween(filetext,'''w60 ',''''));

endMissionVoltageEnable = str2double(extractBetween(filetext,'''w95 ',''''));

endMissionVoltageThreshold = str2double(extractBetween(filetext,'''w97 ',''''));

burnWireHardRelease = str2double(extractBetween(filetext,'''w126 ',''''));

burnWireReleaseDepth = str2double(extractBetween(filetext,'''w127 ',''''));

burnWireReleaseTime = str2double(extractBetween(filetext,'''w128 ',''''));

beaconPreMissionEnable = str2double(extractBetween(filetext,'''w170 ',''''));

beaconMissionEnable = str2double(extractBetween(filetext,'''w171 ',''''));

beaconPostMissionEnable = str2double(extractBetween(filetext,'''w172 ',''''));

beaconPulseTime = str2double(extractBetween(filetext,'''w173 ',''''));

beaconTimeBetween = str2double(extractBetween(filetext,'''w174 ',''''));

hibernateThreshold = str2double(extractBetween(filetext,'''w360 ',''''));

controlDepthThreshold = str2double(extractBetween(filetext,'''w362 ',''''));

oilLowThreshold = str2double(extractBetween(filetext,'''w366 ',''''));

oilHighThreshold = str2double(extractBetween(filetext,'''w367 ',''''));

for driftPing = 1:15
    fixAddress(driftPing) = str2double(extractBetween(filetext,sprintf('''w%i ',driftPing + 210 -1),''''));
end
fixAddress(fixAddress==0) = [];
fixPeriod = str2double(extractBetween(filetext,'''w225 ',''''));
fixDelay = str2double(extractBetween(filetext,'''w226 ',''''));

dt = 1;
t_sec = missionStartSetpoint:dt:missionEndTimer;

depth_mission = nan(1,length(t_sec));
depth_mission(1) = 0;
surfIdx = 1;

t_count_sec = 0;

for tidx = 2:length(t_sec)

    diveIdx = find(t_count_sec >=diveStartTime & diveStartTime~=-1,1,'last');
    
    if isempty(surfIdx)
        surfIdx = 1;
    end
    t_count_sec = t_count_sec + dt;
    if t_sec(tidx)<missionStartTimer
        % wait until the missionStartTimer to start the mission
        depth_mission(tidx) = 0;
        t_count_sec = 0;
    elseif t_sec(tidx)>=missionStartTimer && isempty(diveIdx)
        depth_mission(tidx) = depth_mission(tidx-1);
    elseif (~isempty(diveIdx) && t_count_sec >= diveStartTime(diveIdx))...
            && (~(t_count_sec >= surfaceStartTime(surfIdx)) ...
            || surfaceStartTime(surfIdx)==-1)
        % we have reached the time to start diving 
        % calculate new depth using dive speed
        if depth_mission(tidx-1) < diveDepth(diveIdx)
            depth_mission(tidx) = depth_mission(tidx-1) + diveVelocity(diveIdx)*dt;
        else 
            depth_mission(tidx) = diveDepth(diveIdx);
        end

    elseif t_count_sec >= surfaceStartTime(surfIdx) && surfaceStartTime(surfIdx)~=-1
        % calculate new depth using surface speed 
        surfTime = surfaceStartTime(surfIdx) + surfaceDuration(surfIdx);
        if depth_mission(tidx-1) > 0 
            % we have not reached the surface yet, keep surfacing
            depth_mission(tidx) = depth_mission(tidx-1) + surfaceVelocity*dt;
        elseif  depth_mission(tidx-1) <= 0 && t_count_sec < surfTime
            % we may have reached the surface, but we have not reached the
            % designated surfacing time so stay at the surface
            depth_mission(tidx) = 0;
        elseif t_count_sec >= surfTime && depth_mission(tidx-1) <= 0
            % start the next dive 
            surfIdx = surfIdx + 1;
            depth_mission(tidx) = 0;
        end
    else
        % depth_mission(tidx) = depth_mission(tidx-1);
        keyboard
    end
end

if ~lampsEnable || ~cameraEnableRecord || ~cameraEnable
    warning('Camera System is not fully enabled!')
end

if ~beaconPostMissionEnable || ~beaconPreMissionEnable
    warning('Beacon is not fully enabled!')
end

if ~endMissionVoltageEnable
    warning('Voltage threshold not enabled!')
end

% check to make sure the times are in expected order
if any(missionEndTimer < diveStartTime) || any(missionEndTimer < surfaceStartTime)
    error('Mission end time is not long enough for this mission!')
end

if burnWireHardRelease~=600
    warning('Burn wire release time has been changed!')
end

title1 = sprintf('Cameras will turn on for %1.0f minutes every %1.0f minutes',cameraTon/60,cameraToff/60);
title2 = sprintf('Beacon will flash for %1.0f seconds every %1.0f seconds',beaconPulseTime,beaconTimeBetween);
title3 = sprintf('USBL will ping every %1.0f minutes',fixPeriod/60);

t_cameraOn_sec = 0:(cameraTon+cameraToff):missionEndTimer;
t_cameraOff_sec = cameraTon:(cameraTon+cameraToff):missionEndTimer;

Npings = length(fixAddress);
tmpFixDelay = fixDelay;
for ii = 1:Npings
    t_fix_sec{ii} = tmpFixDelay:(Npings*fixPeriod):missionEndTimer;
    tmpFixDelay = tmpFixDelay + fixPeriod;
end
    

if exist('deploy_time','var')
    t = deploy_time + seconds(t_sec);
    

    ton_cam = deploy_time + seconds(t_cameraOn_sec);
    toff_cam = deploy_time + seconds(t_cameraOff_sec);

    hold on; ya = ylim;
    for idx = 1:min(length(ton_cam),length(toff_cam))
        h(2) = area([ton_cam(idx) toff_cam(idx)],...
            [-endMissionDepthThreshold -endMissionDepthThreshold],'FaceAlpha',0.2,'FaceColor',[0.5 0.5 0]);
    end

    hold on
    if endMissionDepthEnable
        h(3) = plot(t,-endMissionDepthThreshold*ones(size(t)),'--r','linewidth',2);
    end

    if exist('t_fix_sec','var')
        cmap = lines(length(t_fix_sec));
        % cmap = 'm';
        for ii = 1:length(t_fix_sec)
            t_fix = deploy_time + seconds(t_fix_sec{ii});   
            hL = plot([t_fix(:) t_fix(:)],[-endMissionDepthThreshold ya(2)],'color',cmap(ii,:));
            h(end+1) = hL(1);
            leg_str{ii} = sprintf('Ping %i',fixAddress(ii));
        end
    else
        leg_str = '';
    end

    title({sprintf('Dive Profile: Platform ID %i',platformID),...
        sprintf('Mission Start: %s',deploy_time),title1,title2,title3})

    h(1) = plot(t,-depth_mission,'linewidth',2);
    grid on; grid minor;
    xlabel('Time')
    ylabel('Depth,m')
    dx = hours(1);
    ax2 = gca(); ax2.XTick = t(1):dx:t(end);
    set(gca,'XTickLabelRotation',90)
    datetick('x','mm-dd, HH:MM:SS','keepticks')
else
    t = t_sec/60^2;
    plot(t,-depth_mission,'linewidth',2)
    xlabel('Hours')
    grid on; grid minor;
    ylabel('Depth,m')
    
end



set(gca,'fontweight','bold','fontsize',14);


xlim([t(1) t(end)])

set(gca,'fontweight','bold','fontsize',14);

legendstr = {'Dive Profile','Camera On','Depth Threshold'};
legend(h,cat(2,legendstr,leg_str));

