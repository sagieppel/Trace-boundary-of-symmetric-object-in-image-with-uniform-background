function [Imarked,Itemplate,Iresize,Iborders,Y_img_size,Borders_XY]=Exctract_object_from_background_NO_SCANNING(filename,  Symmetry_Mode)  
% The Main function of extracting  vessel from background in the image filename
% Find the object borders no optimization of parameter or symmetry score used 
%for the same function with optimization see Exctract_object_from_background
% assume the object in on uniform background

%Iresize return and save the image of the vessel resize to optimal size in 
%Itemplate: boolean image of the object border with size of the object, with object borders marked white, use as template for finding the object in other fuctions
%Imarked same as I resize only with borders of object painted black
%Iborders bolean image of size of Iresize with all pixels wich are boreder marked white 1  and the rest black 0
%Y_img_size the final size of the image 
%Borders_XY array of the cordinates of all vessel border point in the final image (after resize)
% Symmetry_Mode symmetry mode tell wether to use symmetry consideration (0 if not) and which mode (1-2) see symmetrized function

if (nargin<2) Symmetry_Mode=0;end;% put zero if no symmetry is assumed
    
           threshhold=0.12;% standart Y value and threshold  vlaues of Find_Vessel_Contour    
           [  vessel_cont, symmetry_score, borderxy, imborder, YaxisSize ]=Find_Vessel_Contour(filename,Symmetry_Mode,16000,threshhold,'BORDER_CANNY'); % extract object from image after resizing it to y size and using canny threshold  of threshhold use 'BORDER_CANNY' segmentation mode for image (mode base on finding outer border of objects) return border of object found in image and its symmetry level of found object wich is the use to estimate accuracy
  
           %  imshow(vessel_cont);
             
               ysize=YaxisSize;% standart Y value and threshold  vlaues of Find_Vessel_Contour
               
               symmetry_score=symmetry_score^(1/(ysize+0.1));% the smaller the image the fewer x values there are for the x values to contain hence smaller pictures have unfair advatage
      
                  best_symmetry_score=symmetry_score;% if the result is best so far all its paramaters are saved
                  Itemplate=vessel_cont; % save the conotour of the object found in object size image
                  Imarked=imborder; % save the image were the vessel border are drawn in black  on the image  
                  Borders_XY=borderxy; % save the locations of the border on the final image as array of coordinates
                  Y_img_siz=ysize; % save the size of the image used
                  bestthresh=threshhold;% save the threshold
                  %imshow(Imarked);

close all;
%====================================================================================================================================
for (ff=length(filename):-1:1) % remove spaces from upper part of file
    if filename(ff)~=' ' 
        break;
    end;
end;
outname = filename(1:ff-4);%Get basic file name and path with no extension
outname% write the out put file name
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


Iborders=logical(zeros(size(Iresize)));% creat logical bool matrix in size of I resize with all zeros (black points)
Iborders=set2(Iborders,Borders_XY,1);
imwrite(Iborders,[outname '_BORDERS.tif']);
%---------------------------save parameters------------------------------------------------------------------------------------------------------

save([outname '_PARAMETERS'],'ysize' ,  'best_symmetry_score','bestthresh');
save([outname '_BORDERS_COORDINATES_ARRAY'],'Borders_XY');
%--------------------------------------------------------------------------------------------------------------------------------------

                  
end
          