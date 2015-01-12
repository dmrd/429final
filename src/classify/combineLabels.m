function positives = combineLabels(varargin)
%%
% Given multiple arguments exported from trainingImageLabeler, combine the
% bounding boxes for use in GetNegativeSamples and return in same struct
% format.
images = [];
for i = 1:nargin
    imNames = extractfield(varargin{i}, 'imageFilename');
    images = [images, imNames];
end
images = sort(unique(images));

n = length(images);
imageNames = cell(1, n);
bboxes = cell(1, n);
for imId = 1:n
    boxes = [];
    for label = 1:nargin
        match = arrayfun(@(x)all(strcmp(x.imageFilename, images(imId))),varargin{label});
        if sum(match) == 1  
            boxes = [boxes;varargin{label}(match).objectBoundingBoxes];
        end
    end
    bboxes{imId} = boxes;
    imageNames{imId} = images{imId};
end

positives = struct('imageFilename', imageNames, 'objectBoundingBoxes', bboxes);

end