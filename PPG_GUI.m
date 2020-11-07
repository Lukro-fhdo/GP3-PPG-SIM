classdef PPG_GUI < handle 
    %PPG-GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        s;
        fig;
        
        % GUI Elements:
        
        
        % Dropdownmenues
        dd_selPort;
        dd_selBAUD;
        dd_selSignalFile;
        dd_showASCII;
        dd_headerByte;
        
        % Buttons
        btn_cnnctPort;
        btn_dscnnctPort;
        btn_sendMsg;
        btn_sendData;
        btn_clearScreen
        
        % Checkboxes
        cb_showASCII;
        cb_showSend;
        
        % Textfields
        txa_outputWindow;
        txa_outputWindowText = {};
        txa_outputWindowIndex = 1;
        txa_inputForm;
        
        % Plotter
        ax_plot;
        n_xAxis = 0;
        x;
        
        %Data Buffer
        
        tmp_Buffer = int32(0);
        asc_buffer = [];

        hex_buffer = [];

        Buffersize = 256;
        Buffer;
        numBytes = 0;
        ASCII_ARR = {};
        HEX_ARR = {};
        NUM_ARR = {};
        
        %SignalFiles
        signalFileListing;
        signalPath = 'signaldata/Data01.mat' ;
        signalData = {};
        signalDataIndex = 1;
        signalLength ;
        signalFs = 50; %Samplefrequenz = 30Hz   
        
        signaltimer;
        
        %GUI FLAGS:
        CR_LF_EN = 0;
        PLOTTER_EN = 1;
        DATA_TO_PLOT = 0;
        SHOW_ASCII = 1;     % 1 = show BYTE as ASCII, 0 = show Numbers as charstring 
        SEND_DATA = 1;
        SHOW_OUTGOING;
        
        %COM FLAGS:
        ASCII_CR = 0;
        CTRL_BYTE = 1;
        DATA_BYTE = 2;
        ERROR_BYTE = 3;
       
        HEADER = 0;
    end
    
    methods (Access = private)
        function buildGui(obj)
            %creata GUI Figure
            obj.fig = uifigure('Name','Serialinterface - PPG Simulator',...
                     'Position', [100 100 950 400]);
            
            obj.signalFileListing = dir('signaldata/*.mat');     
                 
            % set callback for closerequest
            figure = obj.fig;
            figure.CloseRequestFcn = @(figure,event)obj.my_closereq();
           
            obj.dd_selPort = uidropdown(obj.fig,...
                    'Position',[10 350 100 25],...
                    'Items', seriallist('available'),...
                    'DropDownOpeningFcn', @(~,~) (portSelect(obj)));

            obj.dd_selBAUD = uidropdown(obj.fig,...
                    'Position',[120 350 100 25],...
                    'Items', {'9600', '56700', '115200'},...
                    'ItemsData', [9600, 56700, 115200]);

            obj.dd_showASCII = uidropdown(obj.fig,...
                    'Position',[10,315,100,25],...
                    'Items', {'DEC', 'HEX', 'ASCII'},...
                    'ItemsData', [1, 2, 3]);
                
            obj.dd_headerByte = uidropdown(obj.fig,...
                    'Position',[230,315,100,25],...
                    'Items', {'None', 'CTRL_Byte', 'DATA_Byte', 'ERR_Byte'},...
                    'ItemsData', [0x00, 0x11, 0x12,0x13]);
                
            obj.btn_clearScreen = uibutton(obj.fig,...
                    'Position',[120,315,100,25],...
                    'Text','Clear',...
                    'ButtonPushedFcn', @(~,~) (clrScreen(obj)));


            obj.btn_cnnctPort = uibutton(obj.fig,...
                    'Position',[230,350,100,25],...
                    'Text','Connect',...
                    'ButtonPushedFcn', @(~,~) (cnnctSerial(obj)));

            obj.btn_dscnnctPort = uibutton(obj.fig,...
                    'Position',[340,350,100,25],...
                    'Text','Disconnect',...
                    'ButtonPushedFcn', @(~,~) (dscnnctSerial(obj)));
                
