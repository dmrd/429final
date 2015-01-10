function showLabels(labelStructEntry)
    b = labelStructEntry.objectBoundingBoxes;
    [im, map] = imread(labelStructEntry.imageFilename{1});
    im = ind2rgb(im, map);
    rects = [b(:, 2), b(:, 1), b(:, 2) + b(:, 4), b(:, 1) + b(:, 3)];
    ShowRectsWithinImage(rects, 8, 8, im)
end