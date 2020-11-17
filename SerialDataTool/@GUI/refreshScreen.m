function refreshScreen(obj)
            
    if(obj.dd_showASCII.Value == 3)

        obj.txa_outputWindow.Value = obj.ASCII_ARR;

    elseif (obj.dd_showASCII.Value == 2)

        obj.txa_outputWindow.Value = obj.HEX_ARR;

    else
        obj.txa_outputWindow.Value = obj.NUM_ARR;

    end
    scroll(obj.txa_outputWindow,'bottom');
end