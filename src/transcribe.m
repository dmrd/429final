function = transcribe( comicDir, classes, transcriptionDir )

detections = [];
for i = 1:size(classes,1)
    [test_set, test_struct] = testComics(comicDir, classes(i));
    bb = cat(1,test_struct.unclipped_boxes{:});
    
    % Get rid of unnecessary columns.  Now we have the rectangles
    % indices into the test_set, and indices into the classes
    bb = [ bb(:,[1:4, 11]) classes(i) ];
    detections = [ detections ; bb ];
end

for i = 1:size(test_set,1)
   
    img = imread(test_set(i));
    
    [pts, thetas, text] = run_bubble(img);
    
    %Get all the rows for the current image
    bb = detections(detections(:,5) == i, :);
    
    % Sort the bounding boxes by xmin
    bb = sortrows(bb, 1);
    
    transcript = '';
    for j = 1:size(pts,1)
        distances = zeros(size(bb,1));
        for k = 1:size(bb,1)
            distances(i) = distance_vector_to_rect(pts(j), thetas(j), bb(k));
        end
        [~, best_bb_idx] = min(distances);
        best_bb = bb(best_bb_idx,:);
        character = classes(bb(6));
        transcript = [ transcript character ':' text ];
    end
    
    transcript

end

