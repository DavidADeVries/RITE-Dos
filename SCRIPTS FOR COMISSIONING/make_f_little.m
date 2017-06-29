clear all; close all

dosave=false;
UnitStr='Unit09';
EnergyStr='06X';

dirs={ 'fx01'    'fx02'    'fx03'    'fx04'    'fx05'    'fx06'    'fx07'  ...
    'fx08'    'fx09'    'fx10'    'fx11'    'fx12'    'fx13'    'fx14'    'fx15' ...
     'fx16'    'fx17'    'fx18'    'fx19'    'fx20'};
currDir = pwd;
dataDir = [currDir '\Comissioning data\EPID images with phantoms off-center (f)'];
cd(dataDir)
EPIDs = cellfun(@(folder) EPID_prepare_4(folder), dirs, 'UniformOutput', 0);
CAXepids = cellfun(@(epid) mean(mean(epid(189:196,253:260))),EPIDs);
% CAXepids = zeros(1,20);
% for j=1:20
%     
% epid=EPID_prepare_4(dirs{j});
% CAXepids(j)=mean(mean(epid(189:196,253:260)));
% end

% NOTE: the following assumes that 01-04 are for d=0cm, 05-08 for d=-5cm,
% 09-12 for d=-10cm, 13-16 for d=+5cm, 17-20 for d=+10cm.

l=[5 10 15 20];
d=[-10 -5 0 5 10];

s05x05=CAXepids([9 5 1 13 17]); s10x10=CAXepids([10 6 2 14 18]);
s15x15=CAXepids([11 7 3 15 19]); s20x20=CAXepids([12 8 4 16 20]);

[fit05,gof05]=fit(d',s05x05','poly1'); c05=coeffvalues(fit05);
[fit10,gof10]=fit(d',s10x10','poly1'); c10=coeffvalues(fit10);
[fit15,gof15]=fit(d',s15x15','poly1'); c15=coeffvalues(fit15);
[fit20,gof20]=fit(d',s20x20','poly1'); c20=coeffvalues(fit20);


figure; a=plot(d,s05x05,'b.',d,s10x10,'g*',d,s15x15,'kx',d,s20x20,'m+');
%set(a,'LineStyle','none','Marker','o')
xlabel('d (cm)'); ylabel('S'' (a.u.)');  xlim([-20 20])
hold; plot(fit05); plot(fit10); plot(fit15); plot(fit20)
legend('05x05','10x10','15x15','20x20','location','northwest');

f_values=zeros(5,4);

f_values(1,1)=CAXepids(1)/CAXepids(9);
f_values(1,2)=CAXepids(2)/CAXepids(10);
f_values(1,3)=CAXepids(3)/CAXepids(11);
f_values(1,4)=CAXepids(4)/CAXepids(12);

f_values(2,1)=CAXepids(1)/CAXepids(5);
f_values(2,2)=CAXepids(2)/CAXepids(6);
f_values(2,3)=CAXepids(3)/CAXepids(7);
f_values(2,4)=CAXepids(4)/CAXepids(8);

f_values(3,1)=CAXepids(1)/CAXepids(1);
f_values(3,2)=CAXepids(2)/CAXepids(2);
f_values(3,3)=CAXepids(3)/CAXepids(3);
f_values(3,4)=CAXepids(4)/CAXepids(4);

f_values(4,1)=CAXepids(1)/CAXepids(13);
f_values(4,2)=CAXepids(2)/CAXepids(14);
f_values(4,3)=CAXepids(3)/CAXepids(15);
f_values(4,4)=CAXepids(4)/CAXepids(16);

f_values(5,1)=CAXepids(1)/CAXepids(17);
f_values(5,2)=CAXepids(2)/CAXepids(18);
f_values(5,3)=CAXepids(3)/CAXepids(19);
f_values(5,4)=CAXepids(4)/CAXepids(20);



figure;
b=plot(d,f_values(:,1),'d-',d,f_values(:,2),'s-',d,f_values(:,3),'^-',d,f_values(:,4),'o-');
legend('05x05','10x10','15x15','20x20','location','northeast')
xlabel('d (cm)')
ylabel('f=S/S''')
xlim([-11 11])



% now, interpolate for steps of l elements of 5:1:20 
% and extrapolate d elements of -20:0.1:20

for j=1:5
    f_values2(j,:)=interp1([5:5:20],f_values(j,:),5:1:20);
end

for j=1:16
    f_values3(:,j)=interp1([-10:5:10],f_values2(:,j),-20:.5:20,'linear','extrap');
end

figure; surf(f_values3)

% add headings
for i=1:size(f_values3,2)
for j=1:size(f_values3,1)
f_values4(j+1,i)=f_values3(j,i);
end
end

for i=1:size(f_values4,2)
for j=1:size(f_values4,1)
f_values5(j,i+1)=f_values4(j,i);
end
end

f_values5(2:end,1)=-20:.5:20;
f_values5(1,2:end)=5:20;

fmatrix=f_values5;
cd ..\..

if dosave
    f_little=fmatrix;
    cd 'Comissioning data'
        eval(['save f_matrix_little_with_headings_',UnitStr,'_',EnergyStr,' f_little']);
    cd ..
end


