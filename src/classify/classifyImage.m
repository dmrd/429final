function [boxes, labelIdx] = classifyImage(clf, im, isBOWModel)
%%
% Extract selective search boxes from an image and show result of running
% classifier across them.
boxes = runSS(im);
labelIdx = {};
for i = 1:size(boxes, 1)
    b = boxes(i, :);
    %labelIdx(i) = predict(clf, imresize(im(b(1):b(3),b(2):b(4), :), 2, 'bicubic'));
    crop = im(b(1):b(3),b(2):b(4), :);
    if isBOWModel 
        labelIdx{i} = BOWModelClassify(clf, im);
    else
        labelIdx{i} = predict(clf, crop);
    end
end

if isBOWModel
    for i = 1:length(clf.classes)
        labelIdx(strcmp(clf.classes(i), labelIdx)) = {i};
        %if strcmp(clf.classes(i), 'negative') == 0
            ShowRectsWithinImage(boxes(cell2mat(labelIdx) == i, :), 8, 8, im, clf.classes{i});
        %end
    end
else
    % This part is probably broken right now...
    %clf.Labels
    %labelIdx
    for i = 1:length(clf.Labels)
        %if strcmp(clf.Labels(i), 'negative') == 0
        %disp(clf.Labels{i})
            ShowRectsWithinImage(boxes(cell2mat(labelIdx) == i, :), 8, 8, im, clf.Labels{i});
        %end
    end
end

end