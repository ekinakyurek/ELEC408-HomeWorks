% Local Feature Stencil Code
% Written by James Hays

% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features 1, the second column is an index
%   in features2. 
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2)

% We can adjust threshold for different images to show best matchigs. 

%For our images best thresholds:

%Notre Dame:
threshold = 0.665;

%Keble:
%threshold = 0.62

%Library:
%threshold = 0.7

%Me:
%threshold = 0.65

%We should find distance between i element of the features1 and for each
%j element of the features2 for a given i. And olsa foreach i element we
%should repeat that process. Actually, matlab has a pdist2 function whose
%i,j element is the distance between features(i) and features(j).
distances = pdist2(features1, features2, 'euclidean');
%We will sort this distances inorder to find best matches. Matlabs has a
%sort function too.
[distances_sorted, index_matrix] = sort(distances, 2, 'ascend');
%For the ratio test I find find distance of nearest feature vector/distance
%of second nearest futures vector for each vector.
ratio = (distances_sorted(:,1)./distances_sorted(:,2));
%If that ratio is closer to one, that's not a good matching. We should
%discard them. Therefore I determine a threshold values around 0.70 to
%discard bad matches.

%Elements of test equals to 1 will be our best matches.
test = ratio < threshold;
%Confidence is required from the function so I calculate the confidence for
%good matches as 1/ratio. By passing test to indexes of ratio I pick only
%good matches
confidences = (1./ratio(test,:));

%Create array in size of good_matchesx2
matches = zeros(size(confidences,1), 2);

%Find that elements' indexes for the first image
matches(:,1) = find(test);
%Find the corresponding element in second image
matches(:,2) = index_matrix(test, 1);
% Sort the matches so that the most confident onces are at the top of the
% list. You should probably not delete this, so that the evaluation
% functions can be run on the top matches easily.
[confidences, ind] = sort(confidences, 'descend');
matches = matches(ind,:);
