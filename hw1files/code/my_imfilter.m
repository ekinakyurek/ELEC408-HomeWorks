function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);


%%%%%%%%%%%%%%%%
% Your code here
%First flip of the columns the filter for the convolution operation
 filter = fliplr(filter);
 %Flip the rows for the convolution operation
 filter = transpose(fliplr(transpose(filter)));
 

%size of image and filter are used in convolution summation limits
size_of_image = size(image);
size_of_filter = size(filter);

%image input can be three different type such that: standart uint8 RGB,
%doubled(im2double) and single(im2single). If its uint8 it should be
%converted to double for filter operation. Because matlab cannot perform
%uint8*double operation, I evaluate those situations
type = 0;
if isa(image,'uint8')
    %The input is in the uint8 format, I convert it to double
    image = double(image);
    %I initialize the output image with given input type
    output = zeros(size_of_image, 'uint8');
    %uint8 is named as type 0
    type = 0;
elseif isa(image,'double') 
    %if the input is double no need to convert it
    %I initialize the output image with given input type
    output = zeros(size_of_image,'double');
    %double is enumarated as type 1
    type = 1;
elseif isa(image,'single')
    %if the image is single no need to convert it
     %I initialize the output image with given input type
    output = zeros(size_of_image, 'single');
    %single is enumarated as type 2
    type = 2;
else
    display('Image format is not valid, try again')
end    

%pading is applied for achieve the same resolution after convolution
pad_size = [(size_of_filter(1)-1)/2 , (size_of_filter(2)-1)/2];
padded_image = padarray(image,pad_size);

%filter applied channel by channel 
for z = 1:3
    % get one channel of the image
    padded_channel = padded_image(:,:,z);
    %convolution operation
    for i = 1:size_of_image(1)
        for j = 1:size_of_image(2)
                intersection = padded_channel(i:i+(size_of_filter(1)-1),j:j+size_of_filter(2)-1) .*filter ;
                if type==0
                    %if the image uint8. It should be converted back
                    output(i,j,z) =uint8(round(sum(sum(intersection))));
                else
                    %if the image double or single no need to convert back
                    output(i,j,z) = sum(sum(intersection));
                end
        end
    end
end
%%%%%END OF THE CODE%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%





