function boxes = runSS(im)
%%
% Run selective search on the given image.  Return back boxes larger than
% some min size.
addpath(genpath('../lib/SelectiveSearchCodeIJCV/'));
MIN_DIMENSION = 40;
MAX_DIMENSION = 180;
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{1}; % Single color space for now

% Specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};

sigma = 1;
k = 200;
minSize = 200; % controls size of segments of initial segmentation.

% Perform Selective Search
[boxes, blobIndIm, blobBoxes, hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
boxes = BoxRemoveDuplicates(boxes);
wh = boxes(:, 3:4) - boxes(:, 1:2);
keep = min(wh, [], 2) > MIN_DIMENSION;
boxes = boxes(keep, :);
wh = boxes(:, 3:4) - boxes(:, 1:2);
keep = max(wh, [], 2) < MAX_DIMENSION;
boxes = boxes(keep, :);
end
