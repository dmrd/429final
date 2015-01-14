function clusterImagesWithLib(cacheDir, name, ims)
%%
% Currently broken, but seems to not be much reason to use over vl_feat
% approach
    addpath(genpath('./feature-extraction'));
    filenames = {}
    if ~exist(prefix)
        prefix = randString(5);
    for i = 1:length(ims)
        % png to avoid compression
        filename = fullfile(cacheDir, [prefix '_' int2str(i) '.png'])
        imwrite(ims{i}, filename);
        filenames{end + 1} = filename;
    end
    datasets_feature({name}, {filenames}, {}, 'color', conf());
    datasets_feature({name}, {filenames}, {}, 'hog2x2', conf());
    end
    
    
    %colors = cell2mat(cellfun(@(x) rgbhist(x, colors, 2), ims, 'UniformOutput', false))';
    
    %idx = kmeans(colors, k);
    %idx = kmeans(colors, k);
    for i = 1:k
        ShowImageCell(ims(idx == i), 8, 8)
    end
    
    %hog = cellfun(@(x) getHog(x), ims, 'UniformOutput', false);
    %return;
end

function hog = getHog(im)
    if size(im, 3) > 1
        gray = rgb2gray(im);
    else
        gray = im;
    end
    points = detectSURFFeatures(gray);
    hog = extractHOGFeatures(im, points);
end

function ret = randString(len)
    s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    numRands = length(s); 
    %specify length of random string to generate
    ret = s( round(rand(1,len)*numRands) )
end