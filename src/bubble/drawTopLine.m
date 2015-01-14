function [ bwImgOut ] = drawTopLine( bwImg )

bwImgOut = bwImg;
rowCountBlack = sum(~bwImg,2);
top = find(rowCountBlack >= 100, 1);
bwImgOut(top:top+5, :) = 0;

end

