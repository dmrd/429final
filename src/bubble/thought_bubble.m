function [ pt, angle ] = thought_bubble( bwImg, bubble, grayImg, startCenter )

bwImg(bubble) = 0;
[centers, ~, ~] = imfindcircles(bwImg,[5,20]);

for i = 1:size(centers,1)
    centers(i,1) = fix(centers(i,1));
    centers(i,2) = fix(centers(i,2));
end

%imshow(bwImgCopy);
%hold on;
%plot(centers(:,1), centers(:,2), 'r*');
%viscircles(centers, radii,'EdgeColor','b');

pathCenters = [startCenter];
lastCenter = startCenter;
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
    if d > 100
        break;
    end
    
    pathCenters = [pathCenters; centers(idx,:)];
    lastCenter = centers(idx,:);
    centers(idx,:) = [];
end

%imshow(bwImg);
%hold on;
%plot(pathCenters(:,1), pathCenters(:,2), 'r*');

nCenters = size(pathCenters,1);
assert(nCenters > 1);    

last = pathCenters(nCenters,:); sndLast = pathCenters(nCenters-1,:);
diff = last - sndLast;

[angle, ~] = cart2pol(diff(1), diff(2));
pt = last;

end

