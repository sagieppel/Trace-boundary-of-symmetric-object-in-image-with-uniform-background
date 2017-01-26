function [L, num] = labelim(bw)
%label binary image bw occurding to its white blobs
%return L image of labels hence image of size of bw where pixels  values
%are their label number num is the number of different labels found
bw=~bw;% invert BW color 1->0 0->1
%figure, imshow(bw);
[L, num] = bwlabel(bw, 4); %L labeld image returns in num the number of connected objects found in BW can have connectivity of 4 or 8 (Second parametr)
%figure, imshow(L,[]);
%impixelinfo;% colorfull way to represent the image such that it use all the rgb values and not just grey
%figure, imshow(label2rgb(L),[]);
end