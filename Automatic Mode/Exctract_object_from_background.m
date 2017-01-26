function [Imarked,Itemplate,Iresize,Iborders,Y_img_size]=Exctract_object_from_background(filename, Segmentation_Mode, Symmetry_Mode)  

% The Main function of extracting  vessel from background in the image filename
% scan various of canny threshold and image sizes and find the best vessels  borders in the image according to their level of symmetry 
% assume the object in on uniform background and symmeteric in respect to the Y axis

%INPUT
% Segmentation_Mode define wether objects/blobs will be recognize by 'BORDER_CANNY' mode wich mean segmenting using edges with close  contours found by canny+sobel operators (deafult mode). 
%Alternative segmentation is by "THRESHOLD"  for the sgementatiomn of grey image using intensity threshold with OTSU limits  'BORDER_CANNY'  give  much better  results the 'THRESHOLD' method for most cases and used as difult
% Symmetry_Mode symmetry mode tell wether to use symmetry consideration (0if not) and which mode (1-2)2 used as deafult altough 1 also give good results see symmetrized function 


%OUTPUT
%Iresize return and save the image of the vessel resize to optimal size in which the recogntion were perforemed 
%Itemplate: binary image of the object border  with object boundaries marked white (1). Can be use as template for finding the object in other images.
%The template size match the vessel size/shape in Iresize 
%Imarked same as Iresize only with the boundaries of object marked on the image (The  output file is filename_MARKED.tif)
%Iborders inary image of size of Iresize with all pixels wich are boreder marked white 1  and the rest black 0
%Y_img_size the final size of the image Y axis only
 
%for the same function without optimization see Exctract_object_from_background_NO_SCANNING
if (nargin<2)   Segmentation_Mode='BORDER_CANNY'; end;
if (nargin<3) Symmetry_Mode=2;end;% put zero if no symmetry is assumed
    
    best_symmetry_score=-100;
%---------------exctract object with varoious of thresholds and image size and peak the best result according to the level of symmtery it show
for threshhold=0.1:0.02:0.22% scan various of thresholds for edge detection in the segmentation part of the recogntion
    for ysize=200:20:340% scan the image in various of sizes to find the one that give best results
        %......................................
        disp('Scanning threshhold and ysize');
        disp(['file name' filename]);
        disp(['Edge detection threshold' num2str(threshhold)]);
        disp(['Resized image Y axis size' num2str(ysize)]);
        
       %............................................
           [  vessel_cont, symmetry_score, borderxy, imborder, YaxisSize]=Find_Vessel_Contour(filename,Symmetry_Mode, (ysize^2)/2,threshhold,Segmentation_Mode); % extract object from image after resizing it to y size and using canny threshold  of threshhold use 'BORDER_CANNY' segmentation mode for image (mode base on finding outer border of objects) return border of object found in image and its symmetry level of found object wich is the use to estimate accuracy
        
               ts=size(borderxy);
              % symmetry_score=symmetry_score*sqrt(ts(1));
             %  symmetry_score=symmetry_score^(1/ts(1)+0.1);% the smaller the image the fewer x values there are for the x values to contain hence smaller pictures have unfair advatage
               symmetry_score=symmetry_score*log(ts(1)*ts(2)+1); % the score of the current boundaries. If this score is better then previous results write it as best result  
             % the symmetry_score*sqrt(ts(1)) symmetry_score*ln(ysize+1) symmetry_score^1/(ysize) or given the value of
           %----------------------------------------check  the quality of the result and decide wether to keep or descard based pm its symmetry_score----------------------------------------------------------------------------
              if (best_symmetry_score<symmetry_score) % the symmetry of the result is used to evaluate its quality result will be saved only if its score is higher then previous best results
                  best_symmetry_score=symmetry_score;% if the result is best so far all its paramaters are saved
                  Itemplate=vessel_cont; % save the conotour of the object found use as template for recogntion of vessel in other images
                  Imarked=imborder; % save the image were the vessel border are marked  on the image  
                  Borders_XY=borderxy; % save the locations of the border on the final image as array of coordinates
                  Y_img_siz=YaxisSize; % save the size of the image used
                  bestthresh=threshhold;% save the threshold usedfor finding the edges
              %   figure, imshow(Imarked);
                %  pause;
              end
              %----------------------------------------------------------------------------------------------------------------
    end
