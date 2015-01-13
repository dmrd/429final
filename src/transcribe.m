function transcribe( rootPath, dataset, testdir, classes, transcriptionDir )

detections = [];
for i = 1:size(classes,1)
    [test_set, test_struct] = testComics(rootPath, classes{i}, dataset, testdir);
    bb = cat(1,test_struct.unclipped_boxes{:});
    
    % Get rid of unnecessary columns.  Now we have the rectangles
    % indices into the test_set, and indices into the classes
    bb = [ bb(:,[1:4, 11]) repmat(i, size(bb,1), 1) ];
    detections = [ detections ; bb ];
end

for i = 1:size(test_set,1)
   
    test_set{i};
    img = imread(test_set{i});
    
    [pts, thetas, text] = run_bubble(img);
    
    %Get all the rows for the current image
    bb = detections(detections(:,5) == i, :);
    
    % Sort the bounding boxes by xmin
    bb = sortrows(bb, 1);
    
    
    outDir = fullfile(transcriptionDir, testdir);
    mkdir(outDir);
    [~, comic_name, ~] = fileparts(test_set{i});
    outFname = fullfile(outDir, [comic_name '.txt']);
    fid = fopen(outFname, 'w');
    for j = 1:size(pts,1)
        distances = zeros(size(bb,1), 1);
        for k = 1:size(bb,1)
            d = distance_vector_to_rect(pts(j,:), thetas(j), bb(k,:));
            distances(k) = d;
        end
        [~, best_bb_idx] = min(distances);
        best_bb = bb(best_bb_idx,:);
        character = classes{best_bb(6)};
        transcript_new = ['\n' character ':' text{j} ]
        fprintf(fid, transcript_new);
    end
    
    fclose(fid);
    
end

