function getThresholdStatistics(save_mat)

% Calculate layer and stimulation specific statistics
%
%
%

cell_ids = {1:5;6:10;11:15;16:20;21:25};
save_mat = 1;
mat_dir = addPaths; 
% Simulation settings
nrn_model_ver = 'maxH';
mode = 1; % monophasic MagProX100 pulse
layer_set_num = 1;
Efield_name = 'M1_PA_MCB70_iso';
nrn_pop = 'nrn_pop1'; % also choose this for reverse
%nrn_pop = 'nrn_pop1-nrn_pop6_all';
model_prefix = sprintf('tms_%s_w%g_ls_%g_E_%s_P_%s',nrn_model_ver,mode,...
                            layer_set_num,Efield_name,nrn_pop); 

                        
%% Load data

layers = loadLayers(layer_set_num);
initialize_layers = NaN;
[layers(:).means] = deal(initialize_layers);
[layers(:).medians] = deal(initialize_layers);
[layers(:).mins] = deal(initialize_layers);
num_layers = length(layers);
data_layer = cell(num_layers,1);
data_fold = fullfile(mat_dir,'nrn_sim_data');
data_struct = load(fullfile(data_fold,model_prefix));
cell_model_names = data_struct.cell_model_names;
threshEs = data_struct.threshEs;


for i = 1:num_layers
    cell_model_names_i = cellModelNames(cell_ids{i}); % cell names in layer
    [~,~,thresh_inds] = intersect(cell_model_names_i,cell_model_names); % get indices of layer cells in threshEs
    
    %Medians
    data_layer{i} = median(cell2mat(threshEs(thresh_inds)),2);
    layers(i).medians = median(data_layer{i});
    %Means
    data_layer{i} = mean(cell2mat(threshEs(thresh_inds)),2);
    layers(i).means = mean(data_layer{i});
    %Mins
    data_layer{i} = min(cell2mat(threshEs(thresh_inds)));
    layers(i).mins = min(data_layer{i});  
end

if save_mat
    cell_data_file = fullfile(mat_dir,'statistics',sprintf('%s_stats.mat',model_prefix)); 
    save(cell_data_file,'layers');
end

end