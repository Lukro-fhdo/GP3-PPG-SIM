classdef GUI < handle 
    %PPG-GUI Summary of this class goes here
    %   Detailed explanation goes here
    properties
        % figure
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
        Buffersize = 256;
        Buffer;
        x;
        
        %Data Buffer
        ASCII_ARR ="";
        HEX_ARR = "";
        NUM_ARR = "";
        
        %SignalFiles
        signalFileListing;
        signalPath = '' ;
        signalData = {};
        signalDataIndex = 1;
        signalLength ;
        
        %GUI FLAGS:
        CR_LF_EN = 0;
        PLOTTER_EN = 1;
        DATA_TO_PLOT = 0;
        SHOW_ASCII = 1;     % 1 = show BYTE as ASCII, 0 = show Numbers as charstring 
        SEND_DATA = 1;
        SHOW_OUTGOING;
        
%         %COM FLAGS:
%         ASCII_CR = 0;
%         CTRL_BYTE = 1;
%         DATA_BYTE = 2;
%         ERROR_BYTE = 3;
%         HEADER = 0;
    end
    properties
        msgToSend = 0;
    end
    
%% Events    
    events
        evt_dd_portSelectFcn;
        evt_btn_clearScreenFcn;
        evt_btn_connectSerialFcn;
        evt_btn_disconnectSerialFcn;
        evt_btn_sendMsgFcn;
        evt_btn_sendDateFcn;
    end

    methods (Access = public)
        
%% Constructor

        function obj = GUI() %PPG_GUI Construct an instance of this class

            %build Gui on construction
            buildGUI(obj);  
            
            %init Buffer
            obj.Buffer = zeros(1,obj.Buffersize);
                     
        end
        
%% GUI Callbackfunctions
        
        function my_closereq(obj)
            selection = uiconfirm(obj.fig,'Close the figure window?',...
                'Confirmation');

            switch selection
                case 'OK'

                    delete(obj.fig)
% ----> call destructor for upper class                    

                case 'Cancel'
                    return
            end
        end
        
        function evt_dd_portSelectCBF(obj,~,~)
            notify(obj,'evt_dd_portSelectFcn');            
        end
        
        function evt_dd_showAsciiCBF(obj,~,~)
            refreshScreen(obj);           
        end
        
        function evt_btn_clearScreenCBF(obj,~,~)
            obj.clearScreen;  
        end
        
        function evt_btn_connectSerialCBF(obj,~,~)
            notify(obj,'evt_btn_connectSerialFcn');
        end
        
        function evt_btn_disconnectSerialCBF(obj,~,~)
            notify(obj,'evt_btn_disconnectSerialFcn');
        end
        
        function evt_btn_sendMsgCBF(obj,~,~)
            obj.msgToSend = obj.txa_inputForm.Value;
            notify(obj,'evt_btn_sendMsgFcn');
        end
        
        function evt_btn_sendDateCBF(obj,~,~)
            notify(obj,'evt_btn_sendDateFcn');
        end
        setPlotSample(obj,n_xAxis)
%         showConnected(obj);
%         showDisconnected(obj);
%         
%         msg = getMsg(obj);
%         headerbyte = getHeaderbyte(obj);
%         
%         writeOnScreen(obj,byte,base)
%         writelineOnScreen(obj,str)
%         newLine(obj);
%         
%         refreshScreen(obj);        
%         clearScreen(obj);
    end
end
