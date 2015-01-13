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

load([rootPath '/labels/' dataset '/' character 'PositiveInstances.mat']);

numExamples = size(positiveInstances,2);
neg_set = [];
fidTrainval = fopen([imsetPath character '_trainval.txt'], 'w');
fidTest = fopen([imsetPath character '_test.txt'], 'w');
for i = 1:numExamples
    fileName = positiveInstances(i).imageFilename
    im = imread(fileName);
    posName = [imPath fileName];
    imwrite(im, posName, 'JPEG');
    fprintf(fidTrainval, [fileName(1:end-4) ' 1\n']);
    fprintf(fidTest, [fileName(1:end-4) ' 1\n']);
    
    for j = 1:size(positiveInstances(i).objectBoundingBoxes,1)
        bb = positiveInstances(i).objectBoundingBoxes(j,:);
        im(bb(2):bb(2)+bb(4),bb(1):bb(1)+bb(3),:) = 255;
    end
    negName = [imPath 'Neg-' fileName];
    imwrite(im, negName, 'JPEG');
    neg_set = [neg_set; negName];
    fprintf(fidTrainval, ['Neg-' fileName(1:end-4) ' -1\n']);
    fprintf(fidTest, ['Neg-' fileName(1:end-4) ' -1\n']);
end
fclose(fidTrainval);
fclose(fidTest);

neg_set = cellstr(neg_set);

labelsToVOC(annoPath, {character}, positiveInstances);

dataset_params.devkitroot = [resultsPath '/'];
dataset_params.localdir = [resultsPath '/'];
dataset_params.resdir = [resultsPath '//results/'];
dataset_params.datadir = [resultsPath 'ComicSVM/'];
dataset_params.dataset = [dataset];
dataset_params.testset = 'test';
dataset_params.SKIP_EVAL = 0;
dataset_params.display = 0;
dataset_params.annopath = [annoPath '%s.xml'];
dataset_params.imgpath = [imPath '%s.jpg'];
dataset_params.imgsetpath = [imsetPath '%s.txt'];
dataset_params.clsimgsetpath = [imsetPath '%s_%s.txt'];
dataset_params.clsrespath = [rootPath '/results///results/Main/%s_cls_test_%s.txt'];
dataset_params.detrespath = [rootPath '/results///results/Main/%s_det_test_%s.txt'];
dataset_params.nparts = 3;
dataset_params.maxparts = [1 2 2];
dataset_params.nactions = 9;
dataset_params.minoverlap = 0.5000;
dataset_params.annocachepath = [rootPath '/results//%s_anno.mat'];
dataset_params.exfdpath = [rootPath '/results//%s_fed.mat'];

save([rootPath '/dataset_params.mat'], 'dataset_params');

params = esvm_get_default_params;
params.model_type = 'exemplar';
params.dataset_params = dataset_params;

%Initialize exemplar stream
stream_params.stream_set_name = 'trainval';
stream_params.stream_max_ex = 10;
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

if size(val_set, 1) > 40
    val_set = val_set(1:40);
end
                              
val_grid = esvm_detect_imageset(val_set, models, val_params, val_set_name);

M = esvm_perform_calibration(val_grid, val_set, models, ...
                             val_params);


end