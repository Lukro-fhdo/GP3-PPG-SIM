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
        RECORD_DATA = 0;
        
        %Plot Date
        tmp_Buffer = uint32(0);
        Buffersize = 256;
        Buffer;
        n_xAxis = 0;
        x;
        
        %Objects
        mySerial;
        myGui;
        SendTimer;
        ReadTimer;
        GuiUpdateTimer;
        
        %Signal Data
        sd_path;
        sd_Data = {};
        sd_DataIndex = 1;
        sd_length = 0;
        numBytes = 0;
        
        %Record Data
        rd_filename;
        rd_Buffer ={}

        %Serial
        s_Port;
        s_Baud;
        s_Buffer;
        
        %Serial listener
        L_SerByteAvb;
        L_ScreenMsgAvb ;
        
        %Timer listener
        L_TimerInt;
        L_TimerStop;
        L_TimerScreenMsgAvb;
        
        L_ReadTimerInt 
        
        %gui Listener
        L_dd_portSelect;
        
        L_btn_clearScreen;
        L_btn_connectSerial;
        L_btn_disconnectSerial;
        L_btn_sendMsg;
        L_btn_sendDate;
        L_btn_recordData
        
        L_closeGui
    end
    
    methods
        function myerror(~,~,~)
            disp('error')
        end
        function obj = SerialDataTool()
                        
            obj.myGui = GUI;
            obj.SendTimer = Timer(25);
            obj.SendTimer.signalTimer.BusyMode = 'error';
            obj.SendTimer.signalTimer.ErrorFcn = @myerror;
            
            obj.ReadTimer = Timer(25);
            
            
            
            
            %init plotbuffer
            obj.Buffer = zeros(1,obj.Buffersize);
            
            
            % SendTimer Eventlistener
            obj.L_TimerScreenMsgAvb     =listener(obj.SendTimer,'evt_TimerScreenMsgFcn',@obj.gui_screenMsgTimer); 
            
            obj.L_TimerInt              =listener(obj.SendTimer,'evt_TimerIntFcn',@obj.putSample);   
            
            obj.L_TimerStop             =listener(obj.SendTimer,'evt_TimerStopFcn',@obj.gui_SendData);  
            
            %ReadTimer Eventlistener
            
            obj.L_ReadTimerInt          =listener(obj.ReadTimer,'evt_TimerIntFcn',@obj.ReadData);
          
            % GUI Eventlistener
            
            obj.L_dd_portSelect         = listener(obj.myGui,'evt_dd_portSelectFcn',@obj.gui_updatePortList);
            
            obj.L_btn_connectSerial     = listener(obj.myGui,'evt_btn_connectSerialFcn',@obj.gui_ConnectSerial);
            
            obj.L_btn_disconnectSerial  = listener(obj.myGui,'evt_btn_disconnectSerialFcn',@obj.gui_DisconnectSerial);
            
            obj.L_btn_sendMsg           = listener(obj.myGui,'evt_btn_sendMsgFcn',@obj.gui_SendMessage);
            
            obj.L_btn_sendDate          = listener(obj.myGui,'evt_btn_sendDateFcn',@obj.gui_SendData);
            
            obj.L_closeGui              = listener(obj.myGui,'evt_closeGuiFcn',@obj.closeAll);

            obj.L_btn_recordData        = listener(obj.myGui,'evt_btn_recordDataFcn',@obj.recordData);
        end
        
        function delete(obj)
            
        end
        
%% Memberfunctions
% external
        readProtocol(obj);
        recordData(obj,~,~);


% internal


        
        function closeAll(obj,~,~)
            if ~isempty(timerfindall) 
            stop(timerfindall);
            delete(timerfindall);
             
             %delete(obj.myGui);
             delete(obj);
            end
            
        end
        
%% Event Listener GUI
        function gui_screenMsgSerial(obj,~,~)

            tmp = obj.mySerial.guiMsg;
            obj.gui_screenMsg(tmp);

        end
        
        function gui_screenMsg(obj,msg)
            
            %obj.myGui.newLine;
            obj.myGui.writelineOnScreen(msg);
            obj.myGui.newLine;
            obj.myGui.refreshScreen;
        end
        
        function gui_screenMsgTimer(obj,~,~)

            tmp = obj.SendTimer.guiMsg;   
            obj.gui_screenMsg(tmp);

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
                 obj.ReadTimer.init(inf);
                 obj.ReadTimer.startTimer;
             end
             
         end
         
         function gui_DisconnectSerial(obj,~,~)
             if(obj.ReadTimer.stopTimer)

                 if(obj.SendTimer.state == 1)
                    obj.SendTimer.stopTimer;
                 end
                 obj.mySerial.close;
                 obj.myGui.showDisconnected;
             end
             
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
                    
                    if isequal(headerbyte,obj.HB_DATA)
                         try % write only numbers 
                                temp = str2num(msg);
                                tempbyte = typecast(uint32(temp),'uint8');
                                %write Headerbyte
                                %write(obj.s,0x12,"uint8");
                                

                                %write seperated Databytes Highbyte to Lowbyte
                                %tempbyte(1) = uint8(bitsrl(int32(temp),24));
                                obj.mySerial.writeByte(tempbyte(4));

                                %tempbyte(2) = uint8(bitsrl(int32(temp),16));
                                obj.mySerial.writeByte(tempbyte(3));

                                %tempbyte(3) = uint8(bitsrl(int32(temp),8));
                                obj.mySerial.writeByte(tempbyte(2));

                                % write Lowbyte
                                %tempbyte(4) = uint8(bitand(int32(temp), int32(0x000000FF)));
                                obj.mySerial.writeByte(tempbyte(1));
                                
                         catch
                             
                         end
                    else
                        for i = 1 : length(msg) 
                            obj.mySerial.writeByte(msg(i));
                        end
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
                    
                    obj.SendTimer.init(obj.sd_length)
                    obj.SendTimer.startTimer;
                else
                    % ToDo Error Message
                end
             else

                stop(obj.SendTimer.signalTimer);
                %obj.SendTimer.stopTimer;
                obj.SEND_DATA = 1;
                
                obj.myGui.btn_sendData.Text = 'Send Data';

            end
             
             
         end
         function putSample(obj,~,~)
             
             temp = obj.sd_Data(obj.sd_DataIndex,1);
             %disp(temp);
             obj.sd_DataIndex = obj.sd_DataIndex + 1;
             %split temp sample in 4 single bytes
             tempbyte = typecast(uint32(temp),'uint8');
             
                %write Headerbyte
                obj.mySerial.writeByte(0x12);
                
                %write seperated Databytes Highbyte to Lowbyte
                
                obj.mySerial.writeByte(tempbyte(4));
                
                
                obj.mySerial.writeByte(tempbyte(3));
                
                
                obj.mySerial.writeByte(tempbyte(2));
                
                
                obj.mySerial.writeByte(tempbyte(1)); 
                
                %write CR+LF
                obj.mySerial.writeByte(0x0D);
                obj.mySerial.writeByte(0x0A);
                
              
             
             
         end       
%% EVENTLISTENER UART       
        function s_readByte(obj,~,~)
            
            obj.readProtocol;
            
        end
        
        function ReadData(obj,~,~)
            n_bytesavb = obj.mySerial.getNumBytesAvb;
            %disp(n_bytesavb);
            if n_bytesavb >0

              %disp(n_bytesavb);
              for i = 1 : n_bytesavb
                obj.readProtocol;
              end%end for
              
              %refresh Terminal and Plot after every burstread
              obj.myGui.refreshScreen;
              obj.plotSample;
            end %end if
        end%end function
        
    end%end mehtod
end%end classdef

