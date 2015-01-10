clear

%[comicImg, map] = imread('dilbert/2014-12-23.gif', 'gif');
[comicImg, map] = imread('garfield/27-1-1983.gif', 'gif');
%[comicImg, map] = imread('garfield/garfieldminusgarfield.jpg', 'jpg');

figure(10);
imshow(comicImg, map);

comicImg = rgb2gray(ind2rgb(comicImg, map));

filteredImg = medfilt2(comicImg,[3 3]);
figure(11), imshow(filteredImg)

% Binarise image

bwImg = im2bw(comicImg, 0.3);

figure(23);
imshow(bwImg);

% Create bounding boxes for the black components

CC = bwconncomp(~bwImg);
boundingBoxes = []; % [x, y, width, height]
for i = 1:size(CC.PixelIdxList, 2)
   % comicImg(CC.PixelIdxList{i}) = rand * 255;
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

% The 5th column is merged box which each box is a part of. Zero indicates it has not
% been merged.
filteredBoundingBoxes = [filteredBoundingBoxes zeros(size(filteredBoundingBoxes,1),1)];
pairwiseDistances = pdist(boundingBoxCentres);
% convert distance vector into distance matrix
distanceMatrix = squareform(pairwiseDistances);

% Merge the bounding boxes together into paragraph bounding boxes
for i = 1:size(distanceMatrix,1)
    for j = (i+1):size(distanceMatrix,1)
        if distanceMatrix(i,j) < 1.5 * (averageBoxWidth + averageBoxHeight)
            % merge boxes i and j
            parentOfBoxI = i;
            parentOfBoxJ = j;
           
            % find the biggest bounding box that the ith box has been merged
            % into
            while filteredBoundingBoxes(parentOfBoxI,5) ~= 0
                parentOfBoxI = filteredBoundingBoxes(parentOfBoxI,5);
            end
            
            % find the biggest bounding box that the jth box has been
            % merged into
            while filteredBoundingBoxes(parentOfBoxJ,5) ~= 0
                parentOfBoxJ = filteredBoundingBoxes(parentOfBoxJ,5);
            end
            
            % if the two parent bounding boxes are not the same, merge them
            % to form a new bounding box
            if parentOfBoxI ~= parentOfBoxJ
                newBox = mergeBoxes(filteredBoundingBoxes(parentOfBoxI,:), filteredBoundingBoxes(parentOfBoxJ,:));
                filteredBoundingBoxes = [filteredBoundingBoxes; newBox];
                filteredBoundingBoxes(parentOfBoxI,5) = size(filteredBoundingBoxes,1);
                filteredBoundingBoxes(parentOfBoxJ,5) = size(filteredBoundingBoxes,1);
            end
        end 
    end
end

figure(30);
imshow(bwImg);

filteredBoundingBoxes = filteredBoundingBoxes(filteredBoundingBoxes(:,5) == 0,1:4);
for i = 1:size(filteredBoundingBoxes,1)
    rectangle('Position', filteredBoundingBoxes(i,:));
end

% Upsample the image to improve OCR perferformance
comicImg = imresize(comicImg, 4, 'lanczos3');

figure(31);
imshow(comicImg);

% Resize the bounding boxes accordingly, and give a little bit of wriggle
% room.
filteredBoundingBoxes = filteredBoundingBoxes * 4;
filteredBoundingBoxes(:,1:2) = filteredBoundingBoxes(:,1:2) - 5;
filteredBoundingBoxes(:,3:4) = filteredBoundingBoxes(:,3:4) + 10;
for i = 1:size(filteredBoundingBoxes,1)
    rectangle('Position', filteredBoundingBoxes(i,:));
end

% Perform the OCR
txt = ocr(comicImg, filteredBoundingBoxes);

% Use the results of the OCR to discard boxes which don't contain text.
textBoundingBoxes = [];
for i = 1:size(txt)
    if size(txt(i).Text) > 0
        textBoundingBoxes = [textBoundingBoxes; filteredBoundingBoxes(i,:)];
    end
end

figure(32);
imshow(comicImg);
for i = 1:size(textBoundingBoxes,1)
    rectangle('Position', textBoundingBoxes(i,:));
end

% Reperform the OCR
txt = ocr(comicImg, textBoundingBoxes);
txt.Text

%comicImg(filteredBoundingBoxes(:,1):(filteredBoundingBoxes(:,1)+filteredBoundingBoxes(:,3)), filteredBoundingBoxes(:,2):(filteredBoundingBoxes(:,2)+filteredBoundingBoxes(:,4))) = 1;


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