% find something in DF FF images
clear all
 
%cd('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\DF_FF_images\20140815')

DCMfilenames=dir('MD*.dcm'); 
nDCMfilenames=length(DCMfilenames);
for i=1:nDCMfilenames
    currentfilename=DCMfilenames(i).name;
    image=dicomread(currentfilename);
    info(i)=dicominfo(currentfilename);
    DCMdescriptions{i}=info(i).RTImageDescription;
    DCMnames{i}=info(i).Filename;

end
clear currentfilename i image  nDCMfilenames DCMfilenames
DCMdescriptions=transpose(DCMdescriptions);
DCMnames=transpose(DCMnames);

%cd('..')