% Local Feature Stencil Code
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

%Check if its colored  or gray image. If it is color turn it to gray image.
%I didn't evaluate feature vectors with color gradients. It works well without color.
if length(size(image)) == 3
gray_image = rgb2gray(image);
else
gray_image = image;
end

%We should smooth image before calculating feature vectors beacuse corner 
%has huge derivatives and they can change one picture to other drastically.
%However, we want to mach them so we should smooth them. I find ideal sigma as 1.2 for both images that I tried
sigma = 1.2;
gaussian_filter = fspecial('Gaussian', feature_width+1, sigma);

% I find the magnitudes and directions of gradients for our gaussian
% filtered image.
[grad_magnitudes, grad_directions] =imgradient(imfilter(gray_image,gaussian_filter));

%Pre allocation of features vector for the speed.
features = zeros([size(x,1),128]);

%For each keypoint we will evaluate feature vector.
for i=1:size(x,1)
    %x and y coordinates of keypoint
    x_coordinate = x(i);
    y_coordinate = y(i);
    
    %I get a patch from gradient magnitudes of image with size of the feature width centered in our keypoint.
    feature_part_gradients = grad_magnitudes(x_coordinate-feature_width/2 : x_coordinate+feature_width/2-1, y_coordinate-feature_width/2 : y_coordinate+feature_width/2-1).*fspecial('Gaussian', feature_width, 8);
    %I o same thing for direction of the gradients.
    feature_part_directions= grad_directions(x_coordinate-feature_width/2 : x_coordinate+feature_width/2-1, y_coordinate-feature_width/2 : y_coordinate+feature_width/2-1);
  
    %pre allocation for speed
    histogram  = zeros([1,128], 'double');
    %We devide feature patch to 4x4 cells. In each cell we calculate 8d histogram vector.
    for j=1:4
      for k=1:4
          % When we get the histogram of a cell we will append the
          % histogram array. However, I preallocate histogram vector,
          % therefore I find the location of new histogram and add the
          % histogram to that location.
           histogram( ((j-1)*32+(k-1)*8 +1): ((j-1)*32+k*8)  ) = getHistogram( feature_part_directions((j-1)*feature_width/4 + 1: j*feature_width/4,   (k-1)*feature_width/4 + 1: k*feature_width/4 )   ,   feature_part_gradients( (j-1)*feature_width/4 + 1: j*feature_width/4,   (k-1)*feature_width/4 + 1: k*feature_width/4) );                     
      end
    end
          %features(i,:) = make_histogram_rotation_invariant(histogram, feature_width);
          %Adding the new feature vector to features array.
           features(i,:) = histogram';
end
%Normalizing features vector.
features = normc(features);
%Clipping excessive histogram values to 0.2. And renormalizing it to 1.
features =normc(features.*(features<0.2) + 0.2*(features>=0.2) );
%End of the function
end

function histogram = getHistogram(Gdir, Grad)
%To speed up I trasform matricies to column vectors.
Gdir = Gdir(:);
Grad = Grad(:);
%I use conditions on arrays to determine a gradients' histogram locations.

%For examples (Gdir>=-180 & Gdir<-135) is 1 for the gradients whose
%directions between [-180,-135] and gives zero for others. And I inner
%product that with Grad vector to find sum of the gradients whose
%directions  between [-180,-135]. 
%I do same thing for other 7 intervals.
histogram = [(Gdir>=-180 & Gdir<-135)'*Grad; (Gdir>=-135 & Gdir<-90)'*Grad; ( Gdir>=-90 & Gdir<-45)'*Grad; (Gdir>=-45 & Gdir<0)'*Grad; (Gdir>=0 & Gdir<45)'*Grad; (Gdir>=45 & Gdir<90)'*Grad; (Gdir>=90 & Gdir<135)'*Grad; (Gdir>=135 & Gdir<180)'*Grad];
%End of the function
end

function  histogram = make_histogram_rotation_invariant(histogram, feature_width)
   %first peak
    [~, I] =  max(histogram);
    %second peak
   % [~,I2] = max(histogram(I) >histogram > histogram(I)*0.8);
    I = mod(I,8); %Histogram angle of the maximum gradient
    if I == 0
         I = 8;
    end   
   %I2 = mod(I2,8);
   %if I2 == 0
   %   I2 = 8;
   %end
   for h=1:feature_width
       histogram((h-1)*8+1: h*8) = circshift(histogram((h-1)*8+1: h*8),-I+1);
       %histogram((h-1)*8+2: h*8) =  circshift(histogram((h-1)*8+2: h*8),-I2+2);
   end

end






