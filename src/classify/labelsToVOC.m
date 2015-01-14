function x = labelsToVOC(outDir, classNames, varargin)
%%
% Given multiple arguments exported from trainingImageLabeler and the names, combine the
% bounding boxes for use in GetNegativeSamples and export to VOC2012 format
% Example usage: labelsToVOC('./xml/', {'dilbert', 'dogbert'}, dilbert, dogbert)
images = [];
for i = 1:length(varargin)
    imNames = extractfield(varargin{i}, 'imageFilename');
    images = [images, imNames];
end
images = sort(unique(images));
x = images;
%return
n = length(images);
for imId = 1:n
    %%
    % Hacky XML printing
    [path, imageName, extension] = fileparts(images{imId});
    fid = fopen(fullfile(outDir, [imNames{imId}(1:end-4) '.xml']), 'w');
    fprintf(fid, '<annotation>\n');
    printField(fid, 'folder', 'VOC2012');
    printField(fid, 'filename', [imageName extension]);
    im = imread(images{imId});
    fprintf(fid, '<size>\n');
    printField(fid, 'width', int2str(size(im, 2)));
    printField(fid, 'height', int2str(size(im, 1)));
    printField(fid, 'depth', int2str(size(im, 3)));
    fprintf(fid, '</size>\n');
    fprintf(fid, ['<source>' ...
		'<database>The VOC2012 Database</database>' ...
		'<annotation>PASCAL VOC2012</annotation>' ...
		'<image>flickr</image>' ...
	'</source>\n']);
    fprintf(fid, '<segmented>0</segmented>\n');
    boxCellId = 1;
    for label = 1:length(varargin)
        match = arrayfun(@(x)all(strcmp(x.imageFilename, images(imId))),varargin{label});
        if sum(match) == 1
            boxes = varargin{label}(match).objectBoundingBoxes;
            for boxId = 1:size(boxes, 1)
                fprintf(fid, '<object>\n');
                printField(fid, 'name', classNames{label});
                fprintf(fid, '<bndbox>\n');
                printField(fid, 'xmin', int2str(boxes(boxId, 1)));
                printField(fid, 'ymin', int2str(boxes(boxId, 2)));
                printField(fid, 'xmax', int2str(boxes(boxId, 1) + boxes(boxId, 3)));
                printField(fid, 'ymax', int2str(boxes(boxId, 2) + boxes(boxId, 4)));
                fprintf(fid, '</bndbox>\n');
                fprintf(fid, '</object>\n');
            end
        end
    end
    fprintf(fid, '</annotation>\n');
    fclose(fid);
end





end

function printField(fid, name, value)
    fprintf(fid, ['<' name '>' value '</' name '>\n']);
end