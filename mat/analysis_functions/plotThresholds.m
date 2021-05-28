%Collects the threshold data from different stimulation settings
%and plots a layerwise summary boxplot
cell_ids = [1 6 11 16 21]; %One celltype per layer
mat_dir = addPaths; 
data_fold = fullfile(mat_dir,'nrn_sim_data');
data_struct1 = load(fullfile(data_fold,'tms_maxH_w1_ls_1_E_M1_PA_MCB70_P_nrn_pop1-nrn_pop6_all.mat'));
data_struct2 = load(fullfile(data_fold,'tms_maxH_w1_ls_1_E_M1_PA_MCB70_P_nrn_pop1.mat'));
data_struct3 = load(fullfile(data_fold,'tms_maxH_w1_ls_1_E_M1_PA_MCB70_r_P_nrn_pop1.mat'));
data_struct4 = load(fullfile(data_fold,'tms_maxH_w1_ls_1_E_M1_PA_MCB70_iso_P_nrn_pop1.mat'));
data_struct5 = load(fullfile(data_fold,'tms_maxH_w1_ls_1_E_M1_PA_MCB70_zrot_P_nrn_pop1.mat'));
data_struct6 = load(fullfile(data_fold,'tms_maxH_w1_ls_1_E_M1_PA_MCB70_zrot_r_P_nrn_pop1.mat'));

%% 
for i = 1:5
    int = mean(data_struct1.threshEs{1,cell_ids(i)},2);
    layerdatas(1,:,i) = int(1:2999);
    int = cell2mat(data_struct2.threshEs(cell_ids(i)));
    layerdatas(2,:,i) = int(1:2999);
    int = cell2mat(data_struct3.threshEs(cell_ids(i)));
    layerdatas(3,:,i) = int(1:2999);
    int = cell2mat(data_struct4.threshEs(cell_ids(i)));
    layerdatas(4,:,i) = int(1:2999);
    int = cell2mat(data_struct5.threshEs(cell_ids(i)));
    layerdatas(5,:,i) = int(1:2999);
    int = cell2mat(data_struct6.threshEs(cell_ids(i)));
    layerdatas(6,:,i) = int(1:2999);
end

%% 
aboxplot(layerdatas,'Colormap',[255 255 204; 199 233 180; 127 205 187; 65 182 196;44 127 184;37 52 148]/255)
%{'#FFFFCC', '#C7E9B4', '#7FCDBB', '#41B6C4', '#2C7FB8', '253494'}
xlabel('Layer')
ylabel('Threshold (A/\mus)')
legend('Pop 1-6','Pop 1','Pop 1 rev.','Pop 1 isotropic','Pop 1 z-rot','Pop 1 z-rot rev.')
ax = gca;
ax.YLim = [0 2000];
ax.XTick = 1:5;
lab = ["1" "2/3" "4" "5" "6"];
ax.XTickLabel = lab;
