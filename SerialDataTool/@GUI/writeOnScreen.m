function  writeOnScreen(obj,byte,base)

    % check for input argument count
    switch nargin 
        case 3 % if specified onl one base is written to screenbuffer
            switch base
                case 'HEX'
                    hex = sprintf(" 0x%02X ,",byte);
                    obj.HEX_ARR(end) = append(obj.HEX_ARR(end),hex);
                case 'DEC'
                    dec = sprintf("%d",byte);
                    obj.NUM_ARR(end) = append(obj.NUM_ARR(end),dec);
                case 'ASCII' 
                    ascii = sprintf("%c",byte);
                    obj.ASCII_ARR(end) = append(obj.ASCII_ARR(end),ascii);
            end
        case 2 % if not spezified string is written to all screenbuffer
            hex = sprintf("%02X  ",byte);
            dec = sprintf("%d",byte);
            ascii = sprintf("%c",byte);
            
            obj.HEX_ARR = append(obj.HEX_ARR(end),hex);
            obj.NUM_ARR = append(obj.NUM_ARR(end),dec);
            obj.ASCII_ARR = append(obj.ASCII_ARR(end),ascii);
            
        
        otherwise
    end
   
end

