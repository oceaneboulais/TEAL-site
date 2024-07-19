function restoreViewCallback(app, ev)

% keyboard
if app.UIAxes == ev.Axes 
    ya = [0 (app.SampleRate.Value/2)/1e3];
    xa = [0 app.SelectDuration.Value];
    
    app.YlimLower.Value = ya(1);
    app.YlimUpper.Value = ya(2);
    app.XlimLower.Value = xa(1);
    app.XlimUpper.Value = xa(2);
    
    xlim(ev.Axes,xa)
    ylim(ev.Axes,ya)

elseif app.UIAxesBF == ev.Axes
    xa = [0 app.SelectDuration.Value];
    
    app.XlimLower.Value = xa(1);
    app.XlimUpper.Value = xa(2);
    
    xlim(ev.Axes,xa)
end