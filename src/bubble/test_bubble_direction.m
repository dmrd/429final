filename = 'bubble_testing_images/phd1.jpg';
comicImg = imread(filename);

figure;
imshow(comicImg);
rect = getrect;

bubble_direction(comicImg, rect);