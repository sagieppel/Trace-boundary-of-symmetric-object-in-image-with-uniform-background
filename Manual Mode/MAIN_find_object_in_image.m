function [Isresize,Itmresize,Ismarked,Iborders,Ysizesys,Ysizeitm,ybest,xbest,Borders_XY, BestScore]= MAIN_find_object_in_image(Is,Itm,search_mode,border,tm_dilation,neg_corl)
%Use template matching or general hough transform to find template Itm in
%the image Is
%Itm is boolean border image of the vessel with border marked 1    %note that Itm is the output _TEMPLATE.tif of Exctract_object_from_background function
% change the image size and vessel countor size to various of ratios the
% image size changed from 100% to 10% of the structure in pixel jump
% scan by two methods 
%c1))shrinking the system image pixel by pixel until (line by line)
% it reach the size of the template (the template remain in it's original size'
% 2) resize the image of the template and for every size scan 
%search_mode is the way the recognition should occur could be 'template', 'template_angle' or 'hough'
% border: if use 'template' recognition border determine wether to match to  'sobel' or  to 'canny' of the system
%tm_dilation determine how much the template should be delated in the template mode 
% neg_corl  to balance random high score false positive in areas that dense with features it use negative correlation (negative template) in pixels adjecent to the Itm template could be 'out' for only the outside of the template or 'full' for both side or 'none'
% Isresize The system image in the size in which the template was match
% Itmresize The template image in the size were the best match size
%Ismarked The system image with the best match boder marked black upon it
%Ysizesys,Ysizeitm the y size of the recognized image
% ybest,xbest location on the image were the best match were found
%Iborders bolean image of size of Iresize with all pixels wich are boreder marked white 1  and the rest black 0
%Borders_XY array of the cordinates of all vessel border point in the final image (after resize)
%BestScore give the score of the match return wihch is also the best match found

if nargin<3
    mode='template';
end;
if nargin<4
    border='canny';%'sobel';
end;
if nargin<5
    Sitm=size(Itm);
tm_dilation=floor(sqrt(Sitm(1)*Sitm(2))/80);% in order to avoid the edge from missing correct point by dilation the size of dilation is proportinal to the size of the item template dimension.

   % tm_dilation=1;
end;
if nargin<6
    neg_corl='out'; %'full';%
end;
Itm=logical(Itm);% make sure Itm is boolean image

close all;
imtool close all;

