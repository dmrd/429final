function clf = trainClassifier(dataFolder, samplingType)
%%
% Train an image classifier given a data folder which contains
% samplingType: one of 'Grid', 'Detector'
imgSets = imageSet(dataFolder, 'recursive');
bag = bagOfFeatures(imgSets, 'PointSelection', samplingType);
clf = trainImageCategoryClassifier(imgSets, bag);
end