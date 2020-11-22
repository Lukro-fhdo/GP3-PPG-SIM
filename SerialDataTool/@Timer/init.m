function init(obj,cycles)

    obj.cycles = cycles;
    obj.signalTimer = timer('Period',obj.signalT,...
                'TasksToExecute', cycles,'ExecutionMode','fixedRate');

    %configure timer callback
    obj.signalTimer.TimerFcn = @(~,~) timerIntCBF(obj);
    obj.signalTimer.StopFcn = @(~,~) timerStopCBF(obj);


end