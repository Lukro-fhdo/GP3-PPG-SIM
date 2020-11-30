function state = startTimer(obj)
            %try
                start(obj.signalTimer);
                state = 1;
%             catch
%                 state = 0;
%                 obj.putMsg('Timer error')
%             end
end
