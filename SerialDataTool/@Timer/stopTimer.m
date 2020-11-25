function  state = stopTimer(obj)
    try
        if isequal(obj.signalTimer.Running, "on")
        
            stop(obj.signalTimer);
            delete(obj.signalTimer);
            state =1;
        end
    catch
        state =0;
    end
     
end

