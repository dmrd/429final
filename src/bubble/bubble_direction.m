function [ pts thetas idxs ] = bubble_direction(comicImg, rects)

scalingFactor = 2;

comicImg = imresize(comicImg,scalingFactor,'bicubic');
rects = rects * scalingFactor;

grayImg = rgb2gray(comicImg);
bwImg = im2bw(comicImg, 0.8);
bwImg = drawTopLine(bwImg);

cc = bwlabel(bwImg,4);

%figure(12123); imshow(bwImg); hold on;
%for i = 1:size(rects,1)
%    rectangle('Position', rects(i,:), 'EdgeColor', 'red');
%end

pts = [];
thetas = [];
idxs = [];
for i = 1:size(rects,1)
    rect = rects(i,:);
    x0 = rect(1); x1 = x0 + rect(3);
    y0 = rect(2); y1 = y0 + rect(4);
    
    bbLabels = cc(y0:y1,x0:x1);
    bubbleLabel = mode(bbLabels(:));
    bubble = (cc == bubbleLabel);
    
    bubble = imfill(bubble, 'holes');    
    boundaries = bwboundaries(bubble);
    boundary = boundaries{1};
    boundary = [boundary(:,2) boundary(:,1)];
    
    bubbleCenter = mean(boundary);
    
    if sum(bubble) > 0.2 * numel(bwImg)
        bubble_type = 'no_bubble';
    else
        
        % Check if the bubble is a thought bubble
        [centers, radii, metric] = imfindcircles(bubble,[5,20]);
        %figure;
        %imshow(bubble);% hold on;
        %viscircles(centers, radii,'EdgeColor','b');
        if size(centers,1) > 10
            bwImgCopy = bwImg;
            try
                [pt, theta] = thought_bubble(bwImgCopy, bubble, grayImg, bubbleCenter);
                pts = [pts; pt];
                thetas = [thetas; theta];
                idxs = [idxs ; i];
            catch e
                %display(e);
            end
        else
            bwImgCopy = bwImg;
            try
                [pt, theta] = standard_bubble(bubble, boundary);
                pts = [pts; pt];
                thetas = [thetas; theta];
                idxs = [idxs ; i];
            catch e
                %display(e);
            end
            
        end

    end
    
end

%figure(85);
%imshow(bwImg); hold on;
for i = 1:size(pts,1)
    pt = pts(i,:);
    theta = thetas(i,:);
    pt2 = [0 0];
    pt2(1) = pt(1) + 30*cos(theta);
    pt2(2) = pt(2) + 30*sin(theta);
%    line([pt(1) pt2(1)], [pt(2) pt2(2)], 'Color', 'red', 'LineWidth', 4);
end

pts = pts ./ scalingFactor;


