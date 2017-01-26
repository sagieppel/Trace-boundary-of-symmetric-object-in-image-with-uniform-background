function blobs = Getimregions( bw )
%take binary image  bw and divide it to untouched areas using image
%segmentation of labelim  return array of all segments of the image arrange
%in according to their area size (larger first)  the return array contain
%lots of information about the blobs that is explained in regionprops
%function
% methodology is simple inver

%   Detailed explanation goes here

 %--------------------------------------------------------------------------------------------------------
 bw=~bw;% invert image color create the negative. black to white and white to black
 L=labelim(bw);% label binary image give different label to evey blob/segment the label are the pixels values of L
 blobs=regionprops(L,'all');% extract blobs from the label image : area shape into array blobs
 [unused, order] = sort([blobs(:).Area],'descend');% order contain the rearranged indexs of blobs after sorting according to blobs area
 new_blobs=blobs(order);% rearranged  blobs in according to their area base on the index given in sort
 blobs=new_blobs;

end