%             obj.cb_showASCII = uicheckbox(obj.fig,...
%                             'Position',[10,315,100,25],...
%                             'Text','show ASCII',...
%                             'Value',0);
                        

                        
            obj.cb_showSend = uicheckbox(obj.fig,...
                            'Position',[520,315,150,25],...
                            'Text','show Send Data',...
                            'Value',0);            
                       

            obj.txa_outputWindow = uitextarea(obj.fig,...
                    'Position',[10, 50, 440, 250],...
                    'ValueChangedFcn', @(~,~) (txa_outScrollBtm(obj)));
                
            obj.txa_inputForm = uieditfield(obj.fig,'text',...
                    'Position', [10,10,330,25],...
                    'ValueChangedFcn', @(~,~) (sendMsgSerial(obj)));
            

            obj.btn_sendMsg = uibutton(obj.fig,...
                    'Position',[350,10,100,25],...
                    'Text','Send',...
                    'ButtonPushedFcn', @(~, ~) (sendMsgSerial(obj)));
                
            obj.btn_sendData = uibutton(obj.fig,...
                    'Position',[520,350,100,25],...
                    'Text','Send Data',...
                    'ButtonPushedFcn', @(~,~) (sendData(obj)));
                
            obj.dd_selSignalFile = uidropdown(obj.fig,...
                    'Position',[630 350 200 25],...
                    'Items', {obj.signalFileListing.name});
                
           
                

                
            obj.ax_plot = uiaxes(obj.fig,...
                    'Position', [500,50,440,250]);
                
        end
        
    end
    
    
    methods (Access = public)
        
        %% Constructor
        function obj = PPG_GUI() %PPG_GUI Construct an instance of this class
            
            close all;
                                           
            
            %build Gui on construction
            buildGui(obj);  
            
            %init Buffer
            obj.Buffer = zeros(1,obj.Buffersize);
                     
        end
        
        
        %% Memberfunctions
        
        %% GUI Callbackfunctions
        
        function my_closereq(obj)
            selection = uiconfirm(obj.fig,'Close the figure window?',...
                'Confirmation');

            switch selection
                case 'OK'

                    % close Port when figure gets closed
                    %fclose(obj.s);
                    obj.s = 0;

                    delete(obj.fig)


                case 'Cancel'
                    return
            end
        end
        
        function clrScreen(obj)
            obj.txa_outputWindow.Value = '';
        
        end
        
      
        function plotData(obj)
            % calculating x-achsis Label : first Data at x = 0
            obj.x = ((obj.n_xAxis - obj.Buffersize + 1) : obj.n_xAxis);
            
            plot(obj.ax_plot, obj.x, obj.Buffer);
            
            
            obj.ax_plot.XLim = [(obj.n_xAxis - obj.Buffersize + 1) obj.n_xAxis];
        end
                
        %% Serial COM
        
        % refresh Portselect Dropdown menu Items on click
        function portSelect(obj)
            obj.dd_selPort.Items = seriallist('available');
        end
      
        function sendMsgSerial(obj)
            %if s.status == 'open' 
                if obj.txa_inputForm.Value ~= 0
                    %fwrite(obj.s,obj.txa_inputForm.Value{1},'uint8');
                    
                    switch obj.dd_headerByte.Value
                        case 0x00
                            
                            writeline(obj.s,obj.txa_inputForm.Value);
                        case 0x11
                            write(obj.s,char(0x11),"uint8");
                            writeline(obj.s,obj.txa_inputForm.Value);
                        case 0x12
