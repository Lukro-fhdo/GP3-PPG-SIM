function timerStopCBF(obj,~,~)
     notify(obj,'evt_TimerStopFcn');
     delete(obj.signalTimer);
end

