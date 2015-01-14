function [colors, hogWords] = clusterImages(ims, colors, hogCenters, nClusters)
    addpath(genpath('../lib/vlfeat-0.9.19/'));
    colors = cell2mat(cellfun(@(x) rgbhist(x, colors, 2), ims, 'UniformOutput', false))';
    
    
    hog = cellfun(@(x) getHog(x), ims, 'UniformOutput', false);
    allHog = cell2mat(hog(:));
    hogSample = allHog(randsample(1:length(allHog), length(allHog)/2), :);
    centers = vl_kmeans(hogSample', hogCenters);
    kdtree = vl_kdtreebuild(centers);
    hogWords = cellfun(@(x) vladHog(x, kdtree, centers), hog, 'UniformOutput', false);
    
    %return
    %idx = kmeans(colors, nClusters);
    %size(colors)
    %[dists, idx] = kmeans(colors', nClusters);
    [dists, idx] = kmeans(cell2mat(hogWords), nClusters);
    for i = 1:nClusters
        ShowImageCell(ims(idx == i), 8, 8)
    end
    
end

function hog = getHog(im)
    hog = vl_phow(single(im), 'Color', 'opponent');
    hog = hog(:);
    return
    if size(im, 3) > 1
        gray = rgb2gray(im);
    else
        gray = im;
    end
    points = detectSURFFeatures(gray);
    hog = extractHOGFeatures(im, points);
end

function enc = vladHog(hog, kdtree, centers)
    nn = vl_kdtreequery(kdtree, centers, hog');
    assignments = zeros(size(centers, 2), size(hog, 1));  % # number centers, number HOG features
    assignments(sub2ind(size(assignments), nn, 1:length(nn))) = 1;
    
    enc = vl_vlad(single(hog'), single(centers), single(assignments));
end