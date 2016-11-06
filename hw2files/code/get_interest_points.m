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
gaussian_filter = fspecial('Gaussian', feature_width+1, sigma);

%case1: first gradient and after that gassian applied

%  g_ch1 =imfilter(imgradientxy(squeeze(image(:,:,1))), gaussian_filter);
%  g_ch2 = imfilter(imgradientxy(squeeze(image(:,:,2))), gaussian_filter);
%  g_ch3 =imfilter(imgradientxy(squeeze(image(:,:,3))), gaussian_filter);

%case2: first gaussian and after that gradient filter applied
[g_ch1x, g_ch1y] =imgradientxy( imfilter( squeeze(image(:,:,1) ), gaussian_filter));
[g_ch2x, g_ch2y] = imgradientxy( imfilter( squeeze(image(:,:,2) ), gaussian_filter));
[g_ch3x, g_ch3y] = imgradientxy( imfilter( squeeze(image(:,:,3) ), gaussian_filter));

second_gaussian = fspecial('average',[3,3]);
a11 = imfilter(g_ch1x.*g_ch1x +  g_ch2x.* g_ch2x + g_ch3x.*g_ch3x, second_gaussian);
a12 = imfilter(g_ch1x.*g_ch1y +  g_ch2x.* g_ch2y + g_ch3x.*g_ch3y, second_gaussian);
a22 = imfilter(g_ch1y.*g_ch1y +  g_ch2y.* g_ch2y + g_ch3y.*g_ch3y, second_gaussian);

%h = zeros(size(g_ch1x), 'double');
alpha = 0.04;
determinants = a11.*a22 - a12.*a12;
traces = a11 + a22;
h = determinants - alpha*traces.*traces;
% for i=2:size(g_ch1x,1)-1
%     for j=2:size(g_ch1x,2) -1       
%        C =  [a11(i,j), a12(i,j); a12(i,j), a22(i,j) ];
%        determinant_C= det(C);
%        trace_C = trace(C);
%        h(i,j) =  determinant_C - alpha*trace_C*trace_C;
%     end
% end

threshold = h >10 * mean2(abs(h)) ; %adaptive
h= h.*threshold;

non_max = imregionalmax(h,8);      % Non max suppression
[x,y] = find(non_max);

image_sizex = size(image,1);
image_sizey = size(image,2);
valid_indicies = (x > feature_width/2+1) & (x+feature_width/2 < image_sizex +1) & (y > feature_width/2+1) & (y+feature_width/2 < image_sizey + 1);
x = x(valid_indicies);
y = y(valid_indicies);

figure, imagesc(image), axis image, hold on
plot(y,x,'ys'), title('corners detected');

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

% Placeholder that you can delete. 20 random point
end