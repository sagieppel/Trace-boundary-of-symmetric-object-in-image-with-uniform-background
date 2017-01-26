function [ vessel_cont, symmetry_score ,brxy , imborder , YaxisSize]=Find_Vessel_Contour(figurefilename, Symmetry_Mode, Npix, threshold, Segmentation_Mode)
%Identify object by sperating it from background
%  identify the vessel in color image readed from figurefilename, 
%resize the image size to so it will contain npix pixels without changing proportions, and use threshold  for the canny sobel operator operator
% Segmentation_Mode define wether objects/blobs will be recognize by 'BORDER_CANNY' mode wich mean using edges with close contours found by canny+sobel operators to segment the ima or by "THRESHOLD" mode finding areas with different  intenstiy using threshold for the grey image of the system   'BORDER_CANNY'  give  much better  results the 'THRESHOLD' method for most cases and used as difult
% Symmetry_Mode symmetry mode tell wether to use symmetry consideration (0 if not) and which mode (1-2) [see symmetrized function]


%general operation: use canny and soble to transform image into border image
% use blob labeling and image segementation to  to identifty the blob of
% the backgroud. Create negative of the background blob image so every that blob is
% not the background is white. choose the largest blob/region as representing the
% vessel. Use symmetry and thikness consideration and remove parallel regions to improve the vessel
% boundary
%Resize
%brxy are list of xy points of the borders point location on the image
%imborder is the original image (resize) with the object borders marked on the final image
close all;
symmetry_score=0;

if (nargin<2 ) Symmetry_Mode=2; end;
if (nargin<3) Npix=16000; end;
 if (nargin<4)   threshold=0.12; end;
 if (nargin<5)   Segmentation_Mode='BORDER_CANNY'; end;


