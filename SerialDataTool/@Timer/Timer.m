classdef Timer < handle
    %TIMER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        signalTimer;
        signalFs;
        signalT;
        cycles
    end
    events
        TimerIntFCN;
    end
    
    methods
        function obj = Timer(samplerate,cycles)
            
            obj.signalFs = samplerate;
            obj.signalT = 1/samplerate;
            obj.cycles = cycles
            obj.signalTimer = timer('Period',obj.signalT,...
                        'TasksToExecute', cycles,'ExecutionMode','fixedRate');
                    
            %configure timer callback
            obj.signalTimer.TimerFcn = @obj.timerIntCBF;

        end
        
        function putMsg(obj,msg)
            disp(msg);
        end
        
       
    end
end

