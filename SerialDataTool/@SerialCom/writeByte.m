function writeByte(obj)
    switch obj.s_classType
        case 0
            try
                fwrite(obj.s_obj,1,"uint8");
            catch
                msg = 'Übertragung fehlgeschlagen';
                putMsg(obj,msg);
            end
        case 1
            try
                write(obj.s_obj,1,"uint8");
            catch
                msg = 'Übertragung fehlgeschlagen';
                putMsg(obj,msg);
            end
    end
end