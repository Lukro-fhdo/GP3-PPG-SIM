classdef SerialDataTool < handle
    %SERIALDATATOOL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %Protocoll
        %--Headerbytes--
        HB_CTRL = 0x11;
        HB_DATA = 0x12;
        HB_ERR  = 0x13;
        
        %--Terminatorbytes--
        PT_CR   = 0x0D;
        PT_LF   = 0x0A;
        
        %--Flagbytes---
        F_HEADERBYTE = 0;
        F_CR = 0;
        F_ENDPKG = 0;
        SEND_DATA = 1;
        
        
        %Objects
        mySerial;
        myGui;
        myTimer;
        
        %Signal Data
        sd_path;
        sd_Data = {};
        sd_DataIndex = 1;
        sd_length = 0;
        
        %Serial
        s_Port;
        s_Baud;
        
        %Serial listener
        L_SerByteAvb;
        L_ScreenMsgAvb ;
        
        %Timer listener
        L_TimerInt;
        L_TimerStop;
        L_TimerScreenMsgAvb;
        
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
            obj.myTimer = Timer(100);
            
            
            % Timer Eventlistener
            obj.L_TimerScreenMsgAvb     =listener(obj.myTimer,'evt_TimerScreenMsgFcn',@obj.gui_screenMsgTimer); 
            
            obj.L_TimerInt              =listener(obj.myTimer,'evt_TimerIntFcn',@obj.putSample);   
            
            obj.L_TimerStop             =listener(obj.myTimer,'evt_TimerStopFcn',@obj.gui_SendData);  
          
            % GUI Eventlistener
            
            obj.L_dd_portSelect         = listener(obj.myGui,'evt_dd_portSelectFcn',@obj.gui_updatePortList);
            
            obj.L_btn_connectSerial     = listener(obj.myGui,'evt_btn_connectSerialFcn',@obj.gui_ConnectSerial);
            
            obj.L_btn_disconnectSerial  = listener(obj.myGui,'evt_btn_disconnectSerialFcn',@obj.gui_DisconnectSerial);
            
            obj.L_btn_sendMsg           = listener(obj.myGui,'evt_btn_sendMsgFcn',@obj.gui_SendMessage);
            
            obj.L_btn_sendDate          = listener(obj.myGui,'evt_btn_sendDateFcn',@obj.gui_SendData);
        end
        
        function delete(obj)
            
        end
        
%% Memberfunctions
        readProtocol(obj);

        
%% Event Listener GUI
        function gui_screenMsgSerial(obj,~,~)

            tmp = obj.mySerial.guiMsg;
            obj.gui_screenMsg(tmp);
%             obj.myGui.newLine;
%             obj.myGui.writelineOnScreen(tmp);
%             obj.myGui.newLine;
%             obj.myGui.refreshScreen;
        end
        
        function gui_screenMsg(obj,msg)
            
            obj.myGui.newLine;
            obj.myGui.writelineOnScreen(msg);
            obj.myGui.newLine;
            obj.myGui.refreshScreen;
        end
        
        function gui_screenMsgTimer(obj,~,~)

            tmp = obj.myTimer.guiMsg;   
            obj.gui_screenMsg(tmp);
%             obj.myGui.newLine;
%             obj.myGui.writelineOnScreen(tmp);
%             obj.myGui.newLine;
%             obj.myGui.refreshScreen;
        end
            
         function gui_updatePortList(obj,~,~)
             
         end
         
         function gui_ConnectSerial(obj,~,~)
             [obj.s_Baud,obj.s_Port]= obj.myGui.getSerialPara;
             obj.mySerial = SerialCom(obj.s_Port,obj.s_Baud);
             
             %Set Listener
             obj.L_ScreenMsgAvb          = listener(obj.mySerial,'ScreenMsgFcn',@obj.gui_screenMsgSerial);
            
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
             
                %get data to send from Gui
                headerbyte = obj.myGui.getHeaderbyte;
                msg = obj.myGui.getMsg;
            
                %check if msg is empty
                if ~isempty(msg)
                    
                    %check if Headerbyte != 0
                    if ~isequal(headerbyte,0x00)
                        obj.mySerial.writeByte(headerbyte);
                    end %end if
                    
                    for i = 1 : length(msg) 
                        obj.mySerial.writeByte(msg(i));
                    end
                    
                    %write CR+LF 
                    obj.mySerial.writeByte(obj.PT_CR);
                    obj.mySerial.writeByte(obj.PT_LF);
                end %end if
         end
         
         function gui_SendData(obj,~,~)
             if obj.SEND_DATA == 1
                if loadFile(obj) == 1
                    obj.SEND_DATA = 0;
                    obj.myGui.btn_sendData.Text = 'Stop';
                    obj.sd_DataIndex = 1;
                    
                    obj.myTimer.init(obj.sd_length)
                    obj.myTimer.startTimer;
                else
                    % ToDo Error Message
                end
             else
%                  temp = obj.sd_Data(obj.sd_DataIndex,1);
%                  disp(temp);
                if ~isempty (obj.myTimer.signalTimer)
                    stop(obj.myTimer.signalTimer);
                    delete(obj.myTimer.signalTimer)
%------> deletefunction for timer!!!!!!!!
%------> deletefunction for timer!!!!!!!!
%------> deletefunction for timer!!!!!!!!
                end
%------> stopfunction for timer!!!!!!!!
%------> stopfunction for timer!!!!!!!!
%------> stopfunction for timer!!!!!!!!
                 %reset button
              obj.SEND_DATA = 1;
                 obj.myGui.btn_sendData.Text = 'Send Data';

            end
             
             
         end
         function putSample(obj,~,~)
             temp = obj.sd_Data(obj.sd_DataIndex,1);
             disp(temp);
             obj.sd_DataIndex = obj.sd_DataIndex + 1;
         end       
%% EVENTLISTENER UART       
        function s_readByte(obj,~,~)
            obj.readProtocol;
        end
        

    end
end

