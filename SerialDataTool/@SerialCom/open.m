function state = open(obj)
    switch obj.s_classType
        case 0 % serial class till 2019a
            %try
                obj.s_obj = serial(obj.s_port,'BaudRate',...
                                        obj.s_baud,'Terminator','CR/LF');

                obj.s_obj.BytesAvailableFcnCount = 1;
                obj.s_obj.BytesAvailableFcnMode = 'byte';
                obj.s_obj.BytesAvailableFcn = @obj.BytesAvailableCBF;

                fopen(obj.s_obj);
                
                state = 1;
                
                msg = 'Verbindung erfolgreich';
                putMsg(obj,msg);
                
                
%             catch
%                 state = 0;
%                 msg = 'Verbindung fehlgeschlagen'; 
%                 putMsg(obj,msg);  
%             end
           
                        
        case 1 % serialport class since 2019a
            try
               obj.s_obj = serialport(obj.s_port,obj.s_baud);
               configureCallback(obj.s_obj,"Byte",1,@obj.BytesAvailableCBF)

               state = 1;
               
               msg = 'Verbindung erfolgreich';
               putMsg(obj,msg);
            catch
               state = 0;
               msg = 'Verbindung fehlgeschlagen'; 
               putMsg(obj,msg);
            end
        otherwise                   
    end            
end