%                             write(obj.s,char(0x12),"uint8");
%                             write(obj.s,str2num(obj.txa_inputForm.Value),"int32");
%                             write(obj.s,char(0x0D),"uint8");
%                             write(obj.s,newline,"uint8");
                            temp = str2num(obj.txa_inputForm.Value);
                            %write Headerbyte
                            write(obj.s,0x12,"uint8");

                            %write seperated Databytes Highbyte to Lowbyte
                            tempbyte(1) = uint8(bitsrl(int32(temp),24));
                            write(obj.s,tempbyte(1),"uint8");

                            tempbyte(2) = uint8(bitsrl(int32(temp),16));
                            write(obj.s,tempbyte(2),"uint8");

                            tempbyte(3) = uint8(bitsrl(int32(temp),8));
                            write(obj.s,tempbyte(3),"uint8");

                            tempbyte(4) = uint8(bitand(int32(temp), int32(0x000000FF)));
                            writeline(obj.s,char(tempbyte(4)) ); % write Lowbyte + CR + LF
                        case 0x13
                    end
%                     if obj.dd_headerByte.Value ~= 0x00
%                         write(obj.s,char(obj.dd_headerByte.Value),"uint8");
%                     end
%                     writeline(obj.s,obj.txa_inputForm.Value);
                end 
                obj.txa_inputForm.Value = '';
            %end
        end

        function cnnctSerial(obj)            
            obj.s = serialport(obj.dd_selPort.Value,obj.dd_selBAUD.Value);
            %Button has to be disabled to prevent multiple portopenings
            obj.btn_cnnctPort.Enable = 0;
            obj.btn_dscnnctPort.Enable = 1;
            %fopen(obj.s);
            configureCallback(obj.s,"byte",1, @(~, ~) (msgRCV(obj)));
            configureTerminator(obj.s,"CR/LF");
            
            %put Connect Message to Outputform
            str_temp = 'Verbunden mit: ';
            obj.ASCII_ARR{1} = sprintf('%s %s',...
                str_temp, obj.dd_selPort.Value); 
            obj.HEX_ARR{1} = sprintf('%s %s',...
                str_temp, obj.dd_selPort.Value); 
            obj.NUM_ARR{1} = sprintf('%s %s',...
                str_temp, obj.dd_selPort.Value);  
           
            refresh_screen(obj);
        end
        
        function dscnnctSerial(obj)%,sel_Port, sel_BAUD)
            %fclose(obj.s);
            obj.s = 0;
            
            %stop timer if running
            timer = get(obj.signaltimer,'Running');
            if isequal(timer,'on')
                stop(obj.signaltimer);
            end
            %Connect Button enabled again after successfull port closing
            obj.btn_cnnctPort.Enable = 1;
            obj.btn_dscnnctPort.Enable = 0;
            
            % clear buffers
            obj.NUM_ARR = [];
            obj.ASCII_ARR = {};
            obj.HEX_ARR = {};
        end
  
        function msgRCV(obj)
            msg = read(obj.s,1,"uint8");
            
            if (msg ~= 0x0D) && (msg ~= 0x0A) 
                obj.asc_buffer(end+1) = char(msg);
            end
            obj.hex_buffer(end+1) = msg;

                      
            % Make int32 from multiple Databytes            
            if (obj.HEADER == obj.DATA_BYTE)                
                obj.tmp_Buffer = bitor(bitshift(obj.tmp_Buffer,8), msg);
                
                %obj.asc_buffer(end+1) = msg;
                obj.numBytes = obj.numBytes + 1;
                
                % Payload on Data max. 4 Bytes --> break
                if obj.numBytes > 3
                    %reinitialize flags to 0
                    obj.numBytes = 0;
                    obj.HEADER = 0;
                    msg = 0;
                    
                    % enable Plotting for completed data transmission
                    obj.DATA_TO_PLOT = 1;
                end
            end
            
           % Check for Protocol Data
            % Set Flags if receive byte ist Protocol startbyte
            if obj.HEADER == 0                
                switch msg 
                    case 0x11
                        obj.HEADER = obj.CTRL_BYTE;
                        obj.HEADER = 0;
                        %obj.asc_buffer(end+1) = 0x11;
                    case 0x12
                        obj.HEADER = obj.DATA_BYTE;
                        %obj.asc_buffer(end+1) = 0x12;
                    case 0x13
                        obj.HEADER = obj.ERROR_BYTE;
                        obj.HEADER = 0;
                        %obj.asc_buffer(end+1) = 0x13;
                    case 0x0D
                        obj.ASCII_CR = 1;   % CR Flag = 1
                end                
            end            
  
            if ((msg == 0x0A && obj.ASCII_CR == 1) || (obj.CR_LF_EN == 1))
                
                %obj.asc_buffer(end+1) = 0x0D;
                %obj.asc_buffer(end+1) = 0x0A;
                
                obj.NUM_ARR{end+1} = sprintf('%d', obj.tmp_Buffer); 
                
                str_bufferasc = [];
                for k = 1 : length(obj.asc_buffer)
                    str = sprintf("%s ",obj.asc_buffer(k));
                    str_bufferasc = strcat(str_bufferasc,str);
                end
                str_bufferhex = [];
                for k = 1 : length(obj.hex_buffer)
                    str = sprintf("%02X ",obj.hex_buffer(k));
                    str_bufferhex = strcat(str_bufferhex,str);
                end
                                
                obj.ASCII_ARR{end+1} = sprintf('%s',str_bufferasc);
                obj.HEX_ARR{end+1} = sprintf('%s',str_bufferhex);
                
                obj.asc_buffer = [];
                obj.hex_buffer = [];
                

                obj.ASCII_CR = 0;  % Reset CR Flag

                %plot Data
                if obj.DATA_TO_PLOT ==1
                    %shift whole array left
                    obj.Buffer = circshift(obj.Buffer,-1);
                    %overwrite last data on last array index (data filled in leftside)
                    obj.Buffer(obj.Buffersize) = obj.tmp_Buffer;                    
                    
                    %increment sample counter
                    obj.n_xAxis = obj.n_xAxis + 1;
                    %reassign helpervars = 0
                    obj.DATA_TO_PLOT = 0;
                    obj.tmp_Buffer = 0;



                    % call plotfunction if enabled
                    plotData(obj);
                end
            end

