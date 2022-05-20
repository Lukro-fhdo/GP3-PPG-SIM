function  writelineOnScreen(obj,str)
   
    ascii = sprintf("%c",str);

    obj.ASCII_ARR = append(obj.ASCII_ARR(end),ascii);
    
    obj.HEX_ARR = append(obj.HEX_ARR(end),ascii);
    
    obj.NUM_ARR = append(obj.NUM_ARR(end),ascii);
    
end

