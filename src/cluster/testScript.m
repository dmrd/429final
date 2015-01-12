figure;
imshow(im);
[x,y] = ginput(1);
mask = expandGraphFromPoint(labels, nodes, edges, x, y, 5);
imshow(mask);