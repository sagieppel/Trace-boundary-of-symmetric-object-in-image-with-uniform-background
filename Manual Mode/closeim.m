function bw=closeim(bw)
% close binary image bw (morphological operation of dilate and erode
CE=strel('square',3);% create square mask of 3X3 for closing
bw=imclose(bw,CE);% clos image using mask
%figure, imshow(bw);
end