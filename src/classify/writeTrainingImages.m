function writeTrainingImages(labelStruct, baseDir, name)
%%
% Given struct from trainingImageLabeler, write cropped images (and flipped
% across x axis) to baseDir/name

dirname = fullfile(baseDir, name);
if not(exist(dirname, 'dir'))
    mkdir(dirname);
end
for i = 1:size(labelStruct, 2)
    %[im, map] = imread(labelStruct(i).imageFilename);
    %im = ind2rgb(im, map);
    im = imread(labelStruct(i).imageFilename);
    for bId = 1:size(labelStruct(i).objectBoundingBoxes, 1)
        b = labelStruct(i).objectBoundingBoxes(bId, :);
        crop = im(b(2):min(size(im, 1), b(2) + b(4)), b(1):min(size(im, 2), b(1) + b(3)),:);
        filename = strcat(int2str(i), '_', int2str(bId));
        imwrite(crop, fullfile(dirname, strcat(filename, 'o.jpg')));
        imwrite(fliplr(crop), fullfile(dirname, strcat(filename, 'f.jpg')));
    end
end