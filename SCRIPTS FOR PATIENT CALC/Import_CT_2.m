function [A] = Import_CT_2

CTfilenames=dir('CT*.dcm');  %Make List of "CT" filenames in folder
nCTfiles=length(CTfilenames); %Number of dicom files in folder

A = zeros(512,512,nCTfiles);
n = 1;
lowerb=0;
upperb=1001;

h = waitbar(0,'Please wait...');

for i=1:nCTfiles
    currentfilename=CTfilenames(i).name;
    m=dicomread(currentfilename);
    A (:,:,i) = m;
    i
    waitbar(i/(nCTfiles-2))
end

% if it comes from SIM 2, I want to do a R-L flip so that the final image
% matches the geometry seen in Eclipse
info=dicominfo(currentfilename);
if strcmp(info.StationName,'HOST-7103')==1 %SIM2
    A=flipdim(A,2);
end

    A=flipdim(A,3);

delete(h)

figure('KeyPressFcn',@figScroll);

    function figScroll(src,evnt)
  if strcmp(evnt.Key,'q')
      upperb = upperb +30;
  elseif strcmp(evnt.Key,'a')
      upperb = upperb -30;
  elseif strcmp(evnt.Key,'w')
      lowerb = lowerb +30;
  elseif strcmp(evnt.Key,'s')
      lowerb = lowerb -30;
  elseif strcmp(evnt.Key,'leftarrow')
      n = n-1;
  elseif strcmp(evnt.Key,'rightarrow')
      n = n+1;    
  end
  
  if lowerb>upperb
      lowerb = upperb-1;
  end
  
  imshow(A(:,:,mod(n,nCTfiles)+1),[lowerb upperb],'InitialMagnification','fit');
  drawnow
end %figScroll
end