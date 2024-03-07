function ax2 = driftcamStatusPlot(driftcam,sunset_time,sunrise_time)


if ~exist('sunset_time','var')
    sunset_time = [];
end
if ~exist('sunrise_time','var')
    sunrise_time = [];
end
if ~isempty(driftcam)
    [control_label,label_idx] = unique(driftcam.control_label);
    islabel = ~(control_label=="");
    control_label = control_label(islabel);
    [label_num,label_sort_idx] = sort(driftcam.control_state(label_idx(islabel)));
    control_label = control_label(label_sort_idx);

    yyaxis left
    plot(driftcam.time_utc,-driftcam.depth_m,'linewidth',2)
    ylabel('Depth,m')
    
    yyaxis right
    plot(driftcam.time_utc,driftcam.control_state,'linewidth',2)
    yticks(label_num)
    yticklabels(control_label);
    set(gca,'fontweight','bold','fontsize',14);
    ylabel('Control State')
    grid on
    
    % repeat the sunset/sunrise times for the whole time period
    [y,m,d] = ymd(driftcam.time_utc);
    ymd_datetime = unique(datetime(y,m,d));
    ya = ylim; xa = xlim;
else
    if ~isempty(sunset_time) & ~isempty(sunrise_time)
        [y,m,d] = ymd(sunset_time);
    end
    ymd_datetime = unique(datetime(y,m,(d-2):(d+2)));
end
hold on
ya = ylim; 

if ~isempty(sunset_time) & ~isempty(sunrise_time)
    for ss = 1:length(ymd_datetime)
        sunset = ymd_datetime(ss) + timeofday(sunset_time(1));
        sunrise = ymd_datetime(ss) + timeofday(sunrise_time(1));
        hs(1)= plot(repmat(sunrise,[1 2]),ya,'--','color',[0.9290 0.6940 0.1250],'linewidth',2);
        hs(2) = plot(repmat(sunset,[1 2]),ya,'--','color',[0.6350 0.0780 0.1840],'linewidth',2);
    end
    legend(hs,'sunrise','sunset')
end
xa = xlim;
ax2 = gca(); ax2.XTick = linspace(xa(1),xa(end),80);
ax2.XTickLabel = '';