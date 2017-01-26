function bw=canysobel(i3,highthresh)

% return borders for greyscale image i3  in a binary image
% combine canny and sobel operator the canny create better edge the soble
% without maximum supression give thiker edges and prevent holes in the one
% line canny hence their combination give best resul
%the soble  threshold should be between the  canny high and low 
% threshholds to be affective. High thresh is the high threshold in the
% canny and is optional the low and sobel threshold will be deterimed by it
%i2=imresize(i,0.12);%0.12);% resize image to 10% since it give better edge detection ability in lower scale
if nargin==1
    highthresh=0.12;% if threshold not assign use standart value
end

e=edge(i3,'canny',[highthresh/3,highthresh],1.1); % preform canny with low and high threshold in [] and gaussian sigma of 1.1(final line)

 %imshow(e);
 %pause;
 %--------------------------------------manualy make gaussian blur (optiona)-----------------------------------------------------------
% gas=fspecial('gaussian',[7,7],1.1)% create gaussian filter with given size and sigma
%i3=imfilter(i3,gas);%gaussian blur the image
 %----------------------------------------------------------------------------------------------
 bw=edge(i3,'sobel',highthresh/2,'nothinning'); %preform soble with given threshold that should be between the canny high and low threshhold no maximum supression applied specify by 'nothinning


 
bw(e>0)=1;% add the edges found by canny to the edges find by soble to create combine edge image
%imshow(bw);
%pause;
end