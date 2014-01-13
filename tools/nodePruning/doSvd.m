function doSvd(layerNum, rank, outFile)
    %we have layerNum-1 hidden layers
    mm = {}; vv = {};	
    for i=1:layerNum
        sm = strcat('m', num2str(i));
	    mm{i} = load(sm)
	    sv = strcat('v', num2str(i));
	    vv{i} = load(sv)
    end
    %print
    fprintf('output to file %s...\n', outFile);
    fd = fopen(outFile, 'w');
    %disp(mm{1});
    for i = 1:layerNum
        fprintf('%d ', i);
        if (i ~= 1 &&(size(mm{i}, 1) * rank + rank * size(mm{i}, 2)<size(mm{i},1)*size(mm{i},2)))
        %if (i == layerNum)
            ma = mm{i}';
            [U S V] = svd(ma);
            V = V';
            mm1 = U(:, 1:rank) * sqrt(S(1:rank, 1:rank));
            mm2 = sqrt(S(1:rank, 1:rank)) * V(1:rank, :);
            printMV(fd, mm1', zeros(rank));
            printMV(fd, mm2', vv{i});
        else
            d1 = size(mm{i}, 1); d2 = size(mm{i}, 2);
            printMV(fd, mm{i}, vv{i});
        end
        d1 = size(mm{i}, 1); d2 = size(mm{i}, 2);
        
	    if (i ~= layerNum)
	        fprintf(fd, '<sigmoid> %d %d\n', d1, d1);
    	else
	        fprintf(fd, '<softmax> %d %d\n', d1, d1);
    	end
    end
    fclose(fd);
end
function printMV(fd, m, v)
    d1 = size(m, 1); d2 = size(m, 2);
    fprintf(fd, '<biasedlinearity> %d %d\n', d1, d2);
	fprintf(fd, 'm %d %d\n', d1, d2);
	for k = 1:d1
	    for l = 1:d2
    		fprintf(fd, '%.10f ', m(k, l));
        end
	    fprintf(fd, '\n');
    end
    fprintf(fd, 'v %d ', d1);
    for k = 1:d1
        fprintf(fd, '%.10f ', v(k));
    end
	fprintf(fd, '\n');
end
