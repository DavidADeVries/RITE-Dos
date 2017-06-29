function[image_sum,nCINEfiles,CAX,goodimages_numbers,badimages_numbers,example_cine]=EPID_prepare_5(EPID_folder)
% This script takes a directory of EPID cine images, and:
% -eliminates the first 2 cines, which are always (unit 9, all energies, all
% resolutions) 'bad' (mean CAX value very different from subsequent ones)
% -eliminates any other ones which are also 'bad' (for different imaging
% parameters, these initial bad ones are anywhere between 2-10)
% -removes flood field (FF) used at imaging time
% -adds a new FF taken through 20cm of water
% -sums all cines together



range=1;


% -------------------------------------------------------------------------
% UNCOMMENT IF YOU WANT IMAGES AND PROFILES OF THE FLOOD FIELD IMAGES

% flood_all_min=min([flood_00cm(:);flood_20cm(:)]);
% flood_all_max=max([flood_00cm(:);flood_20cm(:)]);
% flood_profiles_min=min(min([flood_00cm(:,256);flood_20cm(:,256)]),min([transpose(flood_00cm(192,:));transpose(flood_20cm(192,:))]));
% flood_profiles_max=max(max([flood_00cm(:,256);flood_20cm(:,256)]),max([transpose(flood_00cm(192,:));transpose(flood_20cm(192,:))]));
% 
% figure; imagesc(flood_00cm); axis equal; axis tight; title('Flood Field used during image acquisition'); colorbar; colormap('bone'); %set(gca, 'CLim', [flood_all_min flood_all_max]); 
% figure; 
% if size(flood_00cm,2)==512
%     plot(1:512,flood_00cm(192,:),'.-',((1:384)+64),flood_00cm(:,256),'.-'); xlim([0 512]); %ylim([flood_profiles_min flood_profiles_max]);
% elseif size(flood_00cm,2)==1024
%     plot(1:512*2,flood_00cm(192*2,:),'.-',((1:384*2)+64*2),flood_00cm(:,256*2),'.-'); xlim([0 512]); %ylim([flood_profiles_min flood_profiles_max]);
% end
% title('Flood field profiles (0cm)'); legend('cross-plane','in-plane','location','north')
% 
% figure; imagesc(flood_20cm); axis equal; axis tight; title('New Flood Field image (20cm depth)'); colorbar; colormap('bone'); %set(gca, 'CLim', [flood_all_min flood_all_max]); 
% figure; 
% if size(flood_20cm,2)==512
%     plot(1:512,flood_20cm(192,:),'.-',((1:384)+64),flood_20cm(:,256)','.-'); xlim([0 512]);  %ylim([flood_profiles_min flood_profiles_max]);
% elseif size(flood_20cm,2)==1024
%     plot(1:512*2,flood_20cm(192*2,:),'.-',((1:384*2)+64*2),flood_20cm(:,256*2)','.-'); xlim([0 512*2]);  %ylim([flood_profiles_min flood_profiles_max]);
% end
% title('New flood field profiles (20cm)'); legend('cross-plane','in-plane','location','north')
% -------------------------------------------------------------------------

cd(EPID_folder);
CINEfilenames1=dir('SPI*.dcm');  %Make List of dicom filenames in folder
CINEfilenames2=dir('RI*.dcm'); 
CINEfilenames=[CINEfilenames1; CINEfilenames2];
nCINEfiles=length(CINEfilenames);
names = {CINEfilenames.name};
bs = cellfun(@(name) double(dicomread(char(name))), names, 'UniformOutput', 0);
% bs = cell2mat(bs);
assignin('base','bs',bs);
CAX = cellfun(@(b) mean2(b(189:196,253:260)), bs);
% for i=1:size(CINEfilenames,1)
%     name=CINEfilenames(i).name;
%     b=dicomread(name);
%     b=double(b);
%     CAX(i)=mean2(b(189:196,253:260));
%     
% end
assignin('base','CAX',CAX)
b=bs{1};
image_sum = zeros(size(b));

% here we want to throw out the first 2 cines, always. If have only 4 cines,
% I'll keep the next 1 or 2. If I have more than 4, I'll throw out also all the
% "bad" ones

if nCINEfiles==1
    goodimages_indeces=[1];
elseif nCINEfiles==2
    goodimages_indeces=[0 1];
elseif nCINEfiles==3
    goodimages_indeces=[0 0 1];    
elseif nCINEfiles==4
    goodimages_indeces=[0 0 1 1];
else
    % Find images that are "bad" i.e. have mean CAX that is outlier. In EPID cine
    % imaging this is often the case for the first 2-8 images, depending on imaging
    % parameters.
    goodimages_indeces=CAX>(mean(CAX)-range*std(CAX))& CAX<(mean(CAX)+range*std(CAX));
    goodimages_indeces(1:2)=0; % never keep the first 2 cines
end

goodimages_numbers=find(goodimages_indeces);
badimages_numbers=find(~goodimages_indeces);

% figure; 
% plot(goodimages_numbers,CAX(goodimages_numbers),'go',badimages_numbers,CAX(badimages_numbers),'rx');
% legend('accepted','rejected','location','southeast')
% title('Mean CAX value for cine images of beam')

sum = zeros(size(b));
for i=goodimages_numbers
    name=CINEfilenames(i).name;
    b=dicomread(name);
    b=double(b);
    sum=sum+b;
end
average=sum/size(goodimages_numbers,2);



for n=1:nCINEfiles
        % if this is one of the bad images, substitute it with the mean of the
        % good ones
    if any(n==badimages_numbers)
        image_asis=average;
       % Otherwise, proceed!
    elseif any(n==goodimages_numbers)
            currentfilename=CINEfilenames(n).name;
            image_asis=dicomread(currentfilename);
            image_asis=double(image_asis);
    end

            if n==1
                if size(image_asis,2)~=1024
                    sprintf('Image is FULL RES (1024x768)');
                elseif size(image_asis,2)~=512
                    sprintf('Image is HALF RES (512x384)');
                end
            end

          % -------------------------------------------------------------------------
        % PLOT THE RAW CENTERMOST CINE FRAME
            if n==round(nCINEfiles/2)
                example_cine=image_asis;
                if size(example_cine,2)==512
                %figure; imagesc(example_cine); axis equal; axis tight; title('middle cine "as is"'); colorbar; colormap('bone')
                %figure; plot(1:512,image_asis(192,:),((1:384)+64),example_cine(:,256)); xlim([0 512]); title('"as is" profiles (a.u.)'); legend('cross-plane','in-plane','location','north');xlabel('pixels');
                %% UNCOMMENT THIS IF YOU WANT TO SEE DIAGONAL PROFILES
                % x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg]=improfile(image_asis,x,y);
                % x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos]=improfile(image_asis,x,y);
                % %figure; plot(-14.16284:0.073916228:14.16284,ProfDiagNeg,-14.16284:0.073916228:14.16284,ProfDiagPos);
                % legend('- profile','+ profile','location','north'); title('"as is" diagonal profiles (a.u.)'); xlabel('Distance from isocenter (cm)');
                clear x y cx cy ProfDiagNeg_image_sum ProfDiagPos_image_sum 
                end
                if size(example_cine,2)==1024
                %figure; imagesc(example_cine); axis equal; axis tight; title('middle cine "as is"'); colorbar; colormap('bone')
                %figure; plot(1:1024,example_cine(384,:),((1:768)+128),example_cine(:,512)); xlim([0 1024]); title('"as is" profiles (a.u.)'); legend('cross-plane','in-plane','location','north');xlabel('pixels');
                clear x y cx cy ProfDiagNeg_image_sum ProfDiagPos_image_sum 
                end
            end
        % -------------------------------------------------------------------------

        % -------------------------------------------------------------------------

        % SET THE ZERO
        image_rescaled=-(image_asis-(2^14-1));
            if n==round(nCINEfiles/2)
                if size(image_asis,2)==512
                %figure; imagesc(image_rescaled); axis equal; axis tight; title('EPID image rescaled'); colorbar; colormap('bone')
                %figure; plot(1:512,image_rescaled(192,:),'.-',((1:384)+64),image_rescaled(:,256),'.-'); xlim([0 512]); title('EPID image rescaled'); legend('cross-plane','in-plane')
                end
            end

        % REMOVE FLOOD FIELD CORRECTION FROM EACH EPID IMAGE TO OBTAIN "RAW" IMAGE
        % (NOTE: DARK FIELD CORRECTION REMAINS)
            if n==round(nCINEfiles/2)
                if size(image_asis,2)==512
                %figure; imagesc(image_rescaled_FFcorrOFF); axis equal; axis tight; title('Rescaled and FF correction removed'); colorbar; colormap('bone')
                %figure; plot(1:512,image_rescaled_FFcorrOFF(192,:),'-',((1:384)+64),image_rescaled_FFcorrOFF(:,256),'-'); xlim([0 512]); title('Rescaled and FF correction removed'); legend('cross-plane','in-plane')
                end
            end

        % ADD A new FLOOD FIELD CORRECTION
        % (NOTE: THIS flood_new IS ACQUIRED AT a certain DEPTH in SW)
            if n==round(nCINEfiles/2)
                if size(image_asis,2)==512
                %figure; imagesc(image_rescaled_FFcorrOFF_FFNEWcorrON); axis equal; axis tight; title('New FF correction added'); colorbar; colormap('bone')
                %figure; plot(1:512,image_rescaled_FFcorrOFF_FFNEWcorrON(192,:),'-',((1:384)+64),image_rescaled_FFcorrOFF_FFNEWcorrON(:,256),'-'); xlim([0 512]); title('New FF correction'); legend('cross-plane','in-plane')
                end
            end

        % CONCATENATE THIS IMAGE INTO THE IMAGE SUM    
        image_sum = image_sum + image_rescaled;

    

