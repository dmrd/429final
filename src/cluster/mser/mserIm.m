function mserIm(im, minAx, maxAx)
    if size(im, 3) > 1
        im = rgb2gray(im);
    end
    regions = detectMSERFeatures(im, 'RegionAreaRange', [30, 100000]);
    imshow(im); hold on;
    smallEnough = max(regions.Axes, [], 2) < maxAx;
    largeEnough = max(regions.Axes, [], 2) > minAx;
    %regions = regions(largeEnough);
    regions = regions((smallEnough + largeEnough) == 2);
    plot(regions,'showPixelList', true, 'showEllipses', false);
end