function clusterImages(ims, k, colors)
    colors = cell2mat(cellfun(@(x) rgbhist(x, colors, 2), ims, 'UniformOutput', false))';
    idx = kmeans(colors, k);
    % TODO: OTHER TYPES OF FEATURES!  DETECT HARRIS/SURF, EXTRACT HOG.
    % Color descriptors?
    for i = 1:k
        ShowImageCell(ims(idx == i), 8, 8)
    end
end