load('./garfield/positiveInstances.mat');

numExamples = size(positiveInstances,2);
neg_set = [];
for i = 1:numExamples
    im = imread(positiveInstances(i).imageFilename);
    posName = sprintf('/Users/frankjiang/Documents/Workspace/429final/exemplarsvm/VOCdevkit/VOC2007/JPEGImages/garfield/1%.5d.jpg', i);
    imwrite(im, posName, 'JPEG');
    
    for j = 1:size(positiveInstances(i).objectBoundingBoxes,1)
        bb = positiveInstances(i).objectBoundingBoxes(j,:);
        im(bb(2):bb(2)+bb(4),bb(1):bb(1)+bb(3),:) = 255;
    end
    negName = sprintf('/Users/frankjiang/Documents/Workspace/429final/exemplarsvm/VOCdevkit/VOC2007/JPEGImages/garfield/%.6d.jpg', i);
    imwrite(im, negName, 'JPEG');
    neg_set = [neg_set; negName];
end

neg_set = cellstr(neg_set);

labelsToVOC('/Users/frankjiang/Documents/Workspace/429final/exemplarsvm/VOCdevkit/VOC2007/Annotations/garfield/', {'garfield'}, positiveInstances)

load('./dataset_params.mat');
dataset_params.imgpath = '/Users/frankjiang/Documents/Workspace/429final/exemplarsvm/VOCdevkit/VOC2007/JPEGImages/garfield/%s.jpg';
dataset_params.annopath = '/Users/frankjiang/Documents/Workspace/429final/exemplarsvm/VOCdevkit/VOC2007/Annotations/garfield/%s.xml';

params = esvm_get_default_params;
params.model_type = 'exemplar';
params.dataset_params = dataset_params;

%Initialize exemplar stream
stream_params.stream_set_name = 'trainval';
stream_params.stream_max_ex = 1;
stream_params.must_have_seg = 0;
stream_params.must_have_seg_string = '';
stream_params.model_type = 'exemplar'; %must be scene or exemplar;
stream_params.cls = 'garfield';

%Create an exemplar stream (list of exemplars)
e_stream_set = esvm_get_pascal_stream(stream_params, ...
                                      dataset_params);
                                  
               
                                  
models_name = ...
    ['garfield' '-' params.init_params.init_type ...
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

val_set_name = ['trainval+' 'garfield'];

val_set = esvm_get_pascal_set(dataset_params, val_set_name);
val_set = val_set(1:40);
                              
val_grid = esvm_detect_imageset(val_set, models, val_params, val_set_name);

M = esvm_perform_calibration(val_grid, val_set, models, ...
                             val_params);
                         
                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Testing
%%%%%%%%%%%%%%%%%%%%%%%

test_params = params;
test_params.detect_exemplar_nms_os_threshold = 0.5;
test_set_name = ['test+' 'garfield'];
test_set = esvm_get_pascal_set(dataset_params, test_set_name);
%test_set = test_set(1:100);

test_grid = esvm_detect_imageset(test_set, models, test_params, test_set_name);

test_struct = esvm_pool_exemplar_dets(test_grid, models, M, test_params);

maxk = 20;
allbbs = esvm_show_top_dets(test_struct, test_grid, test_set, models, ...
                       params,  maxk, test_set_name);