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
        
        % Buttons
        btn_cnnctPort;
        btn_dscnnctPort;
        btn_sendMsg;
        btn_sendData;
        
        % Checkboxes
        cb_showASCII;
        
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
        Buffersize = 256;
        Buffer;
        numBytes = 0;
        ASCII_ARR = {};
        NUM_ARR = {};
        
        %SignalFiles
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
                     'Position', [100 100 1000 400]);
            
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


            obj.btn_cnnctPort = uibutton(obj.fig,...
                    'Position',[230,350,100,25],...
                    'Text','Connect',...
                    'ButtonPushedFcn', @(~,~) (cnnctSerial(obj)));

            obj.btn_dscnnctPort = uibutton(obj.fig,...
                    'Position',[340,350,100,25],...
                    'Text','Disconnect',...
                    'ButtonPushedFcn', @(~,~) (dscnnctSerial(obj)));
                
            obj.cb_showASCII = uicheckbox(obj.fig,...
                            'Position',[450,350,100,25],...
                            'Text','show ASCII',...
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
                    'Position',[540,350,100,25],...
                    'Text','Send Data',...
                    'ButtonPushedFcn', @(~,~) (sendData(obj)));

                
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
                    writeline(obj.s,obj.txa_inputForm.Value);
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
            obj.NUM_ARR{1} = sprintf('%s %s',...
                str_temp, obj.dd_selPort.Value);  
           
        end
        function dscnnctSerial(obj)%,sel_Port, sel_BAUD)
            %fclose(obj.s);
            obj.s = 0;
            %Connect Button enabled again after successfull port closing
            obj.btn_cnnctPort.Enable = 1;
            obj.btn_dscnnctPort.Enable = 0;
        end
  
        function msgRCV(obj)
            msg = read(obj.s,1,"uint8");                        
               
            % Make int32 from multiple Databytes
            if (obj.HEADER == obj.DATA_BYTE) 
                obj.tmp_Buffer = bitor(bitshift(obj.tmp_Buffer,8), msg);
                obj.asc_buffer(obj.numBytes+1) = char(msg);
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
                    case 0x12
                        obj.HEADER = obj.DATA_BYTE;
                    case 0x13
                        obj.HEADER = obj.ERROR_BYTE;
                    case 0x0D
                        obj.ASCII_CR = 1;   % CR Flag = 1
                end
            end
  
            if ((msg == 0x0A && obj.ASCII_CR == 1) || (obj.CR_LF_EN == 1))
                obj.txa_outputWindowIndex = obj.txa_outputWindowIndex + 1; %New Line
                obj.ASCII_CR = 0;   % Reset CR Flag

                %plot Data
                if obj.DATA_TO_PLOT ==1
                    %shift whole array left
                    obj.Buffer = circshift(obj.Buffer,-1);
                    %overwrite last data on last array index (data filled in leftside)
                    obj.Buffer(obj.Buffersize) = obj.tmp_Buffer;
                    obj.NUM_ARR{end+1} = num2str(obj.tmp_Buffer);
                    obj.ASCII_ARR{end+1} = num2str(obj.asc_buffer);
                    
                    %increment sample counter
                    obj.n_xAxis = obj.n_xAxis + 1;
                    %reassign helpervars = 0
                    obj.DATA_TO_PLOT = 0;
                    obj.tmp_Buffer = 0;
                    obj.asc_buffer = [];

                    % call plotfunction if enabled
                    plotData(obj);
                end
            end

            if(obj.cb_showASCII.Value == 1)
                obj.txa_outputWindow.Value = obj.ASCII_ARR;
            else
                obj.txa_outputWindow.Value = obj.NUM_ARR;
            end
            
            %scroll to bottom
            scroll(obj.txa_outputWindow,'bottom');
        end
        
        function sendData(obj)
            if obj.SEND_DATA == 1
                if loadFile(obj) == 1
                    
                    %configure signal timer for fixed samplerate
                    %transmission
                    obj.signaltimer = timer('Period',1/obj.signalFs,...
                        'TasksToExecute', Inf,'ExecutionMode','fixedRate');
                    %configure timer callback
                    obj.signaltimer.TimerFcn = @(~,~) putSample(obj);
                    start(obj.signaltimer);
                    
                    obj.SEND_DATA = 0;
                    obj.btn_sendData.Text = 'Stop';
                    obj.signalDataIndex = 1;
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
                
                %write seperated Databytes Highbyte to Lowbyte
                tempbyte = uint8(bitsrl(int32(temp),24));
                write(obj.s,tempbyte,"uint8");
                
                tempbyte = uint8(bitsrl(int32(temp),16));
                write(obj.s,tempbyte,"uint8");
                
                tempbyte = uint8(bitsrl(int32(temp),8));
                write(obj.s,tempbyte,"uint8");
                
                tempbyte = uint8(bitand(int32(temp), int32(0x000000FF)));
                writeline(obj.s,char(tempbyte) );
                
                %increment Data Indice
                obj.signalDataIndex = obj.signalDataIndex + 1;
                
            end
        
        end
        
        function status = loadFile(obj)
            %check for Data
                if exist(obj.signalPath,'file') == 2
                    %load signal Data from mat-file
                    obj.signalData = struct2array(load(obj.signalPath));
                    obj.signalLength = height(obj.signalData);
                    
                    %put Load successfull Message to Outputform
                    str_temp = ' wurde geladen';
                    obj.ASCII_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.NUM_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    
                    if(obj.cb_showASCII.Value == 1)
                        obj.txa_outputWindow.Value = obj.ASCII_ARR;
                    else
                        obj.txa_outputWindow.Value = obj.NUM_ARR;
                    end
                    status = 1;
                else
                    %put Load unsuccessfull Message to Outputform
                    str_temp = ' wurde nicht gefunden';
                    obj.ASCII_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.NUM_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    
                    if(obj.cb_showASCII.Value == 1)
                        obj.txa_outputWindow.Value = obj.ASCII_ARR;
                    else
                        obj.txa_outputWindow.Value = obj.NUM_ARR;
                    end
                    status = 0;
                end
                 
        
        end
        
      
        
    end
end

