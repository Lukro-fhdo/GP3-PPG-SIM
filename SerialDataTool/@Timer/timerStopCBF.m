function timerStopCBF(obj,~,~)
    notify(obj,'evt_TimerStopFcn');
     if isequal(obj.signalTimer.Running, "on")
        
        stop(obj.signalTimer);
     end
end

