function ax2 = driftcamStatusPlot(driftcam,control_label,sunset_time,sunrise_time)

yyaxis left
plot(driftcam.time_utc,-driftcam.depth_m,'linewidth',2)
ylabel('Depth,m')

yyaxis right
plot(driftcam.time_utc,driftcam.control_state,'linewidth',2)
yticks([1:length(control_label)]-1)
yticklabels(control_label);
set(gca,'fontweight','bold','fontsize',14);
ylabel('Control State')
grid on

% repeat the sunset/sunrise times for the whole time period
[y,m,d] = ymd(driftcam.time_utc);
ymd_datetime = unique(datetime(y,m,d));

hold on
ya = ylim; xa = xlim;
for ss = 1:length(ymd_datetime)
    sunset = ymd_datetime(ss) + timeofday(sunset_time(1));
    sunrise = ymd_datetime(ss) + timeofday(sunrise_time(1));
    hs(1)= plot(repmat(sunrise,[1 2]),ya,'--','color',[0.9290 0.6940 0.1250],'linewidth',2);
    hs(2) = plot(repmat(sunset,[1 2]),ya,'--','color',[0.6350 0.0780 0.1840],'linewidth',2);
end
legend(hs,'sunrise','sunset')

ax2 = gca(); ax2.XTick = linspace(xa(1),xa(end),80);
ax2.XTickLabel = '';