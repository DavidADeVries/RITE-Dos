% take the F matrix of unit9, and build a 'fake' one for U10
% hyp: only the amplitude changes, not the shape.
close all; clear all
% U9 15X, 10x10, w=20cm

EPID_folder='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\Pat00-U09\Full\GA002\fx14'; % 103 MUs

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20140818\MFF07645';%U9 06X empty beam HALF RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150127\MFF13448.dcm';%U9 06X empty beam FULL RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13580';%U9 06X empty beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150219\MFF13464.dcm';%U9 06X, 20cm SW in beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13581';%U9 06X, 20cm SW in beam FULL RES

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20070104\MFF00185.dcm';
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20140818\MFF07643';%U9 15X empty beam HALF RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150127\MFF13453';%U9 15X empty beam FULL RES
FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13756';%U9 15X empty beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150219\MFF13466';%U9 15X, 20cm SW in beam FULL RES
FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13757';%U9 15X, 20cm SW in beam FULL RES

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20141103\MFF01955';%U10 06X empty beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20150312\MFF05104';%U10 06X 20cm SW in beam

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20141103\MFF01957';%U10 15X empty beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20150312\MFF05105';%U10 06X 20cm SW in beam

cd(EPID_folder)
[epid,flood_old,flood_new,nCINEfiles,CAX,goodimages_numbers,badimages_numbers,example_cine]=EPID_prepare_4(EPID_folder,FF_used,FF_new);
epid_unit09=epid;



% U10 15X, 10x10, w=20cm

EPID_folder='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\2015_09_22_U10_BeamEndEff_n_RecalForF\U10_15X_103MUs';

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20140818\MFF07645';%U9 06X empty beam HALF RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150127\MFF13448.dcm';%U9 06X empty beam FULL RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13580';%U9 06X empty beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150219\MFF13464.dcm';%U9 06X, 20cm SW in beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13581';%U9 06X, 20cm SW in beam FULL RES

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20070104\MFF00185.dcm';
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20140818\MFF07643';%U9 15X empty beam HALF RES
%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150127\MFF13453';%U9 15X empty beam FULL RES
FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13756';%U9 15X empty beam FULL RES
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150219\MFF13466';%U9 15X, 20cm SW in beam FULL RES
FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u9\20150512\MFF13757';%U9 15X, 20cm SW in beam FULL RES

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20141103\MFF01955';%U10 06X empty beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20150312\MFF05104';%U10 06X 20cm SW in beam

%FF_used='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20141103\MFF01957';%U10 15X empty beam
%FF_new='C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\DF_FF_images\u10\20150312\MFF05105';%U10 15X 20cm SW in beam

cd(EPID_folder)
[epid,flood_old,flood_new,nCINEfiles,CAX,goodimages_numbers,badimages_numbers,example_cine]=EPID_prepare_4(EPID_folder,FF_used,FF_new);
epid_unit10=epid;

cd('C:\Documents and Settings\stefanopeca\My Documents\EPID_dosimetry_RESEARCH\2014-2015\RITE Dos 2015\comissioning_data')
load('F_matrix_interp_with_headings_Unit09_15X_Full.mat')
F_matrix_interp_with_headings(2:end,2:end)=F_matrix_interp_with_headings(2:end,2:end)*mean(mean(epid_unit10(189:196,253:260)))/mean(mean(epid_unit09(189:196,253:260)));
save('F_matrix_interp_with_headings_Unit10_15X_Full.mat','F_matrix_interp_with_headings')



