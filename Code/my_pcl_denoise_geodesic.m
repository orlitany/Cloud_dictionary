function [ recon_shape ] = my_pcl_denoise_geodesic(noisy_shape,params)


%- for every point - (a) find neighboring points 
fprintf('Collecting patches...');
ii=0;
f = fastmarchmex('init', int32(noisy_shape.TRIV-1), double(noisy_shape.X(:)), double(noisy_shape.Y(:)), double(noisy_shape.Z(:)));
for outer_loop = 1:params.patch_collecting_rounds
    set_of_unused_points = randperm(numel(noisy_shape.X));
    pt = [];
    all_distances = Inf(numel(noisy_shape.X),1);
    
    while ~isempty(set_of_unused_points)
        ii = ii+1;
         %pt = [pt;set_of_unused_points(1)];  
        [~,fp] = max(all_distances(set_of_unused_points));
        pt = [pt;set_of_unused_points(fp)];

        [patch_points_ind{ii},patch_points_dist{ii},distances] = extractPointsInsideBall(noisy_shape,pt(end),params.knn_radius,f);
        all_distances = min(all_distances,distances);

        set_of_unused_points = setdiff(set_of_unused_points,patch_points_ind{ii},'stable');
    
    end
end

fastmarchmex('deinit', f);
num_of_patches = ii;clear ii;
fprintf('Done.\n');




% load dictionary
D = load();


%%

if strcmp(params.dict_type , 'ksvd'),     
    Dtrained = @(xy)Dcont(xy)*ksvdDictionary;    
end


%- denoise
for ii=1:min(num_of_patches,params.num_of_patches)
    if mod(ii,10)==0, disp(num2str(ii)), end;
    XYZ = [noisy_shape.X(patch_points_ind{ii}) noisy_shape.Y(patch_points_ind{ii}) noisy_shape.Z(patch_points_ind{ii}) ];
    patch_points_recon_XYZ{ii} = patchDenoise(D,params.sigma,params.L,XYZ);  
    
end

if params.num_of_patches < num_of_patches,
    for k = params.num_of_patches+1:numel(num_of_patches)
        
        patch_points_recon_XYZ{k} = [noisy_shape.X(patch_points{k}.ind) noisy_shape.Y(patch_points{k}.ind) noisy_shape.Z(patch_points{k}.ind)];
    
    end
    
end

   
visited_pts.recon_XYZ = vertcat(patch_points_recon_XYZ{:});
visited_pts.ind = vertcat(patch_points_ind{:});

normalization_factor = accumarray(visited_pts.ind,1);
recon_shape.X = accumarray(visited_pts.ind,visited_pts.recon_XYZ(:,1))./normalization_factor;
recon_shape.Y = accumarray(visited_pts.ind,visited_pts.recon_XYZ(:,2))./normalization_factor;
recon_shape.Z = accumarray(visited_pts.ind,visited_pts.recon_XYZ(:,3))./normalization_factor;




end