%             if(obj.cb_showASCII.Value == 1)
%                 %obj.txa_outputWindow.Value = obj.ASCII_ARR;
%                 obj.txa_outputWindow.Value = obj.HEX_ARR;
%             else
%                 obj.txa_outputWindow.Value = obj.NUM_ARR;
%             end
%             
%             
%             %scroll to bottom
%             scroll(obj.txa_outputWindow,'bottom');
            refresh_screen(obj);
            
        end
        
        function sendData(obj)
            if obj.SEND_DATA == 1
                if loadFile(obj) == 1
                    obj.SEND_DATA = 0;
                    obj.btn_sendData.Text = 'Stop';
                    obj.signalDataIndex = 1;
                    
                    %configure signal timer for fixed samplerate
                    %transmission
                    obj.signaltimer = timer('Period',1/obj.signalFs,...
                        'TasksToExecute', Inf,'ExecutionMode','fixedRate');
                    %configure timer callback
                    obj.signaltimer.TimerFcn = @(~,~) putSample(obj);
                    start(obj.signaltimer);
                    
                    
                else
                    % ToDo Error Message
                end
            else
                stop(obj.signaltimer);
                %reset button
                obj.SEND_DATA = 1;
                obj.btn_sendData.Text = 'Send Data';
            end
        end
        
        function putSample(obj)
            %check for arrayindex overflow
            if obj.signalDataIndex > obj.signalLength
                %reset transmission parameter
                stop(t);
                obj.signalDataIndex = 1;
                obj.btn_sendData.Text = 'Stop';
            else
                temp = table2array(obj.signalData(obj.signalDataIndex,1));
                %write Headerbyte
                write(obj.s,0x12,"uint8");
                
                %write seperated Databytes Highbyte to Lowbyte
                tempbyte(1) = uint8(bitsrl(int32(temp),24));
                write(obj.s,tempbyte(1),"uint8");
                
                tempbyte(2) = uint8(bitsrl(int32(temp),16));
                write(obj.s,tempbyte(2),"uint8");
                
                tempbyte(3) = uint8(bitsrl(int32(temp),8));
                write(obj.s,tempbyte(3),"uint8");
                
                tempbyte(4) = uint8(bitand(int32(temp), int32(0x000000FF)));
                writeline(obj.s,char(tempbyte(4)) ); % write Lowbyte + CR + LF
                
              
                %increment Data Indice
                obj.signalDataIndex = obj.signalDataIndex + 1;
                
                if obj.SHOW_OUTGOING == 1
                %write data to Serial Monitor
                    obj.ASCII_ARR{end+1} = sprintf('--> "%s" "%s" "%s" "%s" "%s" "%s" "%s"',...
                        0x12,tempbyte(1),tempbyte(2),tempbyte(3),tempbyte(4), 0x0D, 0x0A); 
                    obj.NUM_ARR{end+1} = sprintf('--> "%s" "%s" "%s" "%s" "%s" "%s" "%s"',...
                        0x12,tempbyte(1),tempbyte(2),tempbyte(3),tempbyte(4), 0x0D, 0x0A);
                    
