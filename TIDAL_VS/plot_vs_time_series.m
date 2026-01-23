%plot_vs_time_series

figure
title('Analog Data Zoomed')
hold on
plot(AnalogTime,MeasuredValues(:,1),'-xb')
plot(AnalogTime,MeasuredValues(:,2),'-+r')
plot(AnalogTime,MeasuredValues(:,3),'-og')
plot(AnalogTime,MeasuredValues(:,4),'-*c')
hold off
xlim([1,1.01])
ylim ([-2,2])
legend('ChX','ChY','ChH','ChZ')
xlabel('Time[s]')
ylabel('Amplitude[V]')
%
figure
title('Analog Data')
hold on
plot(AnalogTime,MeasuredValues(:,1),'-xb')
plot(AnalogTime,MeasuredValues(:,2),'-+r')
plot(AnalogTime,MeasuredValues(:,3),'-og')
plot(AnalogTime,MeasuredValues(:,4),'-*c')
hold off
legend('ChX','ChY','ChH','ChZ')
xlabel('Time[s]')
ylabel('Amplitude[V]')
%%
%Plot and display digital results

figure('Position',[50,50,1200,600]);
CalPlot = tiledlayout(2,1,'TileSpacing','Compact');
% Plot raw magnetometer values
nexttile
plot(DigitalDataMeas(:,7),'-b')
hold on;
plot(DigitalDataMeas(:,8),'-r')
plot(DigitalDataMeas(:,9),'-g')
hold off;
ylabel('Magnetic (nT)')
%ylim([-60000,-70]);
ax = gca;
ax.YAxis.Exponent = 0;
ytickformat('%,.0f')
title('Raw Magnetometer Values')
legend('Ch. X','Ch. Y','Ch. Z','Location','eastoutside')
%
% Plot Values before Calibration
nexttile
plot(DigitalDataMeas(:,4),'-b')
hold on;
plot(DigitalDataMeas(:,5),'-r')
plot(DigitalDataMeas(:,6),'-g')
ylabel('Acceleration [g]')
hold off;
title('Raw Accelerometer Values')
legend('Ch. X','Ch. Y','Ch. Z','Location','eastoutside')