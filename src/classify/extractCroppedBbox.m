function ims = extractCroppedBbox(labelStruct)
%%
% Given struct from trainingImageLabeler, return cropped images
ims = {};
for i = 1:size(labelStruct, 2)
    im = imread(labelStruct(i).imageFilename);
    for bId = 1:size(labelStruct(i).objectBoundingBoxes, 1)
        b = labelStruct(i).objectBoundingBoxes(bId, :);
        ims{end+1} = im(b(2):min(size(im, 1), b(2) + b(4)), b(1):min(size(im, 2), b(1) + b(3)),:);
    end
end