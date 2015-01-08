clear

[comicImg, map] = imread('dilbert/2014-12-23.gif', 'gif');

figure;
imshow(comicImg, map);

% Binarise image

bwImg = im2bw(comicImg, 0.3);
imshow(bwImg)

figure(23);
imshow(bwImg);

% Create bounding boxes for the black components

CC = bwconncomp(~bwImg);
boundingBoxes = []; % [x, y, width, height]
for i = 1:size(CC.PixelIdxList, 2)
   comicImg(CC.PixelIdxList{i}) = rand * 255;
   minX = idivide(min(CC.PixelIdxList{i}), uint32(size(comicImg, 1)), 'floor');
   minY = min(mod(CC.PixelIdxList{i}, size(comicImg, 1)));
   maxX = idivide(max(CC.PixelIdxList{i}), uint32(size(comicImg, 1)), 'floor');
   maxY = max(mod(CC.PixelIdxList{i}, size(comicImg, 1)));
   boundingBoxes = [boundingBoxes; [minX, minY, maxX - minX, maxY - minY]];
end

% Display the bounding boxes
for j = 1:size(boundingBoxes, 1)
    rectangle('Position', boundingBoxes(j,:));
end

figure(24);
imshow(bwImg);

% Filter bounding boxes which are too big or too small
filteredBoundingBoxes = []; % [x, y]
boundingBoxCentres = [];
hold on;
for j = 1:size(boundingBoxes, 1)
    area = boundingBoxes(j, 3) * boundingBoxes(j, 4);
    if area > 10 & area < 200
        filteredBoundingBoxes = [filteredBoundingBoxes; boundingBoxes(j,:)];
        boundingBoxCentres = [boundingBoxCentres; [boundingBoxes(j,1) + boundingBoxes(j,3) / 2, boundingBoxes(j,2) + boundingBoxes(j,4) / 2]];
        rectangle('Position', boundingBoxes(j,:));
    end
end

hold on;
plot(boundingBoxCentres(:,1), boundingBoxCentres(:,2), 'r+');

averageBoxWidth = sum(filteredBoundingBoxes(:,3)) / size(filteredBoundingBoxes,1);
averageBoxHeight = sum(filteredBoundingBoxes(:,4)) / size(filteredBoundingBoxes,1);

mergedBoundingBoxes = [];
pairwiseDistances = pdist(boundingBoxCentres);
[sortedPairwiseDistances, indices] = sort(pairwiseDistances);
sortedPairwiseDistances = sortedPairwiseDistances(sortedPairwiseDistances < 2 * (averageBoxWidth + averageBoxHeight));
indices = indices(1:size(sortedPairwiseDistances,2))
sortedBoundingBoxes = filteredBoundingBoxes(indices,:);

%{

% Detect and extract region
mserRegions = detectMSERFeatures(comicImg, 'RegionAreaRange', [15, 500], 'ThresholdDelta', 0.5, 'MaxAreaVariation', 1);
mserRegionsPixels = cell2mat(mserRegions.PixelList);

hold on;
plot(mserRegions, 'showPixelList', true);%, 'showEllipses', false);
title('MSER regions');


% Convert MSER pixel lists to a binary mask
mserMask = false(size(comicImg));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;

% Run the edge detector
edgeMask = edge(comicImg, 'Canny');

% Find intersection between edges and MSER regions
edgeAndMSERIntersection = edgeMask & mserMask;
figure;
imshowpair(edgeMask, edgeAndMSERIntersection, 'montage');
title('Canny edges and intersection of canny edges with MSER regions');

[~, gDir] = imgradient(comicImg);
% You must specify if the text is light on dark background or vice versa
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'DarkTextOnLight');
figure;
imshow(gradientGrownEdgesMask);
title('Edges grown along gradient direction');

% Remove gradient grown edge pixels
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;

% Visualize the effect of segmentation
figure; imshowpair(mserMask, edgeEnhancedMSERMask, 'montage');
title('Original MSER regions and segmented MSER regions')

se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(edgeEnhancedMSERMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);

% Display image region corresponding to afterMorphologyMask
displayImage = comicImg;
size(displayImage)
displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
size(displayImage)
figure; imshow(displayImage, map); title('Image region under mask created by joining individual characters')

%}