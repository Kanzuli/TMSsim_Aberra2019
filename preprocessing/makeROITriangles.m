function ROItriangles2 = makeROITriangles(surf, matter)
    
    % get indices of nodes in ROI
    [~,LocResults,~] = intersect(surf.nodes,matter,'rows');

    % get those triangles that are in ROI (all three points must be in ROI nodes)
    % = keep row, if all elements in the row belong to LocResult

    idx = [];
    for i = 1:size(surf.triangles, 1)
        if ismember(surf.triangles(i,1), LocResults)
            if ismember(surf.triangles(i,2), LocResults)
                if ismember(surf.triangles(i,3), LocResults)
                    idx(end+1) = i;
                end
            end
        end
    end

    ROItriangles = surf.triangles(idx,:);

    % remove nodes that are not faces of any triangle
    % TODO, also change indices of triangles
%     connectedFaces = find(any(faces==nearestVertexID,2));
%     assert(length(connectedFaces)>=1,'Vertex %u is not connected to any face.',nearestVertexID)
    
    
    % convert three points of triangles into MeshROI index system

    ROItriangles2 = zeros(size(ROItriangles));

    for i = 1:size(ROItriangles,1)
        for j = 1:3
            original_index = ROItriangles(i,j);
            point = surf.nodes(original_index,:);
            [~,new_index,~] = intersect(matter,point,'rows');
            ROItriangles2(i,j) = new_index;       
        end
    end
end