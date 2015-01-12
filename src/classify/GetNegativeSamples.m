function [neg] = GetNegativeSamples(positiveInstances, overlapThreshold, outputFolder)
%%
% Go through labelled images and extract negatives examples by taking
% selective search boxes which don't overlap with labeled instances.
% 
% Write output to outputFolder/negative

if nargin == 3
    dirname = fullfile(outputFolder, 'negative');
    if not(exist(dirname, 'dir'));
        mkdir(dirname);
    end
end
for imEx = 1:size(positiveInstances, 2)
    %[im, map] = imread(positiveInstances(imEx).imageFilename);
    %im = ind2rgb(im, map);
    im = imread(positiveInstances(imEx).imageFilename);
    disp(positiveInstances(imEx).imageFilename)
    
    %%
    % Remove examples that heavily overlap with positive data
    b = runSS(im);
    b(:, 3:4) = b(:, 3:4) - b(:, 1:2);
    b = b(all(b, 2), :);  % Remove any rows w/ 0s
    % Change to x, y, w, h format
    b = [b(:, 2), b(:, 1), b(:, 4), b(:, 3)];
    overlapRatio = max(bboxOverlapRatio(positiveInstances(imEx).objectBoundingBoxes, b, 'Min'));
    neg = b(overlapRatio < overlapThreshold, :);
    
    if nargin == 3
        for i = 1:size(neg, 1)
            crop = im(neg(i, 2):neg(i, 2) + neg(i, 4), neg(i, 1):neg(i, 1) + neg(i, 3),:);
            
            filename = strcat(int2str(imEx), '_', int2str(i), '.jpg');
            %imwrite(imresize(crop, 2, 'bicubic'), fullfile(dirname, filename));
            imwrite(crop, fullfile(dirname, filename));
        end
    end
end
end