function state = start(obj)
            try
                start(obj.signaltimer);
                state = 1;
            catch
                state = 0;
                obj.putMsg('Timer error')
            end
end
