function points = detectCrossCorr(im, template)
    cc = xcorr2(rgb2gray(im),rgb2gray(template));
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];
    %points = isequal(corr_offset,offset)
end
