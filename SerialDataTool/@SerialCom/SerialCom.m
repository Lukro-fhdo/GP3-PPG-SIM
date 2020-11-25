classdef SerialCom < handle
    %SERIALCOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties %Private
        s_obj;
        s_port;
        s_baud;
        s_classType = 1; % 0 --> "serial" class, 1 --> "serialport" class
    end
    
    properties %public
        guiMsg
        
    end
    events
        BytesAvailableFcn;
        ScreenMsgFcn;
    end
    methods
        function obj = SerialCom(s_port,s_baud)
            obj.s_port = s_port;
            obj.s_baud = s_baud;
            
        end
        
        function putMsg(obj,msg)
            disp(msg);
            obj.guiMsg = msg;
            notify(obj,'ScreenMsgFcn');
        end
        
        writeByte(obj,dataOut);
        num = getNumBytesAvb(obj);
         
    end
end

