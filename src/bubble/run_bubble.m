function [ pts, thetas, text ] = run_bubble( comicImg )

warning('off', 'all');
set(0,'DefaultFigureVisible','off')


[rects, text] = bubbleseg(comicImg);
[pts, thetas, idxs] =  bubble_direction(comicImg, rects);
text = text(idxs);

warning('on', 'all');
set(0,'DefaultFigureVisible','on')


end

