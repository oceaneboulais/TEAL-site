function plotElevationHistogram(t_utc,el_centers,elev_hist,title_str)

% if exist('el_hist_fig','var')
%     set(groot,'CurrentFigure',el_hist_fig)
%     ssize = get(groot, 'ScreenSize'); 
%     set(gcf, 'Position', ssize);
% 
% end
if ~exist('title_str','var')
    title_str = [];
end
xa = [t_utc(1) t_utc(end)];

pcolor(t_utc,el_centers,squeeze(elev_hist./max(elev_hist,[],2)).');axis('xy')
% imagesc(t_utc,el_centers,squeeze(elev_hist);axis('xy')
shading flat
ylabel('Elevation, deg')
xlabel('Time')
set(gca,'fontweight','bold','fontsize',14);
ylim([-90 90])
caxis([0 1])
hold on
datetick('x')

ax2 = gca(); ax2.XTick = linspace(ax2.XTick(1),ax2.XTick(end),80);
set(gca,'XTickLabelRotation',90)
ax2 = gca(); ax2.XTick = linspace(ax2.XTick(1),ax2.XTick(end),80);
datetick('x','mm-dd, HH:MM:SS','keepticks')
set(gca,'fontweight','bold','fontsize',14);
set(gca,'XTickLabelRotation',90)
set(gca,'fontweight','bold','fontsize',14);
title(cat(2,{sprintf('%s to %s',datestr(xa(1)),datestr(xa(2)))},title_str))
xlim(xa)
xlabel('Elevation, deg')
