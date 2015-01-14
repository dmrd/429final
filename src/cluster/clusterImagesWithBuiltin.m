function encoded = clusterImagesWithBuiltin(cacheDir, ims, numClusters)
    
    prefix = randString(5);
    mkdir(cacheDir, prefix);
    mkdir(fullfile(cacheDir, prefix), 'train');
    
    for i = 1:length(ims)
        if rand() < 0.9 % Write a subset to avoid training on everything
        % png to avoid compression
        filename = fullfile(cacheDir, prefix, 'train', [int2str(i) '.png']);
        imwrite(ims{i}, filename);
        end
    end
    bag = bagOfFeatures(imageSet(fullfile(cacheDir, prefix), 'recursive'), ...
        'PointSelection', 'Detector');

    %encoded = cellfun(@(x) bag.encode(x), ims, 'UniformOutput', false)';
    fprintf(1, 'Encoding images...\n');
    encoded = cell2mat(cellfun(@(x) bag.encode(x), ims, 'UniformOutput', false)');
    
    fprintf(1, 'Clustering images...\n');
    idx = kmeans(encoded, numClusters, 'Replicates', 5);
    %idx = spcl(encoded, numClusters, 5, 'kmean', [2, 2]);
    
    fprintf(1, 'Displaying clusters...\n');
    for i = 1:numClusters
        ShowImageCell(ims(idx == i), 8, 8)
    end
    
    %hog = cellfun(@(x) getHog(x), ims, 'UniformOutput', false);
    %return;
end

function ret = randString(len)
    s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    numRands = length(s); 
    %specify length of random string to generate
    ret = s( round(rand(1,len)*numRands) )
end