%                     if(obj.cb_showASCII.Value == 1)
%                         obj.txa_outputWindow.Value = obj.ASCII_ARR;
%                     else
%                         obj.txa_outputWindow.Value = obj.NUM_ARR;
%                     
%                     end
%                     scroll(obj.txa_outputWindow,'bottom');
                    refresh_screen(obj);
                end
            end
        
        end
        
        function refresh_screen(obj)
            
            if(obj.dd_showASCII.Value == 3)

                obj.txa_outputWindow.Value = obj.ASCII_ARR;

            elseif (obj.dd_showASCII.Value == 2)

                obj.txa_outputWindow.Value = obj.HEX_ARR;

            else
                obj.txa_outputWindow.Value = obj.NUM_ARR;

            end
            scroll(obj.txa_outputWindow,'bottom');
        end
        
        function txa_outScrollBtm(obj)
            scroll(obj.txa_outputWindow,'bottom');
        end
        
        function status = loadFile(obj)
            %check for Data
            obj.signalPath = append('signaldata/',obj.dd_selSignalFile.Value);
                if exist(obj.signalPath,'file') == 2
                    %load signal Data from mat-file
                    obj.signalData = struct2array(load(obj.signalPath));
                    obj.signalLength = height(obj.signalData);
                    
                    %put Load successfull Message to Outputform
                    str_temp = ' wurde geladen';
                    obj.ASCII_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.HEX_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.NUM_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    
                    
                    
%                     if(obj.cb_showASCII.Value == 1)
%                         obj.txa_outputWindow.Value = obj.ASCII_ARR;
%                     else
%                         obj.txa_outputWindow.Value = obj.NUM_ARR;
%                     end
%                     scroll(obj.txa_outputWindow,'bottom');
                    refresh_screen(obj);
                    status = 1;
                else
                    %put Load unsuccessfull Message to Outputform
                    str_temp = ' wurde nicht gefunden';
                    obj.ASCII_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.HEX_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.NUM_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    
%                     if(obj.cb_showASCII.Value == 1)
%                         obj.txa_outputWindow.Value = obj.ASCII_ARR;
%                     else
%                         obj.txa_outputWindow.Value = obj.NUM_ARR;
%                     end
                    refresh_screen(obj);
                    status = 0;
                end
                 
        
        end
        
      
        
    end
end

