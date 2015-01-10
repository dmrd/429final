clear

[comicImg, map] = imread('garfield.jpg', 'jpg');
rect = [351 6 74 21];
x0 = rect(1); x1 = x0 + rect(3);
y0 = rect(2); y1 = y0 + rect(4);
xCenter = fix((x0 + x1) / 2);
yCenter = fix((y0 + y1) / 2);


%figure;
%imshow(comicImg, map);

% Binarise image

% bwImg = im2bw(comicImg, 0.8);
% bwImg(y0:y1,x0:x1) = 1;
% 
% se = strel('disk',2,6);
% dilated = ~imdilate(~bwImg, se);
% cc = bwlabel(dilated);
% bubbleLabel = cc(yCenter,xCenter);
% insidebubble = find(cc == bubbleLabel);
% %dilated(insidebubble) = 0;
% 
% se = strel('disk',3,6);
% %imshow(dilated);

bwImg = im2bw(comicImg, 0.8);
bwImg(y0:y1,x0:x1) = 1;

cc = bwlabel(bwImg,4);
bubbleLabel = cc(yCenter,xCenter);
bubbleIdx = find(cc == bubbleLabel);
bubble = false(size(bwImg));
bubble(bubbleIdx) = 1;
C = corner(bubble,1,'SensitivityFactor', 0.01);


 %imshow(bubble);
 %hold on;
% plot(C(:,1), C(:,2), 'r*');

boundaries = bwboundaries(bubble);

bubbleBoundary = false(size(bwImg));
imshow(bubbleBoundary);
hold on

boundary = boundaries{1};
boundary = [boundary(:,2) boundary(:,1)];
plot(boundary(:,1), boundary(:,2), 'w', 'LineWidth', 2);

distances = zeros(length(boundary),1);
for i = 1:length(boundary)
    dx = C(1) - boundary(i,1);
    dy = C(2) - boundary(i,2);
    distances(i) = dx*dx + dy*dy;
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

%imshow(bwImg);
