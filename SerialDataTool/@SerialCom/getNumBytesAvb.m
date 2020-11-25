function num = getNumBytesAvb(obj)
    
    switch obj.s_classType
        case 0 % serial class till 2019a
            num = obj.s_obj.BytesAvailable;
        case 1 % serialport class since 2019a
            num = obj.s_obj.NumBytesAvailable;
        otherwise                   
    end            
end

