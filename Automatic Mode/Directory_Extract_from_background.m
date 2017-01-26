% for all image in the directory dirname extract object from background and
% save in the appropriate file its boundary in appropriate binary file inthe same directory 
% directory dirname and with name that include the file name and _boundary.tif
dirname='EXAMPLE IMAGES';% directory containin image to be used 
list = ls(dirname); % read all files in dirname
s=size(list);% number of files in list
Symmetry_Mode=2;% zero if you dont want to use symmetry (1 or 2 if you do  see symmetrized to what 1,2 mean) 1 is used as stadart altough its not neccessary better then 2
for f=1:s(1)% scan all files in dirname and look for jpg images
    if  ~isempty(strfind(list(f,:),'.JPG')) || ~isempty(strfind(list(f,:),'.jpg')) %list = ls(name) returns the files and folders in the current folder that match the specified name to list.
  Exctract_object_from_background([dirname '\' list(f,:)],'BORDER_CANNY',Symmetry_Mode);%Extract the vessel border in the image from back ground in the image: best segmentation mode is  based on borders 'BORDER_CANNY'  alternative segmentation mode is 'THRESHOLD'%  work horribly (this line when you assume symmetric object with respect to Y axis)
    %Exctract_object_from_background_NO_SCANNING([dirname '\' list(f,:)],0); % use this  when you dont assume the vessel is symmetrized
    end
end


%{
Directory_Extract_from_background: Script that perform the recognition process on every jpg file within given directory (the directory page is given in dirname in line 4 of the script). The output file will be created in dirname after the script finished (few minutes per file). See sections 1-6.
%}