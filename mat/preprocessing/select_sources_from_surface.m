function [inds] = select_sources_from_surface(mesh,radius1,radius2,inds,reference_points)

% This functions allows to click and select sources from the cortical mesh
% surface

% Tuomas Mutanen, 2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input:
%
% sa = the head model
% radius1 = the radius used to picking up the sources of interest
% radius2 = optional, the radius used to deleting the extra sources of interest
% ind = optional, already previously defined indices to enable to continue
% from the previously saved point
% reference_points = Anatomical landmarks in MNI coordinates to help to identify ROIs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    radius2 = radius1;
end

if nargin < 4
    inds = [];
end

if nargin < 5
    reference_points = [];
end

% Reading the cortical surface from the average head

%cortex.vc = mesh.p;
cortex.vc = mesh.nodes;

%cortex.tri = mesh.e;
cortex.tri = mesh.triangles;

tri_midpoint = Tri_Midpoints(cortex.vc, cortex.tri);

N_cortex_points = length(cortex.tri);

% Implementing the visualization and the GUI

    fig = figure(999);
    
    plot_vec = zeros(1,N_cortex_points);
    plot_vec(inds) = 1;
    
    h = trisurf(cortex.tri, cortex.vc(:,1), cortex.vc(:,2), cortex.vc(:,3),plot_vec,'EdgeAlpha',0);
    grid off;
    axis off;
    caxis([-1 1])
    view([0, 90]);
    colormap('jet')
    colorbar;   
    lightangle(90,-90)
     h.FaceLighting = 'gouraud';
    h.AmbientStrength = 0.5;
    h.DiffuseStrength = 0.9;
    h.SpecularStrength = 0.2;
    h.SpecularExponent = 50;
    h.BackFaceLighting = 'unlit';
    [az,el] = view;
    
    if ~isempty(reference_points)
    hold on; 
    plot3(reference_points(:,1),reference_points(:,2),reference_points(:,3),'k.','MarkerSize',40)
    hold off;
    end 

continue_choosing = 1;

while continue_choosing

    figure(999);
    plot_vec(inds) = 1;
    h = trisurf(cortex.tri, cortex.vc(:,1), cortex.vc(:,2), cortex.vc(:,3),plot_vec,'EdgeAlpha',0);
    grid off;
    axis off;
    caxis([-1 1])
    view([0, 90]);
    colormap('jet')
    colorbar;   
    lightangle(90,-90)
     h.FaceLighting = 'gouraud';
    h.AmbientStrength = 0.5;
    h.DiffuseStrength = 0.9;
    h.SpecularStrength = 0.2;
    h.SpecularExponent = 50;
    h.BackFaceLighting = 'unlit';
    view(az,el)
    
    if ~isempty(reference_points)
    hold on; 
    plot3(reference_points(:,1),reference_points(:,2),reference_points(:,3),'k.','MarkerSize',40)
    hold off;
    end 
    
    datacursormode on;

    title('Choose a point reflecting ROI, press a KEY to SAVE the point')
    pause();
    dcm_obj = datacursormode(fig);
    c_info = getCursorInfo(dcm_obj);
    try
        current_indx = find(sqrt(sum((tri_midpoint - repmat(c_info.Position, [N_cortex_points, 1])).^2,2)) < radius1);
        inds = [inds; current_indx];
    catch
        break;
    end

    title('Press any KEY to CONTINUE, CLICK to END selecting ROI points')
    continue_choosing = waitforbuttonpress;
    [az,el] = view;

end

continue_choosing = 1;

while continue_choosing

    figure(999);
    plot_vec = zeros(1,N_cortex_points);
    plot_vec(inds) = 1;
    h = trisurf(cortex.tri, cortex.vc(:,1), cortex.vc(:,2), cortex.vc(:,3),plot_vec,'EdgeAlpha',0);
    grid off;
    axis off;
    caxis([-1 1])
    view([0, 90]);
    colormap('jet')
    colorbar;   
    lightangle(90,-90)
     h.FaceLighting = 'gouraud';
    h.AmbientStrength = 0.5;
    h.DiffuseStrength = 0.9;
    h.SpecularStrength = 0.2;
    h.SpecularExponent = 50;
    h.BackFaceLighting = 'unlit';
    view(az,el);
    
    if ~isempty(reference_points)
    hold on; 
    plot3(reference_points(:,1),reference_points(:,2),reference_points(:,3),'k.','MarkerSize',40)
    hold off;
    end 
    datacursormode on;

    title('Trim accidental extra points, press a KEY to DELETE the point')
    pause();
    dcm_obj = datacursormode(fig);
    c_info = getCursorInfo(dcm_obj);
    try
        current_indx = find(sqrt(sum((tri_midpoint - repmat(c_info.Position, [N_cortex_points, 1])).^2,2)) < radius2);
        inds = setdiff(inds, current_indx);
    catch
        break;
    end

    title('Press any KEY to CONTINUE, CLICK to END deleting ROI points')
    continue_choosing = waitforbuttonpress;
    [az,el] = view; 
    
end

end
