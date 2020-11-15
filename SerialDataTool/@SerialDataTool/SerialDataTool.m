classdef SerialDataTool < handle
    %SERIALDATATOOL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        %Objects
        mySerial
        myGui
        list
        
        %Serial
        s_Port
        s_Baud
        
        %listener
        L_SerByteAvb
        
        %gui Listener
        L_dd_portSelect;
        
        L_btn_clearScreen;
        L_btn_connectSerial;
        L_btn_disconnectSerial;
        L_btn_sendMsg;
        L_btn_sendDate;
    end
    
    methods
        function obj = SerialDataTool()
            %obj.test;
            
            obj.myGui = GUI;
           
            % GUI Eventlistener
            
            obj.L_dd_portSelect         = listener(obj.myGui,'evt_dd_portSelectFcn',@obj.gui_updatePortList);
            
            obj.L_btn_connectSerial     = listener(obj.myGui,'evt_btn_connectSerialFcn',@obj.gui_ConnectSerial);
            
            obj.L_btn_disconnectSerial  = listener(obj.myGui,'evt_btn_disconnectSerialFcn',@obj.gui_DisconnectSerial);
            
            obj.L_btn_sendMsg           = listener(obj.myGui,'evt_btn_sendMsgFcn',@obj.gui_SendMessage);
            
            obj.L_btn_sendDate          = listener(obj.myGui,'evt_btn_sendDateFcn',@obj.gui_updatePortList);
        end
        
%         function  test(obj)
%             obj.list = serialportlist;
%             port = obj.list(4);
%             baud = 9600;
%             obj.mySerial = SerialCom(port,baud);
%             obj.mySerial.open;
%             %obj.mySerial.close;
%             obj.L_SerByteAvb = listener(obj.mySerial,'BytesAvailableFcn',@obj.s_readByte);
%         end
        
%% Event Listener
         function gui_updatePortList(obj,~,~)
         end
         
         function gui_ConnectSerial(obj,~,~)
             [obj.s_Baud,obj.s_Port]= obj.myGui.getSerialPara;
             obj.mySerial = SerialCom(obj.s_Port,obj.s_Baud);
             if obj.mySerial.open
                 obj.myGui.showConnected;
             end
         end
         
         function gui_DisconnectSerial(obj,~,~)
             obj.mySerial.close;
             obj.myGui.showDisconnected;
         end
         
         function gui_SendMessage(obj,~,~)
                msg = obj.myGui.getMsg;
                
                for i = 1 : length(msg) 
                    obj.mySerial.write(msg(i));
                end
         end
         
         function gui_SendData(obj,~,~)
         end
       
        
        function s_readByte(obj,~,~)
            data = obj.mySerial.readByte;
            disp(data);
        
        end
        
        function burstwrite(obj)
            tic;
            for n = 1:100
                obj.mySerial.writeByte(n);
            end
            toc;
        end
    end
end

