function layersE = makeLayersE(layers_our,E,num_points,all_layers)
    
    % initializing fields for layersE struct
    layersE = layers_our;
    interpnames = cellstr(['N/A']);
    [layersE(:).interp_name] = deal(interpnames{:});
    efieldnames = cellstr(['M1_PA_MCB70']);
    [layersE(:).Efield_solution] = deal(efieldnames{:});

    % adding cell origin coordinates as the basis for e-field structures
    [layersE(:).Efield] = layers_our.cell_origins;
    [layersE(:).EfieldLoc] = layers_our.cell_origins;

    % adding e-field info to Efield structure by interpolating
    % this part of code is largely from Aberra's function 'interpEfield'

    Epts = E(:,1:3);
    Evec = E(:,4:6);
    Emag = sqrt(Evec(:,1).^2+Evec(:,2).^2+Evec(:,3).^2);
    % remove outliers
    Epts = Epts(Emag < 450,:); % extract points below 450 V/m
    Evec = Evec(Emag < 450,:); 
    % remove duplicate points
    [Epts,uinds,~] = unique(Epts,'rows');
    Evec = Evec(uinds,:);
    
    if all_layers
        depths = {layers_our.depth};
        num_layers = size(depths,2);
    else
        num_layers = 1;
    end

    % loop through all layers and cell origins
    for i = 1:num_layers
        %numPositions = layers_our(i).num_elem; 
        numPositions = 5;
        Efi = cell(numPositions,1);
        Eloc = cell(numPositions,1);
        parfor k = 1:numPositions
            disp(k)
            Cij = layers_our(i).cell_origins(k,:); % get coordinates of all compartments for kth cell (in mm)
            inds = knnsearch(Epts,Cij,'k',num_points); % find 4 nearest points in E
            unique_inds = unique(inds); % extract unique points
            pts_near_Cij = Epts(unique_inds,:); % extract coordinates
            E_near_i = Evec(unique_inds,:);
            % make scattered interpolants for each component of E
            Ex_int = scatteredInterpolant(pts_near_Cij(:,1),pts_near_Cij(:,2),pts_near_Cij(:,3),E_near_i(:,1),'linear');
            Ey_int = scatteredInterpolant(pts_near_Cij(:,1),pts_near_Cij(:,2),pts_near_Cij(:,3),E_near_i(:,2),'linear');
            Ez_int = scatteredInterpolant(pts_near_Cij(:,1),pts_near_Cij(:,2),pts_near_Cij(:,3),E_near_i(:,3),'linear');

            Eint = [Ex_int(Cij(:,1),Cij(:,2),Cij(:,3)),...
                Ey_int(Cij(:,1),Cij(:,2),Cij(:,3)),...
                Ez_int(Cij(:,1),Cij(:,2),Cij(:,3))]; % get interpolated field components
            if size(Eint) ~= size(Cij)
                error('E-field has different number of elements from cell-coordinates');
            end
            
            % make 4th column of EfieldLoc (Efield magnitude)
            eloc = sqrt(Eint(:,1).^2+Eint(:,2).^2+Eint(:,3).^2);
            
            % Add to full array of Efield vectors
            Efi{k} = Eint;
            Eloc{k} = eloc;
        end
        for m = 1:numPositions
            [layersE(i).Efield(m,4:6)] = Efi{m};
            % make 4th column of EfieldLoc (Efield magnitude)
            [layersE(i).EfieldLoc(m,4)] = Eloc{m};
        end
    end
end