end


% ALWAYS WANT FINAL ANSWER IN HALF RES TO MAKE IMAGES LIGHTER
if size(image_sum,2)==1024
    image_sum=imresize(image_sum,0.50);
end

% PLOT FINAL IMAGE AND ITS PROFILES
%figure; imagesc(image_sum); axis equal; axis tight; title('Cine sum, rescaled, FF removed, new FF'); colorbar; colormap('bone')
%figure; plot(1:512,image_sum(192,:),((1:384)+64),image_sum(:,256)); xlim([0 512]); title('final profiles (a.u.)'); legend('cross-plane','in-plane','location','best');xlabel('pixels'); 
% UNCOMMENT THIS IF YOU WANT TO SEE DIAGONAL PROFILES
% x = [65 448]; y = [1 384]; [cx,cy,ProfDiagNeg_image_sum]=improfile(image_sum,x,y);
% x = [65 448]; y = [384 1]; [cx,cy,ProfDiagPos_image_sum]=improfile(image_sum,x,y);
% %figure; plot(-14.16284:0.073916228:14.16284,ProfDiagNeg_image_sum,-14.16284:0.073916228:14.16284,ProfDiagPos_image_sum);
% legend('- profile','+ profile','location','South'); title('Pre-processed diagonal profiles (a.u.)'); xlabel('Distance from isocenter (cm)');
clear x y cx cy ProfDiagNeg_image_sum ProfDiagPos_image_sum 
cd ..
