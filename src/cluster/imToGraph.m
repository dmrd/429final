function [labels, nodes, edges] = imToGraph(im, maxSegSize)
if (size(im, 3) > 1)
    im = rgb2gray(im);
end

segmented = segmentation(im, 4, 'pso');
labels = label(segmented);
stats = regionprops(labels, 'Area');
labels(~ismember(labels, find([stats.Area] < maxSegSize))) = 0;
[nodes, edges] = imRAG(labels);
end