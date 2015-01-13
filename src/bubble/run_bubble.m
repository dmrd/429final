function [ pts, thetas, text ] = run_bubble( comicImg )

[rects, text] = bubbleseg(comicImg);
[pts, thetas, idxs] =  bubble_direction(comicImg, rects);
text = text{idxs};

end

