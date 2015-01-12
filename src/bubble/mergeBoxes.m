function mergedBox = mergeBoxes(box1, box2)
    minX = box1(1);
    minY = box1(2);
    maxX = box1(1) + box1(3);
    maxY = box1(2) + box1(4);
    if box2(1) < minX
        minX = box2(1);
    end
    if box2(2) < minY
        minY = box2(2);
    end
    if box2(1) + box2(3) > maxX
        maxX = box2(1) + box2(3);
    end
    if box2(2) + box2(4) > maxY
        maxY = box2(2) + box2(4);
    end
    mergedBox = [minX, minY, maxX - minX, maxY - minY, 0];
end