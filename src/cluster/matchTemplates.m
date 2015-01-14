function boxes = matchTemplates(im, templates)
%%
% Match SURF features and get clusters
if size(im, 3) > 1
    %im = im(:, :, channel);
    im = rgb2gray(im);
end

matches = cell2mat(cellfun(@(x) matchTemplate(im, x), templates, 'UniformOutput', false)');
imshow(im);hold on;scatter(matches(:, 1), matches(:, 2))
%boxes = boxesByDilation(matches, 20, 5000);
boxes = boxesByClusters(im, matches);
end

function boxes = boxesByClusters(im, matches)
clusters = fitCenters(matches, 6);
n = max(clusters);
boxes = {};
for i = 1:n
    p = matches(clusters == i, :);
    xmin = min(p(:, 1));
    ymin = min(p(:, 2));
    xmax = max(p(:, 1));
    ymax = max(p(:, 2));
    w = xmax - xmin;
    h = ymax - ymin;
    if min(w, h) < 10
        continue;
    end
    boxes{end + 1} = [xmin, ymin, w, h];
    rectangle('Position', [xmin, ymin, w, h]);
end
boxes = cell2mat(boxes');
end

%20, 5000
function boxes = boxesByDilation(matches, dilateBy, threshold)

pointMap = zeros(size(im, 1), size(im, 2));
dilated = imdilate(pointMap, strel('square', dilateBy));
STATS = regionprops(dilated);
boxes = [STATS([STATS.Area] > threshold).BoundingBox]
end


function clusters = fitCenters(points, maxN)
AIC = Inf * ones(1,maxN);
GMModels = cell(1,maxN);
options = statset('MaxIter',500);
for k = 1:maxN
    try
        GMModels{k} = fitgmdist(points,k,'SharedCovariance',true, 'Replicates', 10);
        AIC(k)= GMModels{k}.AIC;
    catch
        break
    end
end
try
    [minAIC,numComponents] = min(AIC);
    BestModel = GMModels{numComponents};
    clusters = cluster(BestModel, points);
catch
    return
end

end

function points = matchTemplate(im, template)
if size(template, 3) > 1
    template = rgb2gray(template);
end

p1 = detectSURFFeatures(im);
p2 = detectSURFFeatures(template);

[f1, vpts1] = extractFeatures(im, p1);
[f2, vpts2] = extractFeatures(template, p2);

indexPairs = matchFeatures(f1, f2);

matchedPoints1 = vpts1(indexPairs(:, 1));
matchedPoints2 = vpts2(indexPairs(:, 2));
%figure; showMatchedFeatures(im, template, matchedPoints1, matchedPoints2);
matches = [matchedPoints1; matchedPoints2];
points = [matchedPoints1.Location];
%clusters = fitCenters(points, 30);
end