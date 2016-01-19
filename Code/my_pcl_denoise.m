function [ recon_shape ] = my_pcl_denoise(noisy_shape,params)

D = @(x)continousDictionary(x,params.knn_radius,params.num_of_frequencies);
tree = ann('init', [noisy_shape.X noisy_shape.Y noisy_shape.Z]');

opt.search_sch = 'fr';
opt.radius = params.knn_radius;
seed_points = randperm(numel(noisy_shape.X));
seed_points = seed_points(1:params.num_of_patches);
[IDX,mind] = ann('search', tree, [noisy_shape.X(seed_points) noisy_shape.Y(seed_points) noisy_shape.Z(seed_points)]',params.k_neighbors, opt);

%cut to patches
IDX_cl = num2cell(IDX,1);
IDX_cl = cellfun(@(x)[x(x~=0)],IDX_cl,'UniformOutput',false);
patches_XYZ = cellfun(@(x)[noisy_shape.X(x) noisy_shape.Y(x) noisy_shape.Z(x)],IDX_cl,'UniformOutput',false);



parfor i=1:params.num_of_patches
%     disp(num2str(i))
    patches_to_fix_{i} = patchDenoise(D,params.sigma,params.L,patches_XYZ{i}); 
end


% recon_XYZ = patches_XYZ;
% recon_XYZ(p(1:num_of_patches)) = patches_to_fix_;
recon_XYZ = cell2mat(patches_to_fix_');
IDX_cl = cell2mat(IDX_cl');
recon_shape.X = accumarray(IDX_cl,recon_XYZ(:,1),[],@mean);
recon_shape.Y = accumarray(IDX_cl,recon_XYZ(:,2),[],@mean);
recon_shape.Z = accumarray(IDX_cl,recon_XYZ(:,3),[],@mean);
% recon_shape.TRIV = gt_shape.TRIV;

% h=figure(3);showshape(recon_shape);title('reconstruction');


end

