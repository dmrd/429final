test_set = '/Users/ben/Documents/school/429final/data/garfield/2014';
image_files = dir([test_set '/*.jpg']);

pts_err = [];
thetas_err = [];
numMissed = 0;
numExtra = 0;

load('garfield2014.mat', 'pts', 'thetas');
for i = 1:size(image_files,1)
    fname = fullfile(test_set, image_files(i).name);
    comicImg = imread(fname);
    [pts_test, thetas_test] = run_bubble(comicImg);
    pts_truth = pts{i};
    thetas_truth = thetas{i};
    for j = 1:size(pts_truth,1)
        norms = zeros(size(pts_test,1),1);
        for k = 1:size(pts_test,1)
            norms(k) = norm(pts_truth(j,:)-pts_test(k,:));
        end
        [minDist, minIdx] = min(norms);
        if minDist < 50
            pts_err = [pts_err ; minDist];
            t_err = thetas_test(minIdx) - thetas_truth(j);
            t_err = abs(wrapToPi(t_err));
            thetas_err = [thetas_err ; t_err];
        else
            numMissed = numMissed + 1;
        end
    end
    
    for j = 1:size(pts_test,1)
        norms = zeros(size(pts_truth,1),1);
        for k = 1:size(pts_truth,1)
            norms(k) = norm(pts_truth(k,:)-pts_test(j,:));
        end
        [minDist, minIdx] = min(norms);
        if minDist > 50
            numExtra = numExtra + 1;
        end
        
    end
end

avg_theta_err = mean(thetas_err)
avg_pts_err = mean(pts_err)
numMissed
numExtra
        