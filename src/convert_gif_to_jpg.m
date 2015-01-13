function convert_gif_to_jpg( filename )
    [img,map] = imread([filename '.gif']);
    imwrite(img,map,[filename '.jpg']);
end

