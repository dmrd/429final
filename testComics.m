function [test_set, test_struct] = testComics(rootPath, dataset, character, testset)


load([rootPath '/dataset_params.mat']);
load([rootPath '/results/models/' character '-g.exemplar-svm.mat']);
load([rootPath '/results/models/' character '-g.exemplar-svm-M.mat']);

testsetPath = [rootPath '/data/' dataset '/' testset];

dirNames = struct2cell(dir([testsetPath '/*.jpg']));
test_set = dirNames(1,:)';

params = esvm_get_default_params;
params.model_type = 'exemplar';
params.dataset_params = dataset_params;

test_params = params;
test_params.detect_exemplar_nms_os_threshold = 0.5;
test_set_name = ['test+' character];

test_grid = esvm_detect_imageset(test_set, models, test_params, test_set_name);

test_struct = esvm_pool_exemplar_dets(test_grid, models, M, test_params);


maxk = 20;
allbbs = esvm_show_top_dets(test_struct, test_grid, test_set, models, ...
                       params,  maxk, test_set_name);

end