function [ pt, angle ] = standard_bubble( bubble, boundary )

C = corner(bubble,'SensitivityFactor',0.01);
C = sortrows(C,2);
C = C(length(C),:);

bubbleBoundary = false(size(bubble));

%figure;
%imshow(bubbleBoundary);
%hold on

%plot(boundary(:,1), boundary(:,2), 'w', 'LineWidth', 2);

distances = zeros(length(boundary),1);
for i = 1:length(boundary)
    distances(i) = norm(C - boundary(i,:));
end
[~, closestIdx] = min(distances);
closestPt = boundary(closestIdx,:);

ptsNearCorner = [boundary(closestIdx-15:closestIdx-1, :) ; ...
                 boundary(closestIdx+1:closestIdx+15, :) ];
%plot(ptsNearCorner(:,1), ptsNearCorner(:,2), '*r');

thetas = zeros(size(ptsNearCorner,1),1);
for i = 1:size(ptsNearCorner,1)
    ptDiff = ptsNearCorner(i,:) - closestPt;
    [theta, ~] = cart2pol(ptDiff(1), ptDiff(2));
    thetas(i) = theta;
end

angle = median(thetas) - pi;
pt = closestPt;

% left = boundary(closestIdx:closestIdx+10,:);
% plot(left(:,1), left(:,2), 'w', 'LineWidth', 2);
% right = boundary(closestIdx:-1:closestIdx-10,:);
% plot(right(:,1), right(:,2), 'w', 'LineWidth', 2);
% leftLine = polyfit(left(:,1),left(:,2),1);
% rightLine = polyfit(right(:,1),right(:,2),1);
% 
% x = linspace(closestPt(1)-10,closestPt(1)+10);
% y = polyval([leftLine(1),leftLine(2)], x);
% plot(x,y,'r','LineWidth',0.1);
% x = linspace(closestPt(1)-10,closestPt(1)+10);
% y = polyval([rightLine(1),rightLine(2)], x);
% plot(x,y,'r','LineWidth',0.1);
% 
% leftAngle = atan(leftLine(1));
% rightAngle = atan(rightLine(1));
% if leftAngle < 0
%     leftAngle = leftAngle + pi;
% end
% if rightAngle < 0
%     rightAngle = rightAngle + pi;
% end
% 
% avgAngle = (leftAngle + rightAngle)/2;
% slope = tan(avgAngle);
% intercept = closestPt(2) - closestPt(1)*slope;
% x = linspace(closestPt(1)-5,closestPt(1)+5);
% y = polyval([slope,intercept], x);
% plot(x,y,'r','LineWidth',0.1);



end