function [Baud,Port] = getSerialPara(obj)

   % Port = obj.dd_selPort.Value;
    Baud = obj.dd_selBAUD.Value;
    Port = obj.dd_selPort.Value;
end

