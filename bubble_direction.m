clear

%comicImg = imread('garfield.jpg', 'jpg');
%rect = [351 6 74 21];
%comicImg = imread('garfield2.jpg', 'jpg');
%rect = [1021 13 234 21];

filename = 'bubble_testing_images/garfield3.jpg';
comicImg = imread(filename);
comicImg = imresize(comicImg,2,'bicubic');
grayImg = rgb2gray(comicImg);

figure;
imshow(comicImg);
rect = getrect;

x0 = rect(1); x1 = x0 + rect(3);
y0 = rect(2); y1 = y0 + rect(4);
xCenter = fix((x0 + x1) / 2);
yCenter = fix((y0 + y1) / 2);

bwImg = im2bw(comicImg, 0.8);
bwImg(y0:y1,x0:x1) = 1;

cc = bwlabel(bwImg,4);
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


