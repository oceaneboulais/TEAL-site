function driftcam = loadDrifterMatFile(time_utc_in,Data)
% this function loads in the SSR "Data" mat file and returns a structure
% INPUTS
%   time_utc_in: if time_utc is empty, load all the time points in ssr_data
%       if time_utc is 1 x 2 vector, use that as the limits of the times to load
%       otherwise, interpolate the log to the time points in time_utc
%   Data: the "Data" structure output from the SSR buoyancy engine
% driftcam:
%   time_utc: a datetime in UTC
%   depth_m: the depth in meters as measured by the USBL
%   yaw_deg: the yaw in deg as measured by the USBL
%   pitch_deg: the pitch in deg as measured by the USBL
%   roll_deg: the roll in deg as measured by the USBL
%   control_state: the control state of the bouyancy engine 
%
% A. Laferriere 2024

ssr_data.Timestamp = [Data.Timestamp];
ssr_data.Depth = [Data.Depth];
ssr_data.Yaw = [Data.Yaw];
ssr_data.Pitch = [Data.Pitch];
ssr_data.Roll = [Data.Roll];
ssr_data.Control_State = [Data.Control_State];

% sometimes there are duplicate time stamps...
[ssr_time,iuniq] = unique(datetime(ssr_data.Timestamp,'ConvertFrom','posixtime'));
%     duplicate_indices = setdiff( 1:numel(ssr_data.Timestamp), iuniq );
% if none of the times are in the set, skip them
if ~isempty(time_utc_in)
    if all(ssr_time<min(time_utc_in))||all(ssr_time>max(time_utc_in))
        return
    end
end
if isempty(time_utc_in)
    time_utc = ssr_time(:);
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
    zeroIdx = ssr_data.Control_State(iuniq)==0;
    if any(zeroIdx)
        warning('Removing control_state=0 from %i samples',sum(zeroIdx))
        iuniq(zeroIdx)=[];
        ssr_time(zeroIdx) = [];
    end
        
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
driftcam = table(time_utc,depth_m,yaw_deg,roll_deg,pitch_deg,control_state,control_label);

