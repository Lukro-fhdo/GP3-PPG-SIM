function recordData(obj,~,~)
    if obj.RECORD_DATA == 0
        obj.myGui.btn_recordData.Text = 'Stop Record';
        obj.rd_filename = ['recordfiles/',obj.myGui.txa_inputFileName.Value,'_', char(datetime),'.mat'];
        tmp = obj.rd_Buffer;
        save (obj.rd_filename,'tmp');
        obj.RECORD_DATA = 1;
    else
        obj.myGui.btn_recordData.Text = 'Record Data';
        obj.RECORD_DATA = 0;
    end
end