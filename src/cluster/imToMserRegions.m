function result = imToMserRegions(im)
%%
% Takes forever, but it works.  Also took forever to arrive at this solution =(
    if size(im, 3) > 1
        im = rgb2gray(im);
    end
    
    f = fspecial('average',3);
    %# Filter it
    im = imfilter(im, f,'same');

    regions = detectMSERFeatures(im, 'RegionAreaRange', [50, 1000], 'ThresholdDelta', 2);
    
    figure('Visible', 'off');
    axis off;set(gca, 'xtick', []);
    imshow(im * 0); hold on;
    plot(regions,'showPixelList', true, 'showEllipses', false);
    

    F = getframe;
    [colored, Map] = frame2im(F);
    result = colored;
    figure('Visible', 'on');
    %[result, Map] = cmunique(colored);
    %result(result == 1) = NaN;
    
    %result = label(result);
    %result = rgb2gray(X);
    %result = label(rgb2gray(X))
end