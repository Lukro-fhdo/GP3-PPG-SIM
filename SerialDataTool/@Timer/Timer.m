classdef Timer < handle
    %TIMER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        signalTimer;
        signalFs;
        signalT;
        state=0;
        cycles
    end
    properties
        guiMsg
    end
    events
        evt_TimerIntFcn;
        evt_TimerStopFcn;
        evt_TimerScreenMsgFcn;
    end
    
    methods
        function obj = Timer(samplerate)
            
            obj.signalFs = samplerate;
            obj.signalT = 1/samplerate;
            
        end
        
        
        
        function putMsg(obj,msg)
            disp(msg);
            obj.guiMsg = msg;
            notify(obj,'evt_TimerScreenMsgFcn');
        end
        
        %timerIntCBF(obj,~,~);
        %timerStopCBF(obj,~,~);
        
        state = stopTimer(obj);
        
       %state = startTimer(obj);
    end
end

