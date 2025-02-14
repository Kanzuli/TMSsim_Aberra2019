%% NOTE: THIS SCRIPT REQUIRES A HEAD MODEL FROM SIMNIBS
% CHECK GIT README.MD FOR INSTRUCTIONS
% MAKE SURE SIMNIBS IS IN MATLAB PATH

% Root path
mat_dir = addPaths; 

%% Make SimNIBS simulation

% Initialize a session
s = sim_struct('SESSION');

% Name of head mesh
s.fnamehead = fullfile(mat_dir,'/preprocessing/head_mesh/subject_1.msh');

% Output folder
s.pathfem = fullfile(mat_dir,'/preprocessing/simulation_mesh/');

% Initialize a list of TMS simulations
s.poslist{1} = sim_struct('TMSLIST');

% Select coil
s.poslist{1}.fnamecoil = 'Magstim_70mm_Fig8.nii.gz';


%% Initialize isotropic conductivities

s.poslist{1}.cond(1).value = 0.126; % white matter
s.poslist{1}.cond(2).value = 0.276; % grey matter
s.poslist{1}.cond(3).value = 1.79; % CSF
s.poslist{1}.cond(4).value = 0.01; % bone
s.poslist{1}.cond(5).value = 0.25; % scalp

%% Initialize anisotropic WM and GM conductivity if DTI available

if exist(fullfile(mat_dir,'/preprocessing/head_mesh/d2c_subject_1'),'dir') > 0
    s.poslist{1}.anisotropy_type = 'vn'; 
end

%% get coil location

transformation_matrix = load(fullfile(mat_dir,'/preprocessing/transformation_matrix.mat'));
 
s.poslist{1}.pos(1).matsimnibs = transformation_matrix;

% Set coil distance from scalp
s.poslist{1}.pos(1).distance = 2; 


%% Run the simulation, takes 10-15 minutes

run_simnibs(s)

%% Analysis
% Read simulation results 
head_mesh = mesh_load_gmsh4(fullfile(mat_dir,'/preprocessing/head_mesh/subject_1.msh'));
simulation_mesh = mesh_load_gmsh4(fullfile(mat_dir,'/preprocessing/simulation_mesh/subject_1_TMS_1-0001_Magstim_70mm_Fig8_nii_vn.msh'));


%%
% Extract GM & WM
gray_matter = mesh_extract_regions(head_mesh,'region_idx', 2);
white_matter = mesh_extract_regions(head_mesh,'region_idx', 1);

% Extract gray and white matter surfaces from head model
gray_matter_surf = mesh_extract_regions(head_mesh,'region_idx', 1002);
white_matter_surf = mesh_extract_regions(head_mesh,'region_idx', 1001);

%% Make E-field data array as in Aberra code

% "The E-field at the model neuron compartments was linearly interpolated from the 10 nearest
% mesh points (tetrahedral vertices in SimNIBS) within the gray and
% white matter volumes using the MATLAB scatteredInterpolant function." 
% - done in function interpEfield 

% Np x 6 matrix where Np is the number of FEM elements in the head model 
% and each row is [x y z Ex Ey Ez]: 
% the coordinates of the center of each tetrahedral FEM element, 
% followed by the directional magnitudes of the E-field vector in that FEM element.

% the last 3 columns (E-field magnitudes) we can get from
E(:,4:6) = simulation_mesh.element_data{1, 1}.tetdata;

% calculating the tetrahedra midpoints with function Tetra_Midpoints
midpoints = Tetra_Midpoints(simulation_mesh.nodes,simulation_mesh.tetrahedra);
E(:,1:3) = midpoints;

% Save E-field solution to correct folder for Aberra pipeline
efield_folder = fullfile(mat_dir,'input_data/fem_efield_data/M1_PA_MCB70.mat');
save(efield_folder,'E'); 

%% choose ROI graphically

if isfile(fullfile(mat_dir,'/preprocessing/ROI_indices.mat'))
    load(fullfile(mat_dir,'/preprocessing/ROI_indices.mat'));
else
    inds = [];
    if ~exist('transformation_matrix','var')
        load(fullfile(mat_dir,'/preprocessing/transformation_matrix.mat'));
    end
    % centerpoint of TMS coil as reference point;
    ref_point = transformation_matrix(1:3,4)';

    % choose points graphically
    inds = select_sources_from_surface(gray_matter_surf, 10, 5, inds, ref_point);
    save(fullfile(mat_dir,'/preprocessing/ROI_indices'),'inds');
end

%% Extract ROI from inds and make MeshROI, TAKES A FEW MINUTES!

MeshROI = makeMeshROI(inds, gray_matter_surf, white_matter_surf);

MeshROI_folder = fullfile(mat_dir,'output_data/layer_data/MeshROI.mat');
save(MeshROI_folder,'MeshROI'); 

%% Construct layers TAKES A FEW MINUTES!

% Aberra et al 2020: "To generate layer-specific populations of neurons, surface
% meshes representing the cortical layers were interpolated between
% the gray and white matter surface meshes at normalized depths"

layers_our = struct('depth',{0.06,0.4,0.55,0.65,0.85},'num_elem',{3000,2999,3000,2999,2999});

% call function to make the layers struct
% 1 means choosing num_elem elements from each layer
[layers, ~] = makeLayers(MeshROI, layers_our, 1);

layers_folder = fullfile(mat_dir,'output_data/layer_data/layer_set_1.mat');
save(layers_folder,'layers'); 

%% Construct layersP struct TAKES A FEW MINUTES!

layersP = struct('depth',{0.06,0.08,0.4,0.51,0.55,0.59,0.65,0.81,0.85});

% 0 means keeping all elements from the mesh
layersP = makeLayers(MeshROI, layersP, 0);

% Save layersP struct
layers_folder = fullfile(mat_dir,'output_data/layer_data/layer_set_1p.mat');
save(layers_folder,'layers'); 

%% Create layers_E struct TAKES AN HOUR OR SO!!!

if ~exist('E','var')
    load(fullfile(mat_dir,'input_data/fem_efield_data/M1_PA_MCB70.mat'));
end

layersE = makeLayersE(layers,E,10,1);

% Save layersE struct
layers_folder = fullfile(mat_dir,'output_data/layer_data/layer_set_1_E_M1_PA_MCB70.mat');
save(layers_folder,'layersE'); 

