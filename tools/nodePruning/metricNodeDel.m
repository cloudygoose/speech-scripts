%layerNum should be number of hidden (layers + 1)
%prune the first pNum least entropy node from the entropyFile
function metricNodeDel(layerNum, entropyFile, outFile, pNum)
    load(strcat(entropyFile, '.mat'));
    entropy = [];
    for i=1:size(me, 2)
        entropy = [entropy me{i}];
    end
    [entropy, list] = sort(entropy);
    %we have layerNum-1 hidden layers
    mm = {}; vv = {};	
    for i=1:layerNum
        sm = strcat('m', num2str(i));
	    mm{i} = load(sm)
	    sv = strcat('v', num2str(i));
	    vv{i} = load(sv)
    end
    %set remainning nodes
    for i = 1:layerNum - 1
        remainNodes{i} = ones(1, size(vv{i}, 2));
    end
    look = zeros(1, layerNum);
    for i = 1:pNum
        kk = list(i);
        ll = 1;
        while (kk > size(me{ll}, 2))
            kk = kk - size(me{ll}, 2);
            ll = ll + 1;
        end
        look(1,ll) = look(1,ll)+1;
        fprintf('%d %d %d ', list(i), ll, kk);
        if (remainNodes{ll}(kk) == 0)
            fprintf('!!!!!!!Prune ERROR!!!!!!!!!!!!!!!!');
        end
        remainNodes{ll}(kk) = 0;
    end
    fprintf('\n');
    disp(look);
   %prune
    for i = 1:layerNum - 1
	    fprintf('pruning layer %d...\n', i);
        mm{i} = mm{i}(remainNodes{i} == 1, :);
        vv{i} = vv{i}(remainNodes{i} == 1);
	    mm{i + 1} = mm{i + 1}(:, remainNodes{i} == 1);
    end
    ssum = 0;
    for i=1:layerNum
        ssum = ssum + size(mm{i}, 1) * size(mm{i}, 2);
    end
    fprintf('left complexity : %d\n', ssum);
    %print
    fprintf('output to file %s...\n', outFile);
    fd = fopen(outFile, 'w');
    %disp(mm{1});
    for i = 1:layerNum
	d1 = size(mm{i}, 1); d2 = size(mm{i}, 2);
   	fprintf(fd, '<biasedlinearity> %d %d\n', d1, d2);
	fprintf(fd, 'm %d %d\n', d1, d2);
	for k = 1:d1
	    for l = 1:d2
		fprintf(fd, '%.10f ', mm{i}(k, l));
            end
	    fprintf(fd, '\n');
        end
        fprintf(fd, 'v %d ', d1);
        for k = 1:d1
            fprintf(fd, '%.10f ', vv{i}(k));
	end
	fprintf(fd, '\n');
	if (i ~= layerNum)
	    fprintf(fd, '<sigmoid> %d %d\n', d1, d1);
	else
	    fprintf(fd, '<softmax> %d %d\n', d1, d1);
	end
    end
    fclose(fd);
end
