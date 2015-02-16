function signal = plotSignal(filename)

    fd = fopen(filename);
    data = textscan(fd, '%s %s', 'delimiter', ',', 'Headerlines', 2);
    fclose(fd);

    signal = [];
    for i=1:size(data{1},1),
        signal(i,1) = datenum(data{1}(i), 'yyyy-mm-dd');
        signal(i,2) = str2num(data{2}{i});
    end

    plot(signal(:,1), signal(:,2));
end
