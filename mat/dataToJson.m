% Convert simulation data to json format for use in netpyne

% File to be loaded
loadFile = "tms_maxH_w1_ls_1_E_M1_PA_MCB70_P_nrn_pop1-nrn_pop6_all.mat";
% Folder for loading data
dataFolder = "nrn_sim_data";
% Folder to save the data
saveFolder = "../netpyne/data";
% Base path for all other folders
basePath = pwd;

dataPath = fullfile(basePath, dataFolder);
savePath = fullfile(basePath, saveFolder);
if ~exist(savePath, 'dir')
   mkdir(savePath);
end

loadPath = fullfile(dataPath, loadFile);

data = load(loadPath);
dataJson = jsonencode(data);

[p, f, e] = fileparts(loadPath);
saveFileName = f + ".json";
saveFile = fullfile(savePath, saveFileName);

sf = fopen(saveFile, 'w');
fprintf(sf, dataJson);
fclose(sf);