 % main function of extracting  vessel from back ground script
% scan the find vessel immagw with variuos of condtions and find the best borders
 % The main script for vessel extraction
% according to their level of symmetry return the image of the vessel
% resize to optimal size the image of the vessel with edge of the found
% vessel marked black.  Template of the vessel border binary, binary image
% in the size of the resize system image with the border as ones and all
% other points zero
% array with the location of all the border points in the vessel
clear all; % clear all variable from work space
best_symmetry_score=-100;
for threshhold=0.09:0.02:0.21
    for ysize=90:20:200
        disp('threshhold and ysize');
       threshhold
        ysize
       
           [  vessel_cont, symmetry_score, borderxy, imborder ]=find_vessel_contour('C:\Users\mithycow\Desktop\trial pictures glassware\edited\IMG_1401.jpg',2, ysize,threshhold);
           %'C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg', ysize,threshhold);
           %'C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor_cut\DSC_0048.jpg', ysize,threshhold); % result in error check this one
           %'C:\Users\mithycow\Desktop\trial pictures glassware\edited\IMG_1401.jpg', ysize,threshhold);
           %'C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg', ysize,threshhold);
             imshow(vessel_cont);
               %pause;
               symmetry_score=symmetry_score^(1/(ysize+0.1));% the smaller the image the fewer x values there are for the x values to contain hence smaller pictures have unfair advatage
               
             % how to solve  this advatage is not clear multipication in
             % the symmetry_score*sqrt(ysize) symmetry_score*ln(ysize+1) symmetry_score^1/(ysize) or given the value of
           %--------------------------------------------------------------------------------------------------------------------
              if (best_symmetry_score<symmetry_score) % the symmetry of the result is used to evaluate its quality 
                  best_symmetry_score=symmetry_score;% if the result is best so far all its paramaters are saved
                  bestborders=vessel_cont; % save the conotour image of the figure
                  bestimborder=imborder; % save the image were the vessel border is drawn of the image 
                  best_border=borderxy; % save the locations of the border on the final image 
                  bestysize=ysize; % save the size of the image used
                  imshow(bestimborder);
                %  pause;
              end
              %----------------------------------------------------------------------------------------------------------------
    end
end
close all;
%-----------------------------------------------------------------------------------------------------------------------------
i3=imread('C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg');
i3=rgb2gray(i3);
  i3=imresize(i3,[200, NaN]);
figure, imshow(i3);
%--------------------------------------------------------------------------------------------------------------------------------------
 %Ss2=size(i3);
   
 % Itm2=imresize(bestborders,[Ss2(1), NaN]);
%imshow(Itm2);
%pause;
%Itm2(Itm2>0)=1;
%imshow(Itm2);
%pause;
%k =find2(Itm2,1);
  %k(:,:)=k(:,:)+xy(1);
  % Ist=set2(i3,k,0);

   % imshow(Ist);
 %  pause;
  imshow(bestimborder);
                  pause;
 %----------------------------------------------------------------------------------------------------------------------------------------------------

                  figure, imshow(bestborders);
                  size(bestborders);
                  imwrite(bestborders,'C:\Users\mithycow\Desktop\vessel_outline.tif','tif');
          