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

% To make more robust and fast multiplications I change out image to double format
image = im2double(image);

%Corners can have huge gradients. And the gradients can drastically change two pictures which we match
%Therefore we need to smoot image first. We apply gaussian filter
% to the image. It is the parameter which should change with corner scale.
% However, in our implementation we assign only one sigma for each image
% emprically. Scale Invariant Feature Transform requires more mathematics.

%Best sigma values for my datas:

%Notre Dame:
sigma = 1;

%Keble:
%sigma = 0.3

%Library:
%sigma = 0.7

%Me:
%sigma=0.5

%Out feature vectors will be in the size of feature width. Thus, smoothing
%can be done in feature_width but I wanted to center our keypoint pixels, therefore I
%use odd filtersize = feature_width+1
gaussian_filter = fspecial('Gaussian', feature_width+1, sigma);


if length(size(image)) == 3

%I smooth the image and find the color gradients in xy format by using
%matlab's imfilter and imgradientxy respectively. R:ch1 , G: ch2, B:ch3.
[g_ch1x, g_ch1y] =imgradientxy( imfilter( squeeze(image(:,:,1) ), gaussian_filter));
[g_ch2x, g_ch2y] = imgradientxy( imfilter( squeeze(image(:,:,2) ), gaussian_filter));
[g_ch3x, g_ch3y] = imgradientxy( imfilter( squeeze(image(:,:,3) ), gaussian_filter));

%I calculate corelattion matrix coeffecient by calculation C=D'D whre D is
%3x2 column matrix [g_ch1x, g_ch1y; g_ch2x, g_ch2y; g_ch3x, g_ch5y].
%Before that implementation I do a for loop for each i,j element of image,
%I multiply numerically D'D but it is very slow. Therefore, I calculate
%matrix coeffecients in hand. It speed up the algorithm.

%Resulting matrix hast 3 different element. a12 = a21.
%In the text book weighting is recommended for the corellation matrix. I
%tried gaussian and average filter. Average filter gives more correct
%results in the matching. 
weighting = fspecial('average',[3,3]);
c11 = imfilter(g_ch1x.*g_ch1x +  g_ch2x.* g_ch2x + g_ch3x.*g_ch3x, weighting);
c12 = imfilter(g_ch1x.*g_ch1y +  g_ch2x.* g_ch2y + g_ch3x.*g_ch3y, weighting); % =a21
c22 = imfilter(g_ch1y.*g_ch1y +  g_ch2y.* g_ch2y + g_ch3y.*g_ch3y, weighting);
else
    
%For gray images corellation matrix is simple a11 = Ix.^2 , a22 = Iy.^2,
%a12 = IxIy = a21. Weighting is also applied.

%I smooth the gay image and find the gradient in xy format by using
%matlab's imfilter and imgradientxy respectively. R:ch1 , G: ch2, B:ch3.
[Ix, Iy] = imgradientxy( imfilter(image, gaussian_filter));
weighting = fspecial('average',[3,3]);
c11 = imfilter(Ix.^2, weighting);
c12 = imfilter(Ix.*Iy , weighting); % =a21
c22 = imfilter(Iy.^2, weighting);
end
%h = I use harris corner function as:
%(lambda1*lambda2)-alpha*(lambda1+lambda2).^2
%I pick alpha as recommended: 0.04
alpha = 0.04;
%Determinan of 2x2 matrix: ad-bc
determinants = c11.*c22 - c12.*c12;
%Trace of 2x2 matrix = a+d
traces = c11 + c22;
%Harris corner function
h = determinants - alpha*traces.*traces;

% for i=2:size(g_ch1x,1)-1
%     for j=2:size(g_ch1x,2) -1       
%        C =  [a11(i,j), a12(i,j); a12(i,j), a22(i,j) ];
%        determinant_C= det(C);
%        trace_C = trace(C);
%        h(i,j) =  determinant_C - alpha*trace_C*trace_C;
%     end
% end

%I realize that the threshold is very dependent to image. I search on the
%internet and effective vay of doing thresh old may actually done by
%looking average. However, in our images mean was negative.
%I come up with and idea that taking mean of the absolute value of the h function 
%I tried  threshold as 2,5,8,10 times of mean2(abs(h)). The best was  10 *
%mean2(abs(h))  in both images.
threshold = h > 10 * mean2(abs(h)) ; %adaptive 

%Applying threshold
h= h.*threshold;

%Nonmaximal supressin to harris corners. There is matlab which looks 8
%neighboor and decide h is local max or not. I use that function
h = imregionalmax(h,8);      % Non max suppression

%Coordinates of non zero h elements=our corners.
[x,y] = find(h);

%We couldnt make a fature vector with near edge corners. Therefore I
%discarded them.
image_sizex = size(image,1);
image_sizey = size(image,2);

%Valid indicies for a given featurewidth
valid_indicies = (x > feature_width/2+1) & (x+feature_width/2 < image_sizex +1) & (y > feature_width/2+1) & (y+feature_width/2 < image_sizey + 1);

%Valid harris corners
x = x(valid_indicies);
y = y(valid_indicies);

%Plotting for visualization of corners.
figure, imagesc(image), axis image, hold on
plot(y,x,'ro'), title('corners');

%End of the function
end