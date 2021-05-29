function midpoints=Tetra_Midpoints(nodes,elements)
% Calculates midpoints (centroids = centers of mass) of the mesh tetrahedra.

p1=nodes(elements(:,1),:);
p2=nodes(elements(:,2),:);
p3=nodes(elements(:,3),:);
p4=nodes(elements(:,4),:);
midpoints=(p1+p2+p3+p4)/4;
    
end