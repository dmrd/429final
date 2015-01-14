test_set = '/Users/ben/Documents/school/429final/data/garfield/2014';
outfile = 'garfield2014';
image_files = dir([test_set '/*.jpg']);

if exists(outfile) == 2
   'aborting because the output file already exists'
   return;
end

pts = {};
thetas = {};

figure;
for i = 1:size(image_files,1)
    fname = fullfile(test_set, image_files(i).name);
    imshow(fname);
    [inputX, inputY] = ginput;
    
    start_ptsX = inputX(1:2:end)
    end_ptsX = inputX(2:2:end);
    start_ptsY = inputY(1:2:end)
    end_ptsY = inputY(2:2:end);
    img_thetas = atan((end_ptsY - start_ptsY) ./ (end_ptsX - start_ptsX));
    offset = pi*(end_ptsX < start_ptsX);
    img_thetas = img_thetas + offset
    
    thetas{i} = img_thetas;
    pts{i} = [start_ptsX start_ptsY];
    
end

save(outfile, 'pts', 'thetas');
