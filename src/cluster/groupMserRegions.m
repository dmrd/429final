function inside = groupMserRegions(im, regions, xp, yp, mSize)
figure;imshow(im); hold on;
[xp, yp] = ginput(1);
inside = getOverlappingRegions(regions, [xp, yp], mSize);
plot(regions(inside), 'showPixelList', true, 'showEllipses', true);
%bboxes = arrayfun(@x(x) ellipseBbox(x.Location(1), x.Location(2), ...
%    x.Axes(1), x.Axes(2), x.Orientation), regions(inside));

end

function containing = getOverlappingRegions(regions, pixel, mSize)
%%
% Take list of regions and a pixel (x,y), return set of regions that overlap it
%x, y = pixel
containing = arrayfun(@(x) insideEllipse(pixel(1), pixel(2), ...
    x.Location(1), x.Location(2), x.Axes(1), x.Axes(2), x.Orientation), regions);
containing(max(regions.Axes, [], 2) > mSize) = 0;
end

function inside = insideEllipse(xp, yp, x, y, d, D, angle)
% Test if [xp, yp] is inside ellipse
% From https://stackoverflow.com/questions/7946187/point-and-ellipse-rotated-position-test-algorithm
cosa = cos(angle);
sina = sin(angle);
dd = d * d / 4;
DD = D * D / 4;

a = (cosa * (xp - x) + sina * (yp - y))^2;
b = (sina * (xp - x) - cosa * (yp - y))^2;
ellipse = (a / dd) + (b / DD);
inside = ellipse <= 1;
end

function bbox = ellipseBbox(x, y, D, d, angle)
    %% Return approximate bbox in [minX, minY, maxX, maxY] format
    % D is major axis
    xc = max(abs(D * cos(angle)), abs(d * cos(pi - angle)))
    yc = max(abs(D * sin(angle)), abs(d * sin(pi - angle)))
    bbox = [x - xc, y - yc, x + xc, y + yc]
end