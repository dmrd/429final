function [boxes, labelIdx] = classifyImage(clf, im)
%%
% Extract selective search boxes from an image and show result of running
% classifier across them.
boxes = runSS(im);
labelIdx = zeros(size(boxes, 1));
for i = 1:size(boxes, 1)
    b = boxes(i, :);
    labelIdx(i) = predict(clf, im(b(1):b(3),b(2):b(4), :));
end
for i = 1:size(clf.Labels)
    if strcmp(clf.Labels(i), 'negative') == 0
        ShowRectsWithinImage(boxes(labelIdx == i, :), 8, 8, im);
    end
end

end