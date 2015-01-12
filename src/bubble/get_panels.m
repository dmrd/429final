function [ rects ] = get_panels( comicImg )

grayImg = rgb2gray(comicImg);
grayImg = imresize(grayImg,2,'bicubic');
regions = detectMSERFeatures(grayImg, 'RegionAreaRange', [10000,1000000]);

figure(221);
imshow(grayImg); hold on;
plot(regions, 'showPixelList', true, 'showEllipses', false);

panels = [];
for i = 1:regions.Count
    rgn = regions(i);
    if size(rgn.PixelList, 1) > 1000
        pxList = rgn.PixelList;
        xmin = min(pxList(:,2));
        ymin = min(pxList(:,1));
        xmax = max(pxList(:,2));
        ymax = max(pxList(:,1));
        w = xmax - xmin;
        h = ymax - ymin;
        panels = [panels ; [xmin ymin w h]];
    end
end

panels

figure(222);
imshow(grayImg); hold on;
for i = 1:size(panels,1)
    rectangle('Position', panels(i,:), 'EdgeColor', 'r');
end

end

