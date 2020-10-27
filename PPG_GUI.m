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
        Buffersize = 256;
        Buffer;
        numBytes = 0;        
        
        %SignalFiles
        signalPath = 'signaldata/Data01.mat' ;
        signalData = {};
        signalLength ;
      
        
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
                    'Position',[500,350,100,25],...
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
            
            %put Connect Messag to Outputform
            obj.txa_outputWindowText{obj.txa_outputWindowIndex} = 'Verbunden mit:';
            obj.txa_outputWindowText{obj.txa_outputWindowIndex} = strcat(obj.txa_outputWindowText{obj.txa_outputWindowIndex}, obj.dd_selPort.Value);
            
            %newline
            obj.txa_outputWindowIndex = obj.txa_outputWindowIndex + 1;
            
           
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
            if obj.SHOW_ASCII == 1 
                msgChar = char(msg);
            end
            
            % Make int32 from multiple Databytes
            if (obj.HEADER == obj.DATA_BYTE) 
                obj.tmp_Buffer = bitor(bitshift(obj.tmp_Buffer,8), msg);
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
            
                  
                if ((msg == 0x0A && obj.ASCII_CR == 1) || (obj.CR_LF_EN == 1))
                    obj.txa_outputWindowIndex = obj.txa_outputWindowIndex + 1; %New Line
                    obj.ASCII_CR = 0;   % Reset CR Flag

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
            end
            
             
            
            %write rcvd msg to messagebo screenbuffer
            if (size(obj.txa_outputWindowText) < obj.txa_outputWindowIndex)
                obj.txa_outputWindowText{obj.txa_outputWindowIndex} = msgChar;
            else
                %temp_cell_array = 
                obj.txa_outputWindowText{obj.txa_outputWindowIndex} = strcat(obj.txa_outputWindowText{obj.txa_outputWindowIndex}, msgChar);
            end
            obj.txa_outputWindow.Value = obj.txa_outputWindowText;
            
            %scroll to bottom
            scroll(obj.txa_outputWindow,'bottom');
        end
        
        function sendData(obj)
            if obj.SEND_DATA == 1
                %check for Data
                if exist(obj.signalPath,'file') == 2
                    %load signal Data from mat-file
                    obj.signalData = struct2array(load(obj.signalPath));
                    obj.signalLength = height(obj.signalData);
                    
                    %put load successfull msg to outputform
                    %put Connect Messag to Outputform
                    obj.txa_outputWindowText{obj.txa_outputWindowIndex} = obj.signalPath;
                    obj.txa_outputWindowText{obj.txa_outputWindowIndex} = strcat(' wurde geladen');

                    %newline
                    obj.txa_outputWindowIndex = obj.txa_outputWindowIndex + 1;
                    obj.txa_outputWindow.Value = obj.txa_outputWindowText;
                end
            end
        end
      
        
    end
end

