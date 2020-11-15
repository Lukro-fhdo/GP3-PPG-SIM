function close(obj)
            switch obj.s_classType
                case 0
                    fclose(obj.s_obj);
                    msg = 'Verbindung getrennt';
                    putMsg(obj,msg);
                case 1
                    obj.s_obj = [];
                    
                    msg = 'Verbindung getrennt';
                    putMsg(obj,msg);
            end
end