function [layers_our, B] = makeLayers(MeshROI_our, layers_our, choose_elements)

    % initialize fields
    surfacestructs = struct('faces',[],'vertices',[]);
    [layers_our(:).surface] = deal(surfacestructs);

    layersetnames = cellstr(['layer_set_1']);
    [layers_our(:).layer_set_name] = deal(layersetnames{:});

    layersets = 1;
    [layers_our(:).layer_set] = deal(layersets);

    % initialize other fields with ones (these will be filled later)
    [layers_our(:).vnormals] = deal(layersets);
    [layers_our(:).cell_normals] = deal(layersets);
    [layers_our(:).cell_origins] = deal(layersets);


    % number of layers
    depths = {layers_our.depth};
    no_of_layers = size(depths,2);

    % Get thickness of GM 
    % start with the surface layer MeshROI_our.GrayMatter, and project downwards
    % to each layer by finding the normals of triangular FEM elements

    % get normals of each triangular surface element
    TR = triangulation(MeshROI_our.surfaces.GrayMatter.faces,MeshROI_our.surfaces.GrayMatter.vertices);
    V = faceNormal(TR);
    V = -V; % making the normals point inwards

    % find thickness of gray matter layer at each point by calculating the
    % length of the normal until it meets the white matter surface
    tri_midpoints = incenter(TR);
    [distances,~] = point2trimesh(MeshROI_our.surfaces.WhiteMatter, 'QueryPoints', tri_midpoints);

    % Create new layer meshes
    for i = 1:no_of_layers
        
        % Project along normals to form layers with relative depths
        
        % Adjust the length of the unit vector to specific layer depths
        % vectors = relative distance x total distance x unit vector and calculate 
        % end points of the stretched vectors = points of the new layer mesh
        
        layer_vectors = layers_our(i).depth .* distances .* V;        
        layer_mesh_points = tri_midpoints + layer_vectors;
        
        % Find point B from which all normals should point outwards from
        % This is for unifying the normal directions later       
        layer_vectors_B = 10 .* distances .* V;        
        layer_mesh_points_B = tri_midpoints + layer_vectors_B;       
        B = mean(layer_mesh_points_B);
        
        % make mesh of new layer points
        layers_our(i).surface.faces = MyCrustOpen(layer_mesh_points);
        layers_our(i).surface.vertices = layer_mesh_points;
        
        if choose_elements
            % Take 3000/2999 elements for each layer surface
            % also perform rejection based on too large area of triangular element

            numelements = layers_our(i).num_elem;
                     
            [layers_our(i).surface.faces,layers_our(i).surface.vertices]...
                = reducepatch(layers_our(i).surface.faces,layers_our(i).surface.vertices,numelements);
                         
        else % write actual number of elements if no specific amount is chosen
            faces_for_number = layers_our(i).surface.faces;
            layers_our(i).num_elem = size(faces_for_number,1);
        end


        % Calculate vnormals, cell_normals and cell_origins

        % calculate normals of each vertex
        faces2double = layers_our(i).surface.faces;
        TR = triangulation(double(faces2double), layers_our(i).surface.vertices);
        layers_our(i).vnormals = vertexNormal(TR);

        % calculate cell_normals of each projected element in each layer
        % "the model neurons were oriented to align their
        % somatodendritic axes with the element normals" - thus normals needed
        layers_our(i).cell_normals = faceNormal(TR);
        
        % calculate cell_origins (apparently midpoints of elements?)
        layers_our(i).cell_origins = incenter(TR);
        
        % Unify direction of normals
        
        % "Say you set up a point B in the middle of the volume. 
        % Suppose dface is the displacement vector from 
        % B to the middle of a face. The the dot product of dface with an 
        % outward face normal should be positive."
        
        % calculating dface vector with previously determined point B
        dface = layers_our(i).cell_origins - B;
        
        sdot = sign(dot(dface,layers_our(i).cell_normals,3));       
        % ^ want these all to be positive
        layers_our(i).cell_normals = layers_our(i).cell_normals.*sdot;
       
        % plot layer meshes
        figure(i);
        nodes = layers_our(i).surface.vertices;
        trisurf(layers_our(i).surface.faces,nodes(:,1),nodes(:,2),nodes(:,3),'facecolor','c','edgecolor','k');
        % Plot cell_normals if needed
        hold on;         

        P = layers_our(i).cell_origins;
        F = layers_our(i).cell_normals;
        quiver3(P(:,1),P(:,2),P(:,3), F(:,1),F(:,2),F(:,3),0.5,'color','r');
    end
end