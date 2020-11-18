function  writelineOnScreen(obj,str)
   
    ascii = sprintf("%c",str);

    obj.ASCII_ARR(end) = append(obj.ASCII_ARR(end),ascii);
    
    obj.HEX_ARR(end) = append(obj.HEX_ARR(end),ascii);
    
    obj.NUM_ARR(end) = append(obj.NUM_ARR(end),ascii);
    
end

