function [ rects text ] = bubbleseg(comicImg)

%[comicImg, map] = imread('dilbert/2014-12-23.gif', 'gif');
%[comicImg, map] = imread('garfield/27-1-1983.gif', 'gif');
%[comicImg, map] = imread('garfield/garfieldminusgarfield.jpg', 'jpg');

%figure(10);
%imshow(comicImg, map);

comicImg = rgb2gray(comicImg);

% Binarise image

bwImg = im2bw(comicImg, 0.3);

%figure(23);
%imshow(bwImg);

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
%for j = 1:size(boundingBoxes, 1)
%    rectangle('Position', boundingBoxes(j,:));
%end

%figure(24);
%imshow(bwImg);

% Filter bounding boxes which are too big or too small
filteredBoundingBoxes = []; % [x, y]
boundingBoxCentres = [];
hold on;
for j = 1:size(boundingBoxes, 1)
    area = boundingBoxes(j, 3) * boundingBoxes(j, 4);
    if area > 10 & area < 200
        filteredBoundingBoxes = [filteredBoundingBoxes; boundingBoxes(j,:)];
        boundingBoxCentres = [boundingBoxCentres; [boundingBoxes(j,1) + boundingBoxes(j,3) / 2, boundingBoxes(j,2) + boundingBoxes(j,4) / 2]];
        %rectangle('Position', boundingBoxes(j,:));
    end
end

%hold on;
%plot(boundingBoxCentres(:,1), boundingBoxCentres(:,2), 'r+');

averageBoxWidth = sum(filteredBoundingBoxes(:,3)) / size(filteredBoundingBoxes,1);
averageBoxHeight = sum(filteredBoundingBoxes(:,4)) / size(filteredBoundingBoxes,1);

% The 5th column is merged box which each box is a part of. Zero indicates it has not
% been merged.
numOriginalBoxes = size(filteredBoundingBoxes,1);
filteredBoundingBoxes = [filteredBoundingBoxes zeros(numOriginalBoxes,1)];
filteredBoundingBoxes = [filteredBoundingBoxes [1:numOriginalBoxes]'];
numOriginalBoxes = size(filteredBoundingBoxes,1);
pairwiseDistances = pdist(boundingBoxCentres);
% convert distance vector into distance matrix
distanceMatrix = squareform(pairwiseDistances);

% Merge the bounding boxes together into paragraph bounding boxes
for i = 1:size(distanceMatrix,1)
    for j = (i+1):size(distanceMatrix,1)
        if distanceMatrix(i,j) < averageBoxWidth + averageBoxHeight
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
                currentIndex = size(filteredBoundingBoxes,1) + 1;
                filteredBoundingBoxes = [filteredBoundingBoxes; [newBox currentIndex]];
                filteredBoundingBoxes(parentOfBoxI,5) = currentIndex;
                filteredBoundingBoxes(parentOfBoxJ,5) = currentIndex;
            end
        end 
    end
end

copyOfFilteredBoundingBoxes = filteredBoundingBoxes;

parentBoxMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

for i = 1:numOriginalBoxes
    parent = i;
    while filteredBoundingBoxes(parent,5) ~= 0
        parent = filteredBoundingBoxes(parent,5);
    end
    parentBoxMap(i) = parent;
end

%figure(30);
%imshow(bwImg);

filteredBoundingBoxes = filteredBoundingBoxes(filteredBoundingBoxes(:,5) == 0,:);
%for i = 1:size(filteredBoundingBoxes,1)
%    rectangle('Position', filteredBoundingBoxes(i,1:4));
%end

% Upsample the image to improve OCR perferformance
comicImg = imresize(comicImg, 4, 'lanczos3');

%figure(31);
%imshow(comicImg);

% Resize the bounding boxes accordingly, and give a little bit of wriggle
% room.
filteredBoundingBoxes(:,1:4) = filteredBoundingBoxes(:,1:4) * 4;
filteredBoundingBoxes(:,1:2) = filteredBoundingBoxes(:,1:2) - 5;
filteredBoundingBoxes(:,3:4) = filteredBoundingBoxes(:,3:4) + 10;

% Snap to box

filteredBoundingBoxes(:, 3) = min(filteredBoundingBoxes(:, 3), size(comicImg, 2) - filteredBoundingBoxes(:, 1)); % width
filteredBoundingBoxes(:, 4) = min(filteredBoundingBoxes(:, 4), size(comicImg, 1) - filteredBoundingBoxes(:, 2)); % height
filteredBoundingBoxes(:, 1:2) = max(filteredBoundingBoxes(:, 1:2), 1);

for i = 1:size(filteredBoundingBoxes,1)
 %   rectangle('Position', filteredBoundingBoxes(i,1:4));
end

% Perform the OCR
txt = ocr(comicImg, filteredBoundingBoxes(:,1:4));

% Use the results of the OCR to discard boxes which don't contain text.
textBoundingBoxes = [];
for i = 1:size(txt)
    if size(txt(i).Text) > 0
        textBoundingBoxes = [textBoundingBoxes; filteredBoundingBoxes(i,:)];
    end
end

%figure(32);
%imshow(comicImg);
mergedBoundingBoxExists = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for i = 1:size(textBoundingBoxes,1)
%    rectangle('Position', textBoundingBoxes(i,1:4));
    mergedBoundingBoxExists(textBoundingBoxes(i,6)) = 1;
end


letterBoundingBoxes = [];

%figure(33);
%imshow(comicImg); hold on;
for i = 1:numOriginalBoxes
    hold on;
    if mergedBoundingBoxExists.isKey(parentBoxMap(i))
        letterBoundingBoxes = [letterBoundingBoxes; copyOfFilteredBoundingBoxes(i,:)];
%        rectangle('Position', copyOfFilteredBoundingBoxes(i,1:4)*4);
%        plot(copyOfFilteredBoundingBoxes(i,1)*4, copyOfFilteredBoundingBoxes(i,2)*4, 'r+');
    end
end

% Filter bounding boxes which are too big or too small
reFilteredBoundingBoxes = [];
for j = 1:size(textBoundingBoxes, 1)
    area = textBoundingBoxes(j, 3) * textBoundingBoxes(j, 4);
    if area > 1000
        reFilteredBoundingBoxes = [reFilteredBoundingBoxes; textBoundingBoxes(j,:)];
    end
end

% Reperform the OCR
comicImg = im2bw(comicImg, 0.8);
txt = ocr(comicImg, reFilteredBoundingBoxes(:,1:4));
txt.Text

text = {};
for i = 1:size(txt, 1)
    text{i} = ocrText(i).Text;
end

rects = fix(reFilteredBoundingBoxes(:,1:4) ./ 4);
