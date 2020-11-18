function msg = getMsg(obj)
%     if obj.txa_inputForm.Value ~= 0
%         msg = obj.txa_inputForm.Value;
%     end 
    msg = obj.msgToSend;
    obj.txa_inputForm.Value = '';

end