i=imread(figurefilename);%'C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg');%DSC_0016.jpg
%-----------------------resize and adopt histogram------------------------
dm=size(i);% y*y/(nx/ny)=npix y= sqrt(npix*ny/nx)  ny=dm1 nx=dm2
YaxisSize=round(sqrt(Npix*dm(1)/dm(2)));
i2 = imresize(i, [YaxisSize NaN]);% 135 /NaN change the image so it will contain npix pixels
%figure, imshow(i2);
i3=rgb2gray(i2);
%figure, imshow(i3);
%i3=histeq(i3);% equalize intensity  histogram for complete image to create wider better intensiy range spectrum of intesinity and increase 
i3=adapthisteq(i3);% equalize histogram image intesnity region by region to prevent borders with low illumination  from being missed and leave open in the contour 
%figure, imshow(i3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SEGMENTATION STEP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------Segment image to close conours using canny sobel or intesnity threshold and return binary image----------------------------------------------------

if strcmp(Segmentation_Mode,'BORDER_CANNY')%find borders using combine canny and sobel edges were the sobel threshhold is between the canny high and low threshold
bw=canysobel(i3,threshold);% find border using combine canny sobel

elseif strcmp(Segmentation_Mode,'THRESHOLD')% segment by intensity threshold (work horribly dont use)
bw=binary_threshold(i3);% create binary image using threshold of greyscale i  much less efficient then canny sobel use one of the two to create binary sgemented image;
else
    disp('unrecogenize image segmentation mode in find vessel contour');
    exit();
end;
%----------------create binary image in which all regions which are not background are white blobs (background are segments in the image that touch the image outer edges------
%dilate;% dilute borders to seal punctore envelops optional)
bw=closeim(bw);% use to close morphological operation to seal the border nevelope % optional not  always good
bw=substract_background(bw); %segment the edge image. create blob image in which every part that correspond to bw background is
%black and every other part is white.
%----------------improve and resuce noise image by closing and openning operation------
 bw=openim(bw);% smoth  openning morpholigical operation that remove unnsseary point 
bw=closeim(bw);% smoth image by closing morphological operation
%---------------------------------------
blobs = Getimregions( bw ); % divide binary image bw to its region assuming and return the region found in in array blob that conain stuructures with information of each blob
% blobs is already shorted from big to small
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REMOVE PARALLEL REGIONS AND SYMMETRIZED LARGEST BLOB%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 %  for f=1:1:1%size(blobs)% show largest 
 f=1; % use only the largest blob
     if ~isempty(blobs) && blobs(f).Area>900% if there blobs that there size bigger then 1000 use them else no object as been found
        
  %   imshow(blobs(f).Image);% show the specific blob image

     %------------show blob  edges--------------------------
        %  BW2 = bwmorph(blobs(f).Image,'remove');% remove blobe interior and live edges
%imshow(BW2)


     %----mark blob on full image---FOR PRSENTATION  ONLY---------------------------------------
     j=i3/3;
     j(blobs(f).PixelList(:,2),blobs(f).PixelList(:,1))=i3(blobs(f).PixelList(:,2),blobs(f).PixelList(:,1));
  %   imshow(j);% mark blob image in figure
%pause;
 %----cut the image area from i3 and pot it on kk. THIS PART OFTEN GOT STUCK and is needed only for symmetrized with sobel hence symmetrized3,4-----------------------------------------

           miny=min(blobs(f).PixelList(:,2));% find the location of the blob square on the total image important and being use later dont delete
           minx=min(blobs(f).PixelList(:,1));% find the location of the blob square on the total image important and being use later dont delete
      %{
      kk=zeros(miny,minx);
           kk(blobs(f).PixelList(:,2)+1-miny,blobs(f).PixelList(:,1)+1-minx)=i3(blobs(f).PixelList(:,2),blobs(f).PixelList(:,1));
           imshow(kk/255);% mark blob image in figure
 }%

 
    % isob=kk;% create image of the region that will be used for sobel operator in symmetrized 3,4
%}
           
  %----------------------Remove Parallel area in the blob-------------------------------------------------------------------------------------------------
         BW3=Remove_Parallel_Region( blobs(f).Image);% if the blob contain  lines with more then one region  (more then two edges) remove all but the broadest image
        
         
         blobs2 = Getimregions(BW3 );%  the vessel blob size might have breaked to few blobs take the first (hence the largest blob).
         miny=miny-1+min(blobs2(1).PixelList(:,2));% Update the location of the blob frame in the image of the system
         minx=minx-1+min(blobs2(1).PixelList(:,1));
         
 %--------------use symmetry and varius of rules to improve borders also remove thin area parrallel to thick area that correspond to the stand poll-----------------------------------------------------------------------------------------------
      %    imshow(blobs2(1).Image);
    
         
         [BW3,symmetry_score]=symmetrized(blobs2(1).Image, Symmetry_Mode);% Remove parrallel regions and symmetrized; adjust object border using symmetry configuration
%imshow(BW3);

