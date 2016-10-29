% Local Feature Stencil Code
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector to start with.
image = im2double(image);

%I cant decide which one should be first gaussian or gradient filter. May
%be it doesnt matter.
sigma = 1;
gaussian_filter = fspecial('Gaussian', 2*sigma+1, sigma);
%case1: first gaussian and after that gradient filter applied
[g_ch1x, g_ch1y] =imgradientxy( imfilter( squeeze(image(:,:,1) ), gaussian_filter));
[g_ch2x, g_ch2y] = imgradientxy( imfilter( squeeze(image(:,:,2) ), gaussian_filter));
[g_ch3x, g_ch3y] = imgradientxy( imfilter( squeeze(image(:,:,3) ), gaussian_filter));

%case2: first gradient and after that gassian applied

%  g_ch1 =imfilter(imgradientxy(squeeze(image(:,:,1))), gaussian_filter);
%  g_ch2 = imfilter(imgradientxy(squeeze(image(:,:,2))), gaussian_filter);
%  g_ch3 =imfilter(imgradientxy(squeeze(image(:,:,3))), gaussian_filter);

% D(:,:,1,1) =  g_ch1x;
% D(:,:,1,2) =  g_ch1y;
% D(:,:,2,1) =  g_ch2x;
% D(:,:,2,2) =  g_ch2y;
% D(:,:,3,1) =  g_ch3x;
% D(:,:,3,2) =  g_ch3y;
% C = D'D
C(:,:,1,1) = g_ch1x.*g_ch1x +  g_ch2x.* g_ch2x + g_ch3x.*g_ch3x;
C(:,:,1,2) = g_ch1x.*g_ch1y +  g_ch2x.* g_ch2y + g_ch3x.*g_ch3y;
C(:,:,2,1) = g_ch1y.*g_ch1x +  g_ch2y.* g_ch2x + g_ch3y.*g_ch3x;
C(:,:,2,2) = g_ch1y.*g_ch1y +  g_ch2y.* g_ch2y + g_ch3y.*g_ch3y;

h = zeros(size(g_ch1x), 'double');
alpha = 0.04;
for i=1:size(g_ch1x,1)
    for j=1:size(g_ch1x,2)
       h(i,j) =  det(squeeze(C(i,j,:,:)))- alpha*trace(squeeze(C(i,j,:,:)))*trace(squeeze(C(i,j,:,:)));
    end
end
threshold = abs(h) > 10*mean2(abs(h)) ; %adaptive
h= h.*threshold;

% non_max = ordfilt2(h,16,ones(4,4));
% coordinates = (h==non_max);       % Non max suppression.
size(h)
[r,c] = find(h);
figure, imagesc(image), axis image, hold on
plot(c,r,'ys'), title('corners detected');




% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.

% Placeholder that you can delete. 20 random points
x = ceil(rand(20,1) * size(image,2));
y = ceil(rand(20,1) * size(image,1));

end