end
close all;
%===============================================WRITE OUTPUT  FILES=====================================================================================
%outname= strrep(filename,' ','');% the file name contain many spaces whiec make it impossible to compare or use THIS CAUSE PROBLEM IF DIRECTORY NAME CONTAIN SPACES

for (ff=length(filename):-1:1) % remove spaces from upper part of file
    if filename(ff)~=' ' 
        break;
    end;
end;
outname = filename(1:ff-4);%Get basic file name and path with no extension
%outname= strrep(filename,'.JPG','');%REMOVE THE FILE EXTENSIOM
% write the out put file name
imwrite(Itemplate,[outname '_TEMPLATE.tif']);
imwrite(Imarked,[outname '_MARKED.tif']);

%-----------------------------------------------------------------------------------------------------------------------------
Iresize=imread(filename);
  Iresize=imresize(Iresize,[Y_img_siz, NaN]);
  Iresize=rgb2gray(Iresize);% change to grey since all coming function will use it as gray (and also to be consistent with template recognition output.
%Is=histeq(Is);% equalize intensity  histogram for complete image to create wider better intensiy range spectrum of intesinity and increase Adapt system image intensity histogram (optional)
%Is=adapthisteq(Is);% equalize histogram image intesnity region by region Adapt system image intensity histogram (optional)
imwrite(Iresize,[outname '_SYSTEM.tif']);
%-------------------------------------------------------------------------------------------------------------------------------
%Iresize=rgb2gray(Iresize);

Iborders=logical(zeros(size(Iresize)));% creat logical bool matrix in size of I resize with all zeros (black points)
Iborders=set2(Iborders,Borders_XY,1);
imwrite(Iborders,[outname '_BORDERS.tif']);
%---------------------------save parameters------------------------------------------------------------------------------------------------------

%save([outname '_PARAMETERS'],'ysize' ,  'best_symmetry_score','bestthresh');
%save([outname '_BORDERS_COORDINATES_ARRAY'],'Borders_XY');
%--------------------------------------------------------------------------------------------------------------------------------------

                  
end
%{
Exctract_object_from_background(filename, segmentation_mode ,Symmetry_Mode)
Description: Found the boundaries of symmetric object in an image with uniform background.
Input: filename: The name +location of the image files. Segementation_mode(optional parameter): The method that will be used to segment the image. Option Segementation_mode ='BORDER_CANNY' is a default mode and it will segment the image by using canny and sobel edges that form closed contours. Alternative segmentation is by ‘THRESHOLD’ which segment image using intensity threshold with OTSU limits, this give bad result for transparent vessels.
Symmetry_Mode (optional parameter): The way in which the symmetry of the object will be adjusted. The values can be between 0 to 2. Value of 2 is default value of 1 give slightly different symmetry adjusting mode with almost same result. Value of 0 mean no symmetry adjustment (for a symmetric). The symmetry mode is explained in the function symmetrized.
Output files: All output are given as both parameters and files in the directory of the input file see section 1 and figure 1 for details on output files.
Output parameters: Iresize: The input image (filename) in greyscale and resized to specific size that gave the best boundaries (The corresponding output file is filename _SYSEM.tif output files [Figure 1, Section 1]) Imarked: Same as Iresize only with the boundaries of object marked on the image (The corresponding to output file is filename_MARKED.tif [Figure 1, Section 1]) Iborders: Binary image of size of Iresize with all pixels correspond to the object boundaries marked white 1 and the rest marked black 0 (The corresponding file is filename_BORDER.tif [Figure 1, Section 1]). Itemplate: Binary image of the object border with object boundaries marked white (1). Can be use as template for finding the object in other images (The corresponding output file is filename _ TEMPLATE.tif [Figure 1, Section 1]). The template size match the vessel size/shape in Iresize. Y_img_size: The final size of the image Y axis (for images Iresize and Iborders).
Algortihm:
Scan various of threshold and sizes of for segmenting image in filename. The recognition itself done by Find_Vessel_Contour. This function scan Find_Vessel_Contour with various of different image size for the image in filename and with various of threshold for the edges in the segmentation step. It pick the best result based on the its symmetry score (symmetry of the contour found).
%}