%----------------------------------------------the symmetrized operation might split the blobs in this case peak the largest blob and use it ----------------------------------------------------------------------------------------------
 blobs2 = Getimregions( BW3 );%  the vessel blob size might have changes take the first (hence the largest blob).
 
 %---------------erode blob by one pixel and get is binary edge image (the erosion is needed because for some reason the blob is one pixel larger the it shouuld be
 vessel_cont= bwmorph(blobs2(1).Image,'remove');% remove blobe interior and leave edges;
 vessel_cont=blobs2(1).Image- vessel_cont; % for some unclear reason the contour received here is one pixel larger then it should be it need to b eroded
 vessel_cont=openim(vessel_cont);
 vessel_cont= bwmorph( vessel_cont,'remove');% remove blobe interior and leave edges;
 minx=minx-1; % Again not clear why but this is needed
 %imshow( vessel_cont);
 if ~exist('vessel_cont','var') vessel_cont=0;symmetry_score=-1000; end; % in case the previous function will fail to give output and get the entire program stuck
  %-----------------------------find the edge points of the vessel  on the total image and mark them--------------------------------------------------------------------------------------------------------------- 
  miny2=min(blobs2(f).PixelList(:,2));% find the location of the blob square on the total image important and being use later dont delete
 minx2=min(blobs2(f).PixelList(:,1));% find the location of the blob square on the total image important and being use later dont delete
 
 brxy=find2(vessel_cont,0.5); % find the border point of the the blob image

 
brxy(:,1)=brxy(:,1)+miny+miny2-2;% translate the border points according to the blob location realtive to the figure 
brxy(:,2)=brxy(:,2)+minx+minx2-2;
%------------------for presentation only draw border on image----------------------------------------- 
imborder=set2(i3, brxy,255,0, 0);% draw the edge points on the new image in white or black
%imborder(vessel_cont>0)=255;? why not this
%imshow(imborder);
%pause;
 
 %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   

%imshow(BW3);
%-----------------------------------------------------------------------------------------------------------

%---------------------------show the edge over the real image
      %kk(BW3>0)=0;
    %figure, imshow(kk/256);% show the figure the blob refer to
  % pause;
     %----------------------------------------------------------------

    
   %---------------------------------------------------------------------------------------------------------------------------------------------------
  else % if no blob found that stand in minimimal demands 
       vessel_cont=zeros(2,2);% assign arbitary values to output to  prevent program from getting stuck as result of not assign paramters
       brxy=[1 1];
       symmetry_score=-100;
    
       imborder=zeros(size(bw));
       disp('NO CONTOUR FOUND or contour is to small in find contour');
  end;
  %-----------------------------------------------------------------------------------------------------------------------------------------------------------------

%end
%{
Find_Vessel_Contour(figurefilename, Symmetry_Mode, Npix, threshold, SegmentationMode)
Description: Found the boundaries of symmetric object in an image with uniform background.
Input: Figurefilename: The name +page of the image file.
Segementation_mode(optional parameter): The method that will be used to segment the image. Option Segementation_mode ='BORDER_CANNY' is a default mode and it will segment the image by using canny and sobel edges that form closed contours. Alternative segmentation is by Segementation_mode = ‘THRESHOLD’ which segment image using intensity threshold with OTSU limits this give bad result for transparent vessels.
Symmetry_Mode (optional parameter): The way in which the symmetry of the object will be adjusted. The values can be between 0 to 2. Value of 2 is default. Value of 1 give slightly different symmetry adjusting mode with almost same result as 2. Value of 0 mean no symmetry adjustment. The symmetry mode is explained in the function symmetrized.
Npix(Optional parameter): Max number of pixels in the image examined (Figurefilename) . If the image have more pixels then Npix then it will be resized to the size of Npix pixels while maintaining proportion. Note that large image (above16000) can take really long time and should be avoided. Threshold (optional parameter): The threshold that will be used in the canny/sobel edge detector in the segmentation step.
Output vessel_cont:Binary image of the object border with object boundaries marked white (1). Can be use as template for finding the object in other images (similar to X_TEMPLATE.tif Figure 1). symmetry_score: The symmetry level of the traced blob (fraction of lines in the original blob that have center in the blob symmetry axis). brxy: List of x,y coordniates of boundary of the object in the image (after the image were resize). imborder: The resized image with the boundaries of object marked on it (see IMarked [figure 1 section 1]). YaxisSize: The final size of the image Y axis in which the recognition where performed
Algortihm:
Basically steps 1-10 in the algorithm section in section 7:
1) Segment the image by looking for edges that form closed contours. The edges are found by combination of canny and sobel edges.
2) All blobs that touch the outer boundaries of the image are merged and considered as background.
3) The negative of the background (found in step 1) is taken. This negative is a binary image in which every pixel that is not background have value of 1 and every background pixel is zero.
4) This binary image is again segmented, and the largest blob is taken as the vessel.
5) If the blob have two parallel region in the horizontal axis the thinnest of the two is deleted (other word if some line of the blob have more than two edges remove all but the edges that form thickest region).
6) The symmetry axis and symmetry level of the blob is found by scanning every line of the blob and finding its center x value for each line. The most abundant center value (x) for lines in the blob is taken as the symmetry axis.
7) The fraction of lines that have center in the symmetry axis is taken as the symmetry level of the blob that will later be used to calculate its score.
8) For each line in the blob that don’t have center in the symmetry axis change either the left or right boundary position of the blob such that the new center of the line will be on the symmetry axis.
9) The resulting contour of the resulting blob could be used as output for the edges of the vessel in the image.
10) The symmetry level of the blob is used to score how good is the match of the blob to the vessel in the image.
%}
     