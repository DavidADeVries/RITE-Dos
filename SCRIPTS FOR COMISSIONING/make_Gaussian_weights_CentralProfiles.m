% 6. GOING FROM S TO D WITH THE SUM OF 2 GAUSSIANS
clear w1 w2 w3 w4 w_cr_avg w_cr_tot w_cross w_in_avg w_in_tot w_in;
sprintf('START GAUSSIAN WEIGHTING')
SD1=1.7; % makes a Gaussian with SD=1.7pixels/0.523pixels/mm=3.2mm (Van Herk penumbras)
SD2=SD1*2; % makes a Gaussian 2x wider (VH penumbra at larger depths)
SD3=SD1*10; % makes a Gaussian 10x wider (scatter)
SD4=SD1*30; % makes a Gaussian 30x wider (scatter at larger depths)

x=1:1000;    m=(max(x)-min(x))/2+0.5;  

s1=SD1/.523; g1=gauss_distribution(x,m,s1);   
s2=SD2/.523; g2=gauss_distribution(x,m,s2);   
s3=SD3/.523; g3=gauss_distribution(x,m,s3);  
s4=SD4/.523; g4=gauss_distribution(x,m,s4); 

% -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

sprintf('CROSS-PLANE')
i=0;
for row=192%:193
    i=i+1;

%[w_cross,ConvRescaleFactor_cross]=Fit2GaussConv(epid(row,:)/trapz(epid(row,:)),eclipse(row,:),SD1,SD2,SD3,SD4);
[w_cross,ConvRescaleFactor_cross]=Fit2GaussConv(epid(row,:),eclipse(row,:),SD1,SD2,SD3,SD4);

w1=w_cross(1); %weight of Gaussian 1
w2=w_cross(2); %weight of Gaussian 2
w3=w_cross(3); %weight of Gaussian 3
w4=w_cross(4); %weight of Gaussian 3
w_cr_tot(i,:)=w_cross;

end
w_cr_avg=w_cr_tot
%w_cr_avg=mean(w_cr_tot);

gsum=(w_cr_avg(1)*g1+w_cr_avg(2)*g2+w_cr_avg(3)*g3+w_cr_avg(4)*g4);   %gsum=gsum/trapz(gsum);
%figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([400 600]); %ylim([0 0.1])
tps_profile=eclipse(row,:);
epid_profile=epid(row,:); %epid_profile=epid_profile/trapz(epid_profile);
test=conv(epid_profile,gsum,'same')*ConvRescaleFactor_cross;
figure; plot(1:length(epid_profile),epid_profile/max(epid_profile)*max(tps_profile),1:length(epid_profile),tps_profile,1:length(epid_profile),test); 
legend('epid (arbitrary scale)','TPS dose','conv(epid,gsum)','location','south'); 
title('crossplane')
% to zoom in accurately
slope=diff(tps_profile); [a,b]=max(slope); [c,d]=min(slope);
xlim([b-30 d+30]); ylim([0.97*max(tps_profile) 1.01*max(tps_profile)])

% -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

sprintf('IN-PLANE')
i=0;
for col=256
    i=i+1;
%[w_in,ConvRescaleFactor_in]=Fit2GaussConv(epid(:,col)'/trapz(epid(:,col)),eclipse(:,col)',SD1,SD2,SD3,SD4);
[w_in,ConvRescaleFactor_in]=Fit2GaussConv(epid(:,col)',eclipse(:,col)',SD1,SD2,SD3,SD4);

w1=w_in(1); %weight of Gaussian 1
w2=w_in(2); %weight of Gaussian 2
w3=w_in(3); %weight of Gaussian 3
w4=w_in(4); %weight of Gaussian 3
w_in_tot(i,:)=w_in;

end
w_in_avg=w_in_tot
%w_in_avg=mean(w_in_tot);

gsum=(w_in_avg(1)*g1+w_in_avg(2)*g2+w_in_avg(3)*g3+w_in_avg(4)*g4);   %gsum=gsum/trapz(gsum);
%figure; plot(x,g1,x,g2,x,g3,x,g4,x,gsum); legend('Gaussian 1','Gaussian 2','Gaussian 3','Gaussian 4','Sum'); xlim([400 600]); %ylim([0 0.1])
tps_profile=eclipse(:,col);
epid_profile=epid(:,col);
%epid_profile=epid_profile/trapz(epid_profile);
test=conv(epid_profile,gsum,'same')*ConvRescaleFactor_in;
figure; plot(1:length(epid_profile),epid_profile/max(epid_profile)*max(tps_profile),1:length(epid_profile),tps_profile,1:length(epid_profile),test); 
legend('epid (arbitrary scale)','TPS dose','conv(epid,gsum)','location','south'); 
title('inplane')
% to zoom in accurately
slope=diff(tps_profile); [a,b]=max(slope); [c,d]=min(slope);
xlim([b-30 d+30]); ylim([0.97*max(tps_profile) 1.01*max(tps_profile)])

% -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
 
eval(['cd(''C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\',UnitStr,'\',ResolutionStr,'\Gaussian_weights\',EnergyStr,' '');']);
eval(['save gw_l',l_string,'w',w_string,' w_cr_avg w_in_avg;']);
cd(working_dir);
sprintf('END GAUSSIAN WEIGHTING')

