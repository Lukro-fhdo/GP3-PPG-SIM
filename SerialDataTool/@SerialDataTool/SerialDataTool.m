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
        
        %Serial listener
        L_SerByteAvb
        L_ScreenMsgAvb 
        
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
            
            
            % Serial Eventlistener
            
          
            % GUI Eventlistener
            
            obj.L_dd_portSelect         = listener(obj.myGui,'evt_dd_portSelectFcn',@obj.gui_updatePortList);
            
            obj.L_btn_connectSerial     = listener(obj.myGui,'evt_btn_connectSerialFcn',@obj.gui_ConnectSerial);
            
            obj.L_btn_disconnectSerial  = listener(obj.myGui,'evt_btn_disconnectSerialFcn',@obj.gui_DisconnectSerial);
            
            obj.L_btn_sendMsg           = listener(obj.myGui,'evt_btn_sendMsgFcn',@obj.gui_SendMessage);
            
            obj.L_btn_sendDate          = listener(obj.myGui,'evt_btn_sendDateFcn',@obj.gui_updatePortList);
        end
        
        function delete(obj)
% ------->  % delete all objects, timer and serial interfaces
% ------->  !!!!!            
        end
        

        
%% Event Listener GUI
        function gui_screenMsg(obj,~,~)
            tmp = obj.mySerial.guiMsg;
            obj.myGui.newLine;
            obj.myGui.writeOnScreen(tmp);
            obj.myGui.newLine;
            obj.myGui.refreshScreen;
        end
            
         function gui_updatePortList(obj,~,~)
         end
         
         function gui_ConnectSerial(obj,~,~)
             [obj.s_Baud,obj.s_Port]= obj.myGui.getSerialPara;
             obj.mySerial = SerialCom(obj.s_Port,obj.s_Baud);
             
             %Set Listener
             obj.L_ScreenMsgAvb          = listener(obj.mySerial,'ScreenMsgFcn',@obj.gui_screenMsg);
            
             obj.L_SerByteAvb            = listener(obj.mySerial,'BytesAvailableFcn',@obj.s_readByte);
     
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
                    obj.mySerial.writeByte(msg(i));
                end
         end
         
         function gui_SendData(obj,~,~)
         end
       
%% EVENTLISTENER UART       
        function s_readByte(obj,~,~)
            data = obj.mySerial.readByte;
            disp(data);        
        end
        

    end
end

