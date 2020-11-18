function readProtocol(obj)
    msg = obj.mySerial.readByte();
    obj.myGui.writeOnScreen(msg,'HEX');
    
    %check for Headerbyte
    if obj.F_HEADERBYTE == 0x00 %Headerbyte received before?
    switch msg
        case obj.HB_CTRL
            obj.F_HEADERBYTE = msg;
        case obj.HB_DATA
            obj.F_HEADERBYTE = msg;
        case obj.HB_ERR
            obj.F_HEADERBYTE = msg;
        otherwise 
            obj.myGui.writeOnScreen(msg,'ASCII');
        
    end%end switch
    end%end if
    
    %check for Terminator
    switch msg
        case obj.PT_CR
            obj.F_CR = 1;
        case obj.PT_LF
            %CR received before 
            if obj.F_CR == 1
                obj.F_ENDPKG = 1;
            end %end if
        otherwise %reset CR Flag if last received byte was not CR
            obj.F_CR = 0;
    end %end switch
    
    % execute protocol package end routine
    if obj.F_ENDPKG == 1
        %reset all Flags
        obj.F_CR         = 0;
        obj.F_HEADERBYTE = 0;
        obj.F_ENDPKG     = 0;
        
        %newline
        obj.myGui.newLine;
        
    end %end if
   
    
    obj.myGui.refreshScreen;
end%end function

