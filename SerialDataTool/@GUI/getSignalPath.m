function path = getSignalPath(obj)

    obj.signalPath = append('signaldata/',obj.dd_selSignalFile.Value);
    path = obj.signalPath;
end

