%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vv
function [BW2]=Remove_Parallel_Region(BW2)%
%%find two points in each line (y value) that will be the the line
%left and right edges 
% take binary BW2 image containing the full area of the object marked in ones on the image
% lines in which there more then two border point to the image (hence to
% paprallel untouched region are reduced by choosing the broadest region and removing the rest
%Return new image with only are two border points per line if the image
%breaked for few seperate blobs delete all but the largest blob

%pause;

 d = size(BW2);% get image dimension
    %find image baundary end center for every line
bn=zeros(d(1),2);% the edge array cotaining the x values of the two edges for every line (y value)
for fy=1:1:d(1)% scan every line y
    pb=0;
    bnd=0; %temp region boundaries mark the left boundary of the last found region
     bn(fy,1)=0; bn(fy,2)=-1;% initialize the edges of line y
      
    for fx=1:1:d(2) % scan along the line x values
       
        if (pb==0 && BW2(fy,fx)==1)
            pb=1;
            bnd=fx;
        elseif (pb==1 && BW2(fy,fx)==0)
            pb=0;
            if (bn(fy,2)- bn(fy,1))<(fx-bnd)
                bn(fy,2)=fx;
                bn(fy,1)=bnd;
            end;
        end
            
    end


if (bn(fy,1)==0)% if only one point was found on the line fy then the two edges equal to this point (fx0)
        bn(fy,1)=bnd;bn(fy,2)=d(2);
end
    
end
 %-----------------------------------------------------draw the new image with only two edges per figure------------------------------------------------------------------------
BW2=zeros(d);
for fy=1:1:d(1)
    for fx=bn(fy,1):1:bn(fy,2)
            BW2(fy,fx)=1; % if the boundary are outside the image 
    end;    
end;
%----------------------------The previous actions might have broken the blob into few different blobs this take the largest blob and draw it---------------------------

%BW2=BW2.*0;%empty the the binary image
%BW2((blobs(f).PixelList(:,2),blobs(f).PixelList(:,1))=1; %mark the largest blob
%imshow(lo);
%plot(av);
%pause;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Remove_Parallel_Region(BW2)
Description: Receive binary image with one blob (input: BW2): If the blob have more then one parallel regions in the horizontal axis, all but the thickest of these regions is deleted (other word if some line of the blob have more than two edges remove all but the edges that form thickest region.). The blob with deleted region is return as binary image (output: BW2)
%}
