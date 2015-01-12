function [] = trainComicDetector(rootPath, dataset, character)
    
% Usage:
%       dataset = 'garfield'
%       character = 'garfield'
%       trainAndTest(pwd, dataset, character)

resultsPath = [rootPath '/results/'];

imPath = [resultsPath 'ComicSVM/' dataset '/JPEGImages/' character '/'];
annoPath = [resultsPath 'ComicSVM/' dataset '/Annotations/' character '/'];
imsetPath = [resultsPath 'ComicSVM/' dataset '/ImageSets/Main/' character '/'];
mkdir(imPath);
mkdir(annoPath);
mkdir(imsetPath);

addpath(genpath(rootPath));

load([rootPath '/labels/' character '/positiveInstances.mat']);

numExamples = size(positiveInstances,2);
neg_set = [];
fidTrainval = fopen([imsetPath character '_trainval.txt'], 'w');
fidTest = fopen([imsetPath character '_test.txt'], 'w');
for i = 1:numExamples
    positiveInstances(i).imageFilename
    im = imread(positiveInstances(i).imageFilename);
    posName = [imPath sprintf('1%.5d.jpg', i)];
    imwrite(im, posName, 'JPEG');
    fprintf(fidTrainval, [sprintf('1%.5d', i) ' 1\n']);
    fprintf(fidTest, [sprintf('1%.5d', i) ' 1\n']);
    
    for j = 1:size(positiveInstances(i).objectBoundingBoxes,1)
        bb = positiveInstances(i).objectBoundingBoxes(j,:);
        im(bb(2):bb(2)+bb(4),bb(1):bb(1)+bb(3),:) = 255;
    end
    negName = [imPath sprintf('%.6d.jpg', i);];
    imwrite(im, negName, 'JPEG');
    neg_set = [neg_set; negName];
    fprintf(fidTrainval, [sprintf('%.6d', i) ' -1\n']);
    fprintf(fidTest, [sprintf('%.6d', i) ' -1\n']);
end
fclose(fidTrainval);
fclose(fidTest);

neg_set = cellstr(neg_set);

labelsToVOC(annoPath, {character}, positiveInstances);

load([rootPath '/dataset_params.mat']);

params = esvm_get_default_params;
params.model_type = 'exemplar';
params.dataset_params = dataset_params;

%Initialize exemplar stream
stream_params.stream_set_name = 'trainval';
stream_params.stream_max_ex = 1;
stream_params.must_have_seg = 0;
stream_params.must_have_seg_string = '';
stream_params.model_type = 'exemplar'; %must be scene or exemplar;
stream_params.cls = character;

%Create an exemplar stream (list of exemplars)
e_stream_set = esvm_get_pascal_stream(stream_params, ...
                                      dataset_params);
                                  
               
                                  
models_name = ...
    [character '-' params.init_params.init_type ...
     '.' params.model_type];

initial_models = esvm_initialize_exemplars(e_stream_set, params, models_name);


train_params = params;
train_params.detect_max_scale = 0.5;
train_params.train_max_mined_images = 50;
train_params.detect_exemplar_nms_os_threshold = 1.0;
train_params.detect_max_windows_per_exemplar = 100;



[models,models_name] = esvm_train_exemplars(initial_models, ...
                                            neg_set, train_params);


val_params = params;
val_params.detect_exemplar_nms_os_threshold = 0.5;
val_params.gt_function = @esvm_load_gt_function;

val_set_name = ['trainval+' character];

val_set = esvm_get_pascal_set(dataset_params, val_set_name);
val_set = val_set(1:40);
                              
val_grid = esvm_detect_imageset(val_set, models, val_params, val_set_name);

M = esvm_perform_calibration(val_grid, val_set, models, ...
                             val_params);


end