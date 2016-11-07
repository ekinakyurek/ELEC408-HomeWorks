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

function [features] = get_features(image, x, y, feature_width, scales)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See lecture notes or Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% Histogram: You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.


gray_image = rgb2gray(image);
features = zeros([size(x,1),128]);


for i=1:size(x,1)
   sigma = scales(i); 
   gaussian_filter = fspecial('Gaussian', feature_width+1, sigma);
   [grad_magnitudes, grad_directions] =imgradient(imfilter(gray_image,gaussian_filter));
  x_coordinate = x(i);
  y_coordinate = y(i);
    
    feature_part_gradients = grad_magnitudes(x_coordinate-feature_width/2 : x_coordinate+feature_width/2-1, y_coordinate-feature_width/2 : y_coordinate+feature_width/2-1).*fspecial('Gaussian', feature_width, sigma*2);
    feature_part_directions= grad_directions(x_coordinate-feature_width/2 : x_coordinate+feature_width/2-1, y_coordinate-feature_width/2 : y_coordinate+feature_width/2-1);
   
    histogram  = [];
    for j=1:feature_width/4
      for k=1:feature_width/4
           histogram = [histogram; getHistogram( feature_part_directions((j-1)*feature_width/4 + 1: j*feature_width/4,   (k-1)*feature_width/4 + 1: k*feature_width/4 ), feature_part_gradients( (j-1)*feature_width/4 + 1: j*feature_width/4,   (k-1)*feature_width/4 + 1: k*feature_width/4 )) ];                     
      end
    end
          Gdir =  make_directions_rotation_invariant(histogram, feature_part_directions((j-1)*feature_width/4 + 1: j*feature_width/4,   (k-1)*feature_width/4 + 1: k*feature_width/4 ));
        histogram = [];
      for j=1:feature_width/4
      for k=1:feature_width/4
           histogram = [histogram; getHistogram( Gdir , feature_part_gradients( (j-1)*feature_width/4 + 1: j*feature_width/4,   (k-1)*feature_width/4 + 1: k*feature_width/4 )) ];                     
      end
    end
          %eatures(i,:) = histogram';
end

features = normc(features);
features =normc(features.*(features<0.2) + 0.2*(features>=0.2) );

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Placeholder that you can delete. Empty features.
%features = zeros(size(x,1), 128);



end

function histogram = getHistogram(Gdir, Grad)
Gdir = Gdir(:);
Grad = Grad(:);
histogram = [(Gdir>=-180 & Gdir<-135)'*Grad; (Gdir>=-135 & Gdir<-90)'*Grad; ( Gdir>=-90 & Gdir<-45)'*Grad; (Gdir>=-45 & Gdir<0)'*Grad; (Gdir>=0 & Gdir<45)'*Grad; (Gdir>=45 & Gdir<90)'*Grad; (Gdir>=90 & Gdir<135)'*Grad; (Gdir>=135 & Gdir<180)'*Grad];
end

function histogram = getHistogram2(Gdir, Grad, angles)
Gdir = Gdir(:) +180;
Grad = Grad(:);
%histogram = [(Gdir>=-180 & Gdir<-135)'*Grad; (Gdir>=-135 & Gdir<-90)'*Grad; ( Gdir>=-90 & Gdir<-45)'*Grad; (Gdir>=-45 & Gdir<0)'*Grad; (Gdir>=0 & Gdir<45)'*Grad; (Gdir>=45 & Gdir<90)'*Grad; (Gdir>=90 & Gdir<135)'*Grad; (Gdir>=135 & Gdir<180)'*Grad];
histogram = [(Gdir>=angles(1) & Gdir< angles(2))'*Grad; (Gdir>=angles(2) & Gdir<angles(3))'*Grad; ( Gdir>=angles(3) & Gdir<angles(4))'*Grad; (Gdir>=angle(4)& Gdir<angles(5))'*Grad; (Gdir>=angles(5) & Gdir<angles(6))'*Grad; (Gdir>=angles(6) & Gdir<angles(7))'*Grad; (Gdir>=angles(7) & Gdir<angles(8))'*Grad; (Gdir>=angles(8) & Gdir< 360)'*Grad];
end

function Gdir = make_directions_rotation_invariant(histogram, Gdir)
   %first peak
   Gdir = Gdir(:) +180;

   [~, I] =  max(histogram);
    %second peak
   % [~,I2] = max(histogram(I) >histogram > histogram(I)*0.8);
    I = mod(I,8); %Histogram angle of the maximum gradient
    if I == 0
         I = 8;
    end   
  Gdir = mod(Gdir-(I-1)*45,360);
  Gdir = Gdir-180;
   %I2 = mod(I2,8);
   %if I2 == 0
   %   I2 = 8;
   %end
end


% function rotational_invariant_feature_vector =  make_rotational_invariant(gradients,directions)
%        
%     if Gdir>=-180 && Gdir<-135
%         histogram_part = 1;
%     elseif Gdir>=-135 && Gdir<-90
%          histogram_part =2;
%     elseif Gdir>=-90 && Gdir<-45
%         histogram_part = 3 ;
%     elseif Gdir>=-45 && Gdir<0
%         histogram_part = 4;
%     elseif Gdir>=0 && Gdir<45
%         histogram_part = 5;
%     elseif Gdir>=45 && Gdir<90
%         histogram_part = 6;
%     elseif Gdir>=90 && Gdir<135
%         histogram_part = 7;
%      elseif Gdir>=135 && Gdir<180
%         histogram_part = 7;
%     else
%         histogram_part =1;
%     end  
% end
%   





