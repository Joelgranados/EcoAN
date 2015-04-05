function fitToSigmoid(filename, neg, col)

    fd = fopen(filename);
    data = textscan(fd, '%s %s %s %s %s %s', 'delimiter', ',', 'Headerlines', 3);
    fclose(fd);

    signal = [];
    for i=1:size(data{1},1),
        signal(i,1) = datenum(data{1}(i), 'yyyy-mm-dd');
        signal(i,2) = str2num(data{col}{i});
    end

    x = signal(:,1);
    y = signal(:,2);
    plot(x,y);

    m = 1;
    if neg,
        m = -1;
    end;

    %f = @(p,x) p(1) + p(2) ./ (1 + exp(-(x-p(3))/p(4)));
    f = @(p,x) p(1) + (p(2)*m) ./ (1 + exp(p(3) - x*p(4)));
    init = [min(y) max(y) mean(x) 1];
    p = nlinfit(x,y,f, init);
    line(x,f(p,x),'color','r');


    % Find inflection point
    d2 = diff(diff(f(p,x)));
    [v, ind] = max(d2);
    d = datestr(x(ind));
    text(x(ind), f(p, x(ind)), d, 'Color', 'red');

end
