function midpoints=Tri_Midpoints(nodes,elements)
% function midpoints=TriangleMidpoints(nodes,elements)
% Calculates midpoints (centroids = centers of mass) of the mesh triangles.

p1=nodes(elements(:,1),:);
p2=nodes(elements(:,2),:);
p3=nodes(elements(:,3),:);
midpoints=(p1+p2+p3)/3;
    
end