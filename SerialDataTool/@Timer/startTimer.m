function state = startTimer(obj)
            %try
                start(obj.signalTimer);
                obj.state =1;
                state = 1;
%             catch
%                 state = 0;
%                 obj.putMsg('Timer error')
%             end
end
