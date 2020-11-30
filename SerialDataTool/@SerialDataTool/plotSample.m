function plotSample(obj)
%shift whole array left
                    obj.Buffer = circshift(obj.Buffer,-1);
                    %overwrite last data on last array index (data filled in leftside)
                    obj.Buffer(obj.Buffersize) = obj.tmp_Buffer;                    
                    
                    %increment sample counter
                    obj.n_xAxis = obj.n_xAxis + 1;
                    %reassign helpervars = 0
                    
                    obj.tmp_Buffer = 0;

                    % call plotfunction if enabled
                    %obj.myGui.setPlotSample(obj.n_xAxis);
                    obj.x = ((obj.n_xAxis - obj.Buffersize + 1) : obj.n_xAxis);
            
                    plot(obj.myGui.ax_plot, obj.x, obj.Buffer);
            
                    obj.myGui.ax_plot.XLim = [(obj.n_xAxis - obj.Buffersize + 1) obj.n_xAxis];    
end

