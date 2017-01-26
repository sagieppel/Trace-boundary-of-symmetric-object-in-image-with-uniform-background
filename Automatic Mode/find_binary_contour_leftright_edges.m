function [y,x1,x2,np]=find_binary_contour_leftright_edges(BW)% 
%get binary contour image and create array with accending y order  in which
%the x1(f) and x2(f) are the left and right borders of the contour in lines
%y(f), assume only two points in each line/y value
% note the x1,x2,y share the same index.
%np number of lines found

 d = size(BW);% get image dimension
   
np=0;% the index of the arrays y,x1,x2
for fy=1:1:d(1)% scan every line y
    m=0;
    for fx=1:1:d(2) % scan along the line x values
        if (BW(fy,fx)==1)
        if (m==0) 
            np=np+1;
            x1(np)=fx;  x2(np)=fx; y(np)=fy; m=1;
        else
            x2(np)=fx;
        end
    end
    end
    
   %{
   for f=1:np
        BW(y(f),x1(f):1:x2(f))=1;
        imshow(BW);
        pause(0.01);
    end;
    %}
end