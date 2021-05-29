function MeshROI_our = makeMeshROI(inds,gray_matter_surf, white_matter_surf)
    
    tris = gray_matter_surf.triangles(inds,:); % take triangle rows corresponding to indices
    tris2 = tris(:); % concatenate columns of triangle rows: get node indices
    tris3= sort(tris2);
    tris4 = unique(tris3); % remove duplicate node indices (those shared between triangles)
    nodes = gray_matter_surf.nodes(tris4,:); % extract the nodes corresponding to said indices

    % extract ROI box as the minimum and maximum node coordinates in each direction
    MeshROI_our.ROI = [min(nodes(:,1)) max(nodes(:,1)) min(nodes(:,2)) max(nodes(:,2)) min(nodes(:,3)) max(nodes(:,3))];
    % Cut off weird slab disconnected from rest of ROI by hard coding
    MeshROI_our.ROI(2) = -15;
       
    % get all nodes of surface inside ROI
    MeshROI_our.GrayMatter = clipPoints3d(gray_matter_surf.nodes,MeshROI_our.ROI);
    MeshROI_our.WhiteMatter = clipPoints3d(white_matter_surf.nodes,MeshROI_our.ROI);

    % add same nodes to surface structure
    MeshROI_our.surfaces.GrayMatter.vertices = MeshROI_our.GrayMatter;
    MeshROI_our.surfaces.WhiteMatter.vertices = MeshROI_our.WhiteMatter;

    % Produce triangles in surface structures 

    % GRAY MATTER
    MeshROI_our.surfaces.GrayMatter.faces = makeROITriangles(gray_matter_surf,MeshROI_our.GrayMatter);

    % WHITE MATTER
    MeshROI_our.surfaces.WhiteMatter.faces = makeROITriangles(white_matter_surf,MeshROI_our.WhiteMatter);

end