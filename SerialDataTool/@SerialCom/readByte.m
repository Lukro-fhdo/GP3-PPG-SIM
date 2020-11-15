function dataIn = readByte(obj)
    switch obj.s_classType
        case 0
            try
                dataIn = fread(obj.s_obj,1,"uint8");
            catch
                msg = 'Fehler beim Auslesen der Schnittstelle';
                putMsg(obj,msg);
            end
        case 1
            try
                dataIn = read(obj.s_obj,1,"uint8");
            catch
                msg = 'Fehler beim Auslesen der Schnittstelle';
                putMsg(obj,msg);
            end
    end
end