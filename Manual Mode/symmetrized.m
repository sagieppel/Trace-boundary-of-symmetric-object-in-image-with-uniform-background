function [BW3,symmetry_score]=symmetrized(BW2,Symmetry_Mode)
%Preform two functions of improving object Edges

% take binary BW2 image containing the full area of the object marked in ones on the image
% lines in which there more then two border point to the image (hence to
% paprallel untouched region are reduced by choosing the broadest region and remove the rest

%2) Symmetrized object (optional only if Symmetry_Mode!=0)
% take binary image containing close contour of some object and find its
% symmetry axes along the Y axes and then arrange the object edges such
% that they are all completely symmetric according to this axis
% take object edge image in black and white BW2  and use symmetry
% consideration to improve its edge accuracy
% the symmetry axes is found by taking the average of the x values pair of points
% in the same line (if line  have more then two points the function peak
% one per of point) and the x value that appear most as average is the
% estimated symmetry axes
% every per of point that is average not fall on symmetry axes is adjust by
% replacing one of the two points (the one farther away in term of x value
% from the expected value according to the closest symmetric line
% create its lenghh is the figure hight  is with is two  the left and right
% boundary of each line

%Symmetry_Mode is optional paramter that as to the mode the  system will choose the the correct point (if two points in a line does not have center in the symmetry axis) Mode one by the point closest to the x value of the boundaries of the closest  correct line
%if Symmetry_Mode have value of zero then the function does not symmetrized the object but only remove parallel regions
if (nargin<2) Symmetry_Mode=2; end;

d = size(BW2);% get image dimension

%find image baundary end center for every line put them in arrays bn for
%left and right edges and av for center the index of the arrays is the y
%value this fucntiona have to variant were a is the best
[bn,av]=Found_Center_and_edges(BW2); %%1) Remove parallel regions (leave only two edge point in each line) and found center of every line
%----------------------------------------------identify center of symmetry axes-------------------------------------------------------------------------
% create center point histogram and found the most frequent value of the
% av array assume this values is the center of symmetry 
% Most frequent values in array
[cent,score_cent]=mostfrequentvalue(av);% most frequent value in av is the image center according to max vote

symmetry_score=score_cent/d(1); % what fraction of the line have their center on the symmetry axes is the measure of accuracy of the image recognition
BW2(:,cent)=2;% draw the center of symmetry on the axes not essential just for presentation
%imshow(BW2,[]);

%-----------------------------------------------------check level of symmetry and send error if symmetry is low ------------------------------------------------------------------------

%if (score_cent<20 || score_cent<d(1)/10)
 %   warning=score_cent/d(1);% the structure is not as symmetric as it should be give worning
%else warnning=0;

%------------adjust image symmetry according to the found symmetry axis
if Symmetry_Mode==1
        bn=adjust_symmetry_axis1(bn, cent, av); % when line does not have center in symmetry axis chose one of the line edges according to which is closer (in term of distance from the center) to the edge of the closest correct line
elseif Symmetry_Mode==2
    bn=adjust_symmetry_axis2(bn, cent, av); % when line does not have center in symmetry axis chose one of the line edges according to which is closer (in term of distance from the center) to the  average of the two closest correct lines (above and below)
end % if symmetry mode is zero dont adjust symmetry
%-----------------------------------------------------draw the new symmetry the structure according to the bn edge points------------------------------------------------------------------------
BW3=zeros(d);
for fy=1:1:d(1)
    for fx=bn(fy,1):1:bn(fy,2)
        if (fx>0 && fx<=d(2) ) 
            BW3(fy,fx)=1; % if the boundary are outside the image 
        else % if the boundary exceed the image  as result of the symmetry making mirror image to the point
            symmetry_score= symmetry_score*(d(1)-3)/d(1); % reduce score 
          yy='error boundary exceed image limits this image is damaged'
        end
    end;
end;
%imshow(lo);
%--------------------------------------------------------------------------------------------------
BW3=openim(BW3); %delete noise in the new seymmetrize image important don delete
%imshow(BW3);
%-------------------------------------------------------
 %BW3 = bwmorph(BW3,'remove');% remove blobe interior and leave edges
%imshow(BW3);
%pause;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bn,av]=Found_Center_and_edges(BW2)
%%find two points in each line (y value) that will be the the line
%left and right edges and put them in bn and find the average of this point and put it in
%av do so for ecery line
% if line have more then two edges choose the edges of the broadest region
% on the line


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
                
 %-----------------------------------------------------------------------------------          
av=zeros(d(1),1);% average array for the center of evert line (the average x of the two lines)
lo=zeros(d);% VIEW PORPUSE the edge image use for showing the new edges have no practical value
% find the average of the two edge points
for fy=1:1:d(1)
              av(fy)=round((bn(fy,2)+bn(fy,1))/2);% create array of average for each line based on the 3 edge point.
            lo(fy,round(av(fy)))=1;lo(fy, bn(fy,2))=1;lo(fy, bn(fy,1))=1;%VIEW PORPUSE the edge image use for showing the new edges. have no practical value FOR PRSENTETIOM ONLY
end
 

%imshow(lo);
%plot(av);
%pause;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
function [bn,av]=findboundaryandcenter2(BW2) % find boundary according to min and max x values worst method dont use
%find two points in each line (y value) that will be the the line
%left and right edges and put them in bn and find the average and put it in
%av do so for ecery line

% the edge point are the smallest and largest x value of every line
% bn array of the two edges in x term of every line av the center point of
% each line
 d = size(BW2);% get image dimension
    %find image baundary end center for every line
bn=zeros(d(1),2);% the edge array cotaining the x values of the two edges for every line (y value)
for fy=1:1:d(1)% scan every line y
    pb=0;
     bn(fy,1)=0; bn(fy,2)=0;% initialize the edges of line y
    for fx=1:1:d(2) % scan along the line x values
       
        if (BW2(fy,fx)==1)
           
            if pb==0
               bn(fy,1)=fx;
                 pb=1;
            else
                    bn(fy,2)=fx;
         
            end
        end
    end
end

                
 %-----------------------------------------------------------------------------------          
av=zeros(d(1),1);% average array for the center of evert line (the average x of the two lines)
lo=zeros(d);% the edge image use for showing the new edges have no practical value
% find the average of the two edge points
for fy=1:1:d(1)
              av(fy)=round((bn(fy,2)+bn(fy,1))/2);% create array of average for each line based on the 3 edge point.
              lo(fy,round(av(fy)))=1;lo(fy, bn(fy,2))=1;lo(fy, bn(fy,1))=1;% the edge image use for showing the new edges have no practical value
end
 

imshow(lo);

plot(av);

end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function [cent,score_cent]=mostfrequentvalue(av)
 %find the most frequent value in av this function preform the same job of
 %matlabe mode function which also return the most frequent value but it
 %also give score to the most frequent value and the histogram of the
 %histogram of frequency which could be usefull for some stuff
%----------------------------------------------identify center of symmetry axes-------------------------------------------------------------------------
% create center point histogram and found the most frequent value of the
% av array assume this values is the center of symmetry 
% Most frequent values in array
d=size(av);
avhist=zeros(round(max(av))+1,1);
for fy=1:1:d(1)
    avhist(round(av(fy)))= avhist(round(av(fy)))+1;
end;

%plot(avhist);% plot center point histogean


cent=find(avhist==max(avhist),1,'first'); % estimate center according to max vote // the most frequent value
score_cent=max(avhist);% max counted votes

%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------------------------------------------------------------------------------------------------------------
function bn=adjust_symmetry_axis1(bn,cent, av)
%this fucntion get an array of points per bn their symmmetry cn and array
%of the center between each two point av=(bn(:,1)+bn(:,2))/2 any per of
%points which their center av does not lay on the symmetry axes are
%adjusted by deleting one of the point and replacing it by mirror image of
%the second point 
if nargin==2 % if only two argument in input
    av=(bn(:,1)+bn(:,2))/2;
end;

Per=find(av~=cent);%list point pairs their center is not the symmetry axis and need to be adjusted
Pc=find(av==cent);% list of all point pairs that their center is the symmetry axis
Ler=size(Per);
maxx=max(bn(:,2));
for f=1:1:Ler(1)% symmetrized the structure around cent line by line scan all lines that their center fall outside symmetry axis
     if (bn(Per(f),2)<=cent)% the higher border is lower then the symmetry axes get read of it
         bn(Per(f),2)=cent+cent-bn(Per(f),1);
     elseif (bn(Per(f),1)>=cent)
          bn(Per(f),1)=cent+cent-bn(Per(f),2);% the lower border is higher then the symmetry axes get rid of it
     elseif (cent+cent-bn(Per(f),1))>maxx % if the mirror point of the small edge is out side the image boundary used the large edge
          bn(Per(f),1)=cent+cent-bn(Per(f),2);
     elseif cent+cent-bn(Per(f),2)<1 % if the mirror point of the higher edge smaller then the image lower boundary use the higher point
          bn(Per(f),2)=cent+cent-bn(Per(f),1);% 
     else
         Clp=abs(Pc-Per(f));% find the distance of lines to the correct point 
         tp=Pc(find(Clp==min(Clp),1,'first'));% find point in the correct line closest in term of Y value to the wrong line
         if  ((abs(abs(cent-bn(tp,1))-abs(cent-bn(Per(f),2))))<(abs(abs(cent-bn(tp,1))-abs(cent-bn(Per(f),1)))))% use the point closer to the closest correct line point
              bn(Per(f),1)=cent+cent-bn(Per(f),2);
         else
             bn(Per(f),2)=cent+cent-bn(Per(f),1);
             
            
         end;
     end;
             
             
end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bn=adjust_symmetry_axis2(bn,cent, av)
%this fucntion get an array of points per bn their symmmetry cn and array
%of the center between each two point av=(bn(:,1)+bn(:,2))/2 any per of
%points which their center av does not lay on the symmetry axes are
%adjusted by deleting one of the point and replacing it by mirror image of
%the second point 
if nargin==2 % if only two argument in input
 av=(bn(:,1)+bn(:,2))/2;
end;


Per=find(av~=cent);%list point pairs their center is not the symmetry axis and need to be adjusted
Pc=find(av==cent);% list of all point pairs that their center is the symmetry axis
Ler=size(Per);
maxx=max(bn(:,2));

for f=1:1:Ler(1)% symmetrized the structure around cent line by line go over all the incorrect lines that  their center dont lie on the symmetry axes
     if (bn(Per(f),2)<=cent)% the higher border is lower then the symmetry axes get read of it
         bn(Per(f),2)=cent+cent-bn(Per(f),1);
     elseif (bn(Per(f),1)>=cent)
          bn(Per(f),1)=cent+cent-bn(Per(f),2);% the lower border is higher then the symmetry axes get rid of it
     elseif (cent+cent-bn(Per(f),1))>maxx % if the mirror point of the small edge is out side the image boundary used the large edge
          bn(Per(f),1)=cent+cent-bn(Per(f),2);
         
     elseif cent+cent-bn(Per(f),2)<1 % if the mirror point of the first edge smaller then the image lower boundary use the higher point
          bn(Per(f),2)=cent+cent-bn(Per(f),1);% 
     else
         Clp=(Pc-Per(f));% create array of the distance of the all correct lines to the current lines the distance are negative if the lines are below the correnct line and positive if above 
         Clp2=-Clp;% create array with opposite sign of distances
         Clp(Clp>0)=100000;% all lines which are above the coorect line are given large distance and hence ignored when minimum distance will be searched
         Clp2(Clp<0)=100000;% all lines which are below the coorect line are given large distance and hence ignored  when minimum distance will be searched
         
         tp=Pc(find(Clp==min(Clp),1,'first'));% find point in the correct line closest in term of Y value to the wrong line which lays above the correct lines
         tp2=Pc(find(Clp2==min(Clp2),1,'first'));% find point in the correct line closest in term of Y value to the wrong line which lays below the correct lines

         predictpoint=(bn(tp,1)*min(Clp2)+bn(tp2,1)*min(Clp))/(min(Clp2)+min(Clp));%find the x values of point between the two closest correct lines edges  by averaging first x edges of the correct poin (bn(tp1/2,1) and their distance from the correct point 
         if  ((abs(abs(cent-predictpoint)-abs(cent-bn(Per(f),2))))<(abs(abs(cent-predictpoint)-abs(cent-bn(Per(f),1)))))% use the point closer to the closest the predictive location of the border based on the two closaest  correct lines above and below 
              bn(Per(f),1)=cent+cent-bn(Per(f),2);
         else
            
             bn(Per(f),2)=cent+cent-bn(Per(f),1);
             
            
         end;
     end;
             
             
end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
symmetrized(BW2,Symmetry_Mode)
Description: Get binary image with one blob. Find its most likely symmetry axis for the blob. Adjust the blob boundaries so it will be completely symmetric around this symmetry axis. Found the image symmetry level (fraction of lines that were symmetrized around this line.
Input: BW2: Binarry image containing one blob to be symmetrized. Symmetry_Mode (optional parameter): The method that will be used to symmetrized the image. Symmetry_Mode =1 if a given line in the blob does not have center in the symmetry axis: Replace the either the left or right edge of this line depending on which edge is farther away from the edge of the closest line that center around the symmetry axis.
Symmetry_Mode =2 (default). 1 1 if a given line in the blob does not have center in the symmetry axis: Replace the either the left or right edge of this line depending on which edge is farther away from the average of the two closest edges (above and below) of the closest lines that have center in the symmetry axis.
OUTPUT BW3: Binary image of the blob in BW3 after it been symmetrized (all lines are center in the symmetry axis) symmetry_score: Basically symmetry level of the original blob in BW2. The fraction of lines in BW2 blob that have center in the symmetry axis
Algortihm:
Step 6-10 in the algorithm in section 7
6) The symmetry axis and symmetry level of the blob is found by scanning every line of the blob and finding its center x value for each line. The most abundant center value (x) for lines in the blob is taken as the symmetry axis.
7) The fraction of lines that have center in the symmetry axis is taken as the symmetry level of the blob that will later be used to calculate its score.
8) For each line in the blob that don’t have center in the symmetry axis change either the left or right boundary position of the line such that the new center of the line will be on the symmetry axis.
9) The resulting contour of the resulting blob could be used as output for the edges of the vessel in the image.
10) The symmetry level of the blob is used to score how good is the match of the blob to the vessel in the image.
%}