%-----------------------------------------------resize system image-----------------------------------------------------------------------------------------------
Rst=4;% the maximal initial ration between the system image size and the vessel template
maxsysYsize=600; % maximal number of pixels in the Y axis of the system image if the system image larger then this resize it to maxsysYsize; 
St=size(Itm);
Ss=size(Is);
if (Ss(1)/St(1)>Rst && Ss(1)/St(1)>Rst); % if the system image is to big (more then Rst time compare to the vessel image resize it down to x time of vessel image x 
    Is=imresize(Is,[St(1)*Rst NaN]); 
end;
Ss=size(Is);% system image size
if (Ss(1)>maxsysYsize); % if the system image is to big (more then Rst time compare to the vessel image resize it down to x time of vessel image x 
    Is=imresize(Is,[maxsysYsize NaN]); 
end;
Is=rgb2gray(Is);
%figure,
%imshow(Is);
% pause;
%-----------------------------------------------Adapt system image intensity histogram (optional)---------------------------------------------------------------------------
%Is=histeq(Is);% equalize intensity  histogram for complete image to create wider better intensiy range spectrum of intesinity and increase 
%Is=adapthisteq(Is);% equalize histogram image intesnity region by region
%-----------------------shrink system image until it reaches vessel size and match each size to the unchanged vessel template--------------------------------------------------------------------
St=size(Itm);% object image size
Ss=size(Is);% system image size
%best_matchxy=struct('score',0,'size',0,'y',0,'x',0);% the first value is the score the second value is the fractional template/system size the third and for values are the x and y fractional  cordinates as fraction of maxx and maxy
scale=100;% scale of the system image in percentage decrease  within the loop as image is resized
BestScore=-1000; % best score found so far
ysize_sys=1;% when the match found mark the itm template image y size here, if zero vessel template itm image remain in original size
ysize_itm=1;% when the match found mark the system image y size here, if zero system image remain in original size
Itmresize=Itm; Ysizeitm=St(1);
while (St(1)<=Ss(1)*1 && St(2)<=Ss(2)*1)% as long as the vessel image smaller then system image
     
  
     %Isr=imresize(Is,[(Ss(1)-1) NaN]);  % resize to by one less Y line and proportinal x
     Isr=imresize(Is,scale/100);  % resize to in one percent less
      Ss=size(Isr);% find new system image size
       Szrat=St(1)/Ss(1); % size ratio between system  and template  size
     if strcmp(search_mode,'template')% the actuall recogniton step of the template in the resize image and return location of best match and its score can occur in one of three mode
         [score,  y,x ]=Template_match_vessel_extraction(Isr,Itm,neg_corl,border,tm_dilation, 1);% apply template matching here and return list of good points (x,y)and their scoring
     elseif strcmp(search_mode,'template_angle')
         [score,  y,x ]=Template_match_gradient_direction(Isr,Itm);
     elseif strcmp(search_mode,'hough')
         [score,  y,x ]=Generalized_hough_transform(Isr,Itm);
     end;
      Ss(1);
      
       scale=scale-0.5;
     %--------------------------if the corrent matching score is better then previous score use it template on image------------------------------------------------------
  if (score(1)>BestScore) % if item  result scored higher then the previous result
       close all;
       BestScore=score(1);% remember best score
       ysize_sys=Ss(1); %remmeber syste image size when the object is found
       ysize_itm=0;% this mean that the template item image size is not changed.
       Isresize=Isr;
       ybest=y(1);
       xbest=x(1);
       %..................................................................................................................................................................
  %Ismarked=imresize(Is,[ysize_sys, NaN]);
 
  
   % k =find2(Itm,1);

  %Ismarked=set2(Ismarked,k,0,ybest,xbest);
  %  figure, imshow(Ismarked);
%  pause();
  end;
 %-----------------------------------------------------------------------------------------------------------------------------------------------------------------
     
     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------shrink vessel edge image until it reach some minimal fraction of system image or minimal number of pixels and match each size to the unchanged system image-----------------------------------------------------------------------------------------------------------------------
 minrt=8;% minimal ratio of system to vessel
  minsize=100;% minimal number of pixel in vessel image
scale=100;
St=size(Itm);
Ss=size(Is);

while (Ss(1)/St(1)<minrt && Ss(2)/St(2)<minrt && St(1)*St(2)>minsize)
    
     scale=scale-0.5;
     %Isr=resize_border(Itm,St(1)-1, NaN);% scale one line less
     %Itr=resize_border3(Itm,St(1)-1, NaN);
     %Isr=resize_border(Itm,scale/100);% scale one perecent less
     Itr=resize_border3(Itm,scale/100);
     St=size(Itr);

     %Isr=imresize(Is,[(Ss(1)-1) NaN]);  % resize to by one less Y line and proportinal x
     if (St(1)>Ss(1) || St(2)>Ss(2)) continue; end;
     %[k1, k2] =find(Itm==1);
     %Isr(k1, k2)=1;
     if strcmp(search_mode,'template')% the actuall recogniton step of the template in the resize image and return location of best match and its score can occur in one of three mode
             [score,  y,x ]=Template_match_vessel_extraction(Is,Itr,neg_corl,border,tm_dilation, 1); %apply template matching here and return list of good points (x,y) and their scoring
     elseif strcmp(search_mode,'template_angle')
             [score,  y,x ]=Template_match_gradient_direction(Is,Itr);
     elseif strcmp(search_mode,'hough')
            [score,  y,x ]=Generalized_hough_transform(Is,Itr);
     end;
     St=size(Itr);% find new image size
     %--------------------------if the correct mark is better then previous mark use it template on image------------------------------------------------------
     if (score(1)>BestScore) % if item  result scored higher then the previous result
        close all;
           BestScore=score(1);% remember best score
           ysize_sys=0; %remmeber syste image size when the object is found
           ysize_itm=St(1);% this mean that the template item image size is not changed.
           ybest=y(1);% mark best location y
           xbest=x(1);% mark best location x
           %Isresize=Is; Itmresize=Itr; Ysizesys=Ss(1);,Ysizeitm=St(1); % write output paramters
       %....................................................mark item on image.............................................................................................................................................................................
  
 
          %Itr=resize_border3(Itm,ysize_itm, NaN);
          %k =find2(Itr,1);
          %Ismarked=set2(Is,k,0,ybest,xbest);
          %  figure, imshow(Ismarked);
        %    pause();
     end;
%-------------------------------mark best found location on image---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
        
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%show best and write best match optional part can be removed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ysize_sys==0% if system image size was not change only template size was changed
    Itr=resize_border3(Itm,ysize_itm, NaN);
            k =find2(Itr,1);
            Ismarked=set2(Is,k,255,ybest,xbest); 
            Iborders=logical(zeros(size(Is)));
       Iborders=set2(Iborders,k,1,ybest,xbest);
       Borders_XY=find2(Iborders,0.5);
           % figure, imshow(Ismarked);
          %  pause();
               Isresize=Is; Itmresize=Itr; Ysizesys=Ss(1);Ysizeitm=ysize_itm; % write output paramters note output paramters also writen when they are first found so this part done twice remove one

elseif ysize_itm==0% if match found by shrinking Is
        Isresize=imresize(Is,[ysize_sys, NaN]);
 
  
       k =find2(Itm,1);

       Ismarked=set2(Isresize,k,255,ybest,xbest);
       Iborders=logical(zeros(size(Isresize)));
       Iborders=set2(Iborders,k,1,ybest,xbest);
       Borders_XY=find2(Iborders,0.5);
       %figure, imshow(Ismarked);
       %pause;
        Itmresize=Itm; Ysizesys=ysize_sys;Ysizeitm=St(1); % write output paramters note output paramters also writen when they are first found so this part done twice remove one
    
    
else
    xxx='no match founded'
end;
end