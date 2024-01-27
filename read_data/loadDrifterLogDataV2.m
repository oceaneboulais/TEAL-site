function [driftcam,control_label] = loadDrifterLogDataV2(time_utc_in,datadrive,drifter)
% if time_utc is empty, load all the time points for this drifter in the data drive
% if time_utc is 1 x 2 vector, use that as the limits of the times to load
% otherwise, interpolate the log to the time points in time_utc


[~,D] = fileparts(datadrive);
if ~strcmp(D,'ControlSystem')
    log_filelist = dir(fullfile(datadrive,'**',sprintf('Drifter%i*',drifter),'ControlSystem','*.txt'));
else
    log_filelist = dir(fullfile(datadrive,'*.txt'));
end
% if isempty(log_filelist)
%     driftcam = []; 
%     control_label = [];
% end
driftcam = []; 
control_label = [];
for ifile = 1:length(log_filelist)
    ssr_file = fullfile(log_filelist(ifile).folder,log_filelist(ifile).name);
    ssr_data = loadDrifterLog(ssr_file);

    [ssr_time,iuniq] = unique(datetime(ssr_data.Timestamp,'ConvertFrom','posixtime'));
    % if none of the times are in the set, skip them
    if all(ssr_time<min(time_utc_in))||all(ssr_time>max(time_utc_in))
        continue
    end
    if isempty(time_utc_in)
        time_utc = ssr_time;
    elseif size(time_utc_in,2)==2&size(time_utc_in,1)==1
        time_utc = ssr_time(ssr_time>=time_utc_in(1)&ssr_time<=time_utc_in(2));
    else
        time_utc = time_utc_in(:);
    end
    depth_m = single(interp1(ssr_time,ssr_data.Depth(iuniq),time_utc));
    yaw_deg = single(interp1(ssr_time,ssr_data.Yaw(iuniq),time_utc));
    pitch_deg = single(interp1(ssr_time,ssr_data.Pitch(iuniq),time_utc));
    roll_deg = single(interp1(ssr_time,ssr_data.Roll(iuniq),time_utc));
    control_label = strings(size(depth_m));
    if isfield(ssr_data,"Control_State")
        % control_state =interp1(ssr_time,ssr_data.Control_State(iuniq),time_utc)-1;
        % control_label = {'Control','Hibernate', 'Dive', 'Surface', 'Interval'};
        control_state =interp1(ssr_time,ssr_data.Control_State(iuniq),time_utc);
        control_label_list = ["Control","Hibernate", "Dive", "Surface", "Interval"];
        control_label(~isnan(control_state)) = control_label_list((int8(control_state(~isnan(control_state))))).';
    elseif length(unique(ssr_data.OP))==5||max(ssr_data.OP)==5
        % control_state =interp1(ssr_time,ssr_data.OP(iuniq),time_utc)-1;
        control_state =interp1(ssr_time,ssr_data.OP(iuniq),time_utc);
        % control_label = {'Control','Hibernate', 'Dive', 'Surface', 'Interval'};        
        control_label_list = ["Control","Hibernate", "Dive", "Surface", "Interval"];    
        control_label(~isnan(control_state)) = control_label_list((int8(control_state(~isnan(control_state))))).';
    else
        control_state = interp1(ssr_time,ssr_data.OP(iuniq),time_utc);
        % control_label = {'Control','Hibernate'};%??
        control_label_list = ["Control","Hibernate"];%??
        control_label(~isnan(control_state)) = control_label_list((int8(control_state(~isnan(control_state)))+1)).';
    end
    
    % control_label = cell(size(control_state))
    % control_label(~isnan(control_state)) = control_label{control_state(~isnan(control_state))+1};
    driftcam = vertcat(driftcam,table(time_utc,depth_m,yaw_deg,roll_deg,pitch_deg,control_state,control_label));
end
end
function t = convertLogTime(filelist)
[~,filename,~]=fileparts(filelist);
t=datetime(filelist(end-16:end-11),'InputFormat','yyMMdd');

end