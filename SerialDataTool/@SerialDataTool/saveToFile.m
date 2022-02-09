function saveToFile(obj,data)
    if obj.RECORD_DATA == 1
        load(obj.rd_filename);
        tmp = [tmp;data];
        save (obj.rd_filename, 'tmp');
    end
end

