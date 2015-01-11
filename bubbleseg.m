clear

%[comicImg, map] = imread('dilbert/2014-12-23.gif', 'gif');
%[comicImg, map] = imread('garfield/27-1-1983.gif', 'gif');
comicImg = imread('bubble_testing_images/phd1.jpg');
grayImg = rgb2gray(comicImg);

imgWidth = size(grayImg,2); imgHeight = size(grayImg,

%[comicImg, map] = imread('garfield/garfieldminusgarfield.jpg', 'jpg');

figure(10);
imshow(comicImg);

% Binarise image

bwImg = im2bw(comicImg, 0.3);

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



% Filter bounding boxes which are too big or too small
filteredBoundingBoxes = []; % [x, y]
boundingBoxCentres = [];

figure(17); imshow(bwImg);
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

figure(56);
imshow(bwImg); hold on;

filteredBoundingBoxes = filteredBoundingBoxes(filteredBoundingBoxes(:,5) == 0,:);
for i = 1:size(filteredBoundingBoxes,1)
    rectangle('Position', filteredBoundingBoxes(i,1:4));
end

% Upsample the image to improve OCR perferformance
grayImg = imresize(grayImg, 4, 'lanczos3');

% figure;
% imshow(grayImg);

% Resize the bounding boxes accordingly, and give a little bit of wriggle
% room.
filteredBoundingBoxes(:,1:4) = filteredBoundingBoxes(:,1:4) * 4;
filteredBoundingBoxes(:,1:2) = filteredBoundingBoxes(:,1:2) - 5;
filteredBoundingBoxes(:,3:4) = filteredBoundingBoxes(:,3:4) + 10;
for i = 1:size(filteredBoundingBoxes,1)
    rectangle('Position', filteredBoundingBoxes(i,1:4));
end

% Perform the OCR
txt = ocr(grayImg, filteredBoundingBoxes(:,1:4));

% Use the results of the OCR to discard boxes which don't contain text.
textBoundingBoxes = [];
for i = 1:size(txt)
    if size(txt(i).Text) > 0
        textBoundingBoxes = [textBoundingBoxes; filteredBoundingBoxes(i,:)];
    end
end

figure(32);
imshow(comicImg);
mergedBoundingBoxExists = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for i = 1:size(textBoundingBoxes,1)
    rectangle('Position', textBoundingBoxes(i,1:4));
    mergedBoundingBoxExists(textBoundingBoxes(i,6)) = 1;
end


letterBoundingBoxes = [];

figure(33);
imshow(comicImg);
for i = 1:numOriginalBoxes
    hold on;
    if mergedBoundingBoxExists.isKey(parentBoxMap(i))
        letterBoundingBoxes = [letterBoundingBoxes; copyOfFilteredBoundingBoxes(i,1:4)];
        rectangle('Position', copyOfFilteredBoundingBoxes(i,1:4)*4);
        plot(copyOfFilteredBoundingBoxes(i,1)*4, copyOfFilteredBoundingBoxes(i,2)*4, 'r+');
    end
end

size(letterBoundingBoxes)

% Reperform the OCR
txt = ocr(grayImg, textBoundingBoxes(:,1:4));
txt.Text

textBoundingBoxes = textBoundingBoxes(:,1:4);

pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
% Clear all the letters from the image
for i = 1:size(letterBoundingBoxes,1)
    bb = letterBoundingBoxes(i,:);
    x0 = bb(1); x1 = x0 + bb(3); y0 = bb(2); y1 = y0 + bb(4);
    bwImg(y0:y1,x0:x1) = 1;
end

cc = bwlabel(bwImg,4);

numBubbles = size(textBoundingBoxes, 1);
txtVec = zeros(numBubbles, 4);
for i = 1:numBubbles
    bubbleLabel = cc(yCenter,xCenter);
    bubbleIdx = find(cc == bubbleLabel);
    bubble = false(size(bwImg));
    bubble(bubbleIdx) = 1;
    boundaries = bwboundaries(bubble);
    boundary = boundaries{1};
    boundary = [boundary(:,2) boundary(:,1)];
    
    bubbleCenter = mean(boundary);
    
    if numel(bubbleIdx) > 0.2 * numel(bwImg)
        bubble_type = 'no_bubble';
    else
        
        % Check if the bubble is a thought bubble
        [centers, radii, metric] = imfindcircles(bubble,[5,20]);
        %imshow(bubble), hold on;
        %viscircles(centers, radii,'EdgeColor','b');
        %pause;
        if size(centers,1) > 10
            bubble_type = 'thought';
            bwImgCopy = bwImg;
            bwImgCopy(bubble) = 0;
            [centers, radii, metric] = imfindcircles(bwImgCopy,[5,20]);
            
            for i = 1:size(centers,1)
                centers(i,1) = fix(centers(i,1));
                centers(i,2) = fix(centers(i,2));
            end
            
            %imshow(bwImgCopy);
            %hold on;
            %plot(centers(:,1), centers(:,2), 'r*');
            %viscircles(centers, radii,'EdgeColor','b');
            
            pathCenters = [];
            lastCenter = bubbleCenter;
            while size(centers,1) > 0
                distances = zeros(size(centers,1),1);
                for i = 1:length(distances)
                    distances(i) = dist(lastCenter,centers(i,:));
                end
                [d,idx] = min(distances);
                if grayImg(fix(centers(idx,2)),fix(centers(idx,1))) < 235
                    centers(idx, :) = [];
                    continue;
                end
                d
                if d > 100
                    break;
                end
                
                pathCenters = [pathCenters; centers(idx,:)];
                lastCenter = centers(idx,:);
                centers(idx,:) = [];
            end
            
            imshow(bwImg);
            hold on;
            plot(pathCenters(:,1), pathCenters(:,2), 'r*');
            
            nCenters = size(pathCenters,1);
            last = pathCenters(nCenters,:); sndLast = pathCenters(nCenters,:);
            diff = last - sndLast;
            vec = diff / norm(diff);
            
        else
            bubble_type = 'standard';
            
            C = corner(bubble,'SensitivityFactor',0.01);
            C = sortrows(C,2);
            C = C(length(C),:);
            
            bubbleBoundary = false(size(bwImg));
            
            figure;
            imshow(bubbleBoundary);
            hold on
            
            plot(boundary(:,1), boundary(:,2), 'w', 'LineWidth', 2);
            
            distances = zeros(length(boundary),1);
            for i = 1:length(boundary)
                distances(i) = dist(C,boundary(i,:));
            end
            [~, closestIdx] = min(distances);
            closestPt = boundary(closestIdx,:);
            
            left = boundary(closestIdx:closestIdx+10,:);
            plot(left(:,1), left(:,2), 'w', 'LineWidth', 2);
            right = boundary(closestIdx:-1:closestIdx-10,:);
            plot(right(:,1), right(:,2), 'w', 'LineWidth', 2);
            leftLine = polyfit(left(:,1),left(:,2),1);
            rightLine = polyfit(right(:,1),right(:,2),1);
            
            x = linspace(closestPt(1)-10,closestPt(1)+10);
            y = polyval([leftLine(1),leftLine(2)], x);
            plot(x,y,'r','LineWidth',0.1);
            x = linspace(closestPt(1)-10,closestPt(1)+10);
            y = polyval([rightLine(1),rightLine(2)], x);
            plot(x,y,'r','LineWidth',0.1);
            
            leftAngle = atan(leftLine(1));
            rightAngle = atan(rightLine(1));
            if leftAngle < 0
                leftAngle = leftAngle + pi;
            end
            if rightAngle < 0
                rightAngle = rightAngle + pi;
            end
            
            avgAngle = (leftAngle + rightAngle)/2;
            slope = tan(avgAngle);
            intercept = closestPt(2) - closestPt(1)*slope;
            x = linspace(closestPt(1)-5,closestPt(1)+5);
            y = polyval([slope,intercept], x);
            plot(x,y,'r','LineWidth',0.1);
        end
        
        
        
    end
    
    %imshow(bwImg);
end
%}


