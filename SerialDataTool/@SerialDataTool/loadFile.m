function status = loadFile(obj)
            %check for Data
            obj.sd_path = obj.myGui.getSignalPath;
                if exist(obj.sd_path,'file') == 2
                    
                    %load signal Data from mat-file
                    obj.sd_Data = struct2array(load(obj.sd_path));
                    obj.sd_length = height(obj.sd_Data);
                    
                    %put Load successfull Message to Outputform
                    str_temp = ' wurde geladen';
                    str = sprintf('"%s" %s',...
                        obj.sd_path, str_temp); 
                    
                    obj.gui_screenMsg(str);                    
                    
                    %return 1
                    status = 1;
                else
                    %put Load unsuccessfull Message to Outputform
                    str_temp = ' wurde nicht gefunden';
                    obj.ASCII_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 
                    obj.HEX_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp);             
                    obj.NUM_ARR{end+1} = sprintf('"%s" %s',...
                        obj.signalPath, str_temp); 

                    refresh_screen(obj);
                    
                    %return 0
                    status = 0;
                end
                 
        
        end