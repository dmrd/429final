function [connectedComponents, nodes, adj] = mserToGraph(im, mser)
%% Given an image and mser segmentation

%labeled = imToMserRegions(im);
%[nodes, adj] = imRAG(labeled);
%return;

    f = fspecial('average',5);
    %# Filter it
    im = imfilter(im, f,'same');
%% Old solution that didn't work =(
labeled = zeros(size(im, 1), size(im, 2));
sizes = zeros(length(mser), 2);
for i = 1:length(mser)
    sizes(i, 2) = i;
    sizes(i, 1) = length(mser(i).PixelList);
end
% Place mser regions in descending order
sizes = sortrows(sizes, [-2, 1]);
for i = 1:length(mser)
    regionPix = mser(sizes(i, 2)).PixelList;
    labeled(sub2ind(size(labeled), regionPix(:, 2), regionPix(:, 1))) = i;
end
connectedComponents = label(labeled);
[nodes, adj] = imRAG(connectedComponents);
end