function writeByte(obj,dataOut)
    switch obj.s_classType
        case 0
            try
                 
                fwrite(obj.s_obj,dataOut,"uint8");
            catch
                msg = 'Übertragung fehlgeschlagen';
                putMsg(obj,msg);
            end
        case 1
            try
                write(obj.s_obj,dataOut,"uint8");
            catch
                msg = 'Übertragung fehlgeschlagen';
                putMsg(obj,msg);
            end
    end
end