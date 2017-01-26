function bw=substract_background(bw)
%create blob image in which every part that correspond to bw background is
%black and every other part is white
%1) recieve binary image bw label it using labelim 
%2) identify all labels on the labeles imaged that touch the image
%outeredges/ borders 
% 3)take ones image in the size of bw and make every pixel that correspond to
% the back ground in bw to be equal zeros
%-------------------------1 label  the image----------------------------------------------------------------------------------
[L, num] = labelim(bw);% label binary image to get the back ground label 
d = size(L);% get figure dimension
%------------------identify the back ground  label (assume that the background label correspond to the outer edges of the image) create black white image where everything beside the back ground is white and the background is black--------------------------------------------------------------------------------------
bw=ones(d);
%bw(L==L(d(1),d(2)) | L==L(1,d(2)) |   L==L(d(1),1)  | L==L(1,1))=0; % get reed of back ground

for f=1:1:d(1)
    bw(L==L(f,1) | L==L(f,d(2)))=0;
    
end;
    
for f=1:1:d(2)
    bw(L==L(1,f) | L==L(d(1),f))=0;
end;
%-----------------------------------------------------------------------------------------------------------------
bw(L==0)=1;% zeros are edges(white areas in bw) and edges count as part of the object not the background thefore they restored if deletd
%}
%as alternative for the above method it might be possible to take the background as simply the label with the largest areas
%---------------------------- 
%erode;
end

