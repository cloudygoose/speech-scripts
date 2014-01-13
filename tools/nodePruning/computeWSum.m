function computeWSum(layerNum, outFile)
    fd = fopen(outFile, 'w');
    m = {}; va = {};	
    for i=2:layerNum
        sm = strcat('m', num2str(i));
	    mm{i} = load(sm);
	    me{i - 1} = sum(abs((mm{i}))) / size(mm{i}, 1);
        for j=1:size(me{i - 1}, 2)
            fprintf(fd, '%.10f ', me{i - 1}(j));
        end
        fprintf(fd, '\n');
    end
    fclose(fd);
    datFile = strcat(outFile, '.mat');
    save(datFile, 'me');
end
