function  writeOnScreen(obj,byte)
    
    dec = sprintf("%d",byte);
    hex = sprintf("%02X",byte);
    ascii = sprintf("%c",byte);

    obj.ASCII_ARR(end) = append(obj.ASCII_ARR(end),ascii);
    
    obj.HEX_ARR(end) = append(obj.HEX_ARR(end),hex);
    
    obj.NUM_ARR(end) = append(obj.NUM_ARR(end),dec);
    
end

