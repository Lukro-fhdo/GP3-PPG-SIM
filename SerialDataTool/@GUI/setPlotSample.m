function setPlotSample(obj,n_xAxis)
% calculating x-achsis Label : first Data at x = 0
            obj.x = ((n_xAxis - obj.Buffersize + 1) : n_xAxis);
            
            plot(obj.ax_plot, obj.x, obj.Buffer);
            
            obj.ax_plot.XLim = [(n_xAxis - obj.Buffersize + 1) n_xAxis];
end

