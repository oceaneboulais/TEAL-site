function axisLimChangedCallback(hAxes,eventData,app)

if app.UIAxes == eventData.AffectedObject 
    % keyboard
    xa = xlim(eventData.AffectedObject);
    ya = ylim(eventData.AffectedObject);
    
    app.YlimLower.Value = ya(1);
    app.YlimUpper.Value = ya(2);
    app.XlimLower.Value = xa(1);
    app.XlimUpper.Value = xa(2);
elseif app.UIAxesBF == eventData.AffectedObject 
    xa = xlim(eventData.AffectedObject);
    
    app.XlimLower.Value = xa(1);
    app.XlimUpper.Value = xa(2);   
end