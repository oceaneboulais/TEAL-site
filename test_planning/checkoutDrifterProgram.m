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

dt = 1;
t_sec = missionStartSetpoint:dt:missionEndTimer;

depth_mission = nan(1,length(t_sec));
depth_mission(1) = 0;
surfaceVelocity = -0.1; % guess the surface velocity 
surfIdx = 1;

for tidx = 2:length(t_sec)

    diveIdx = find(t_sec(tidx) >=diveStartTime & diveStartTime~=-1,1,'last');
    
    if t_sec(tidx)<missionStartTimer
        depth_mission(tidx) = 0;
    elseif (~isempty(diveIdx) && t_sec(tidx) >= diveStartTime(diveIdx)) && ~(t_sec(tidx) >= surfaceStartTime(surfIdx))
        % calculate new depth using dive speed
        if depth_mission(tidx-1) < diveDepth(diveIdx)
            depth_mission(tidx) = depth_mission(tidx-1) + diveVelocity(diveIdx)*dt;
        else 
            depth_mission(tidx) = diveDepth(diveIdx);
        end

    elseif (~isempty(surfIdx) && t_sec(tidx) >= surfaceStartTime(surfIdx)) 
        % calculate new depth using surface speed 
        surfTime = surfaceStartTime(surfIdx) + surfaceDuration(surfIdx);
        if depth_mission(tidx-1) > 0 && t_sec(tidx) < surfTime
            depth_mission(tidx) = depth_mission(tidx-1) + surfaceVelocity*dt;
        elseif  depth_mission(tidx-1) <= 0 && t_sec(tidx) < surfTime
            depth_mission(tidx) = 0;
        elseif t_sec(tidx) >= surfTime
            % start the next dive 
            surfIdx = surfIdx + 1;
            depth_mission(tidx) = 0;
        end
    else
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

if exist('deploy_time','var')
    t = deploy_time + seconds(t_sec);
    plot(t,-depth_mission,'linewidth',2)
    grid on; grid minor;
    xlabel('Time')
    ylabel('Depth,m')
    dx = hours(2);
    ax2 = gca(); ax2.XTick = t(1):dx:t(end);
    set(gca,'XTickLabelRotation',90)
    datetick('x','mm-dd, HH:MM:SS','keepticks')

    title({sprintf('Dive Profile: Platform ID %i',platformID),...
        sprintf('Mission Start: %s',deploy_time),title1,title2})
else
    t = t_sec/60^2;
    plot(t,-depth_mission,'linewidth',2)
    xlabel('Hours')
    grid on; grid minor;
    ylabel('Depth,m')
    
end
hold on
if endMissionDepthEnable
    plot(t,-endMissionDepthThreshold*ones(size(t)),'--r','linewidth',2)
end


set(gca,'fontweight','bold','fontsize',14);


xlim([t(1) t(end)])

set(gca,'fontweight','bold','fontsize',14);

legend('Dive Profile','Depth Threshold')

