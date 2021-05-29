function [area,maxside] = Tri_Area(ind, tris, nodes)
    % getting point coordinates
    p1=nodes(tris(ind,1),:);
    p2=nodes(tris(ind,2),:);
    p3=nodes(tris(ind,3),:);
    
    % lengths of triangle sides
    a = norm(p1-p2);
    b = norm(p1-p3);
    c = norm(p3-p2);
    
    % maximum side length
    maxside = max([a b c]);

    s = (a+b+c)./2;
    area = sqrt(s.*(s-a).*(s-b).*(s-c));
end