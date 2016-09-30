originalRGB = imread('../data/bird.bmp');
h = fspecial('motion', 50, 45);
filteredRGB = my_imfilter(originalRGB, h);
imfilterd = imfilter(originalRGB,h);
difference = imfilterd-filteredRGB;
figure, imshow(filteredRGB)