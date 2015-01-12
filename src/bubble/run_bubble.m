function [ pts, thetas ] = run_bubble( comicImg )

rects = bubbleseg(comicImg);

%pts = 0; thetas = 0;
[pts, thetas] =  bubble_direction(comicImg, rects);

end

