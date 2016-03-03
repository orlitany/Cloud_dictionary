%myclear;
%% add dependencies
addpath(genpath('./Utils/'));
addpath(genpath('./spams-matlab-v2.5-svn2014-07-04/'));
addpath(genpath('C:\Code\3D_shapes_tools\'));
addpath(genpath('./../'));

%% load shape
rng(1);
gt_shape = loadoff('./../Data/centaur0_dense.off');
Nv = numel(gt_shape.X);
pcshow([gt_shape.X gt_shape.Y gt_shape.Z],uint8(repmat([0 0 100],[Nv 1])));

% figure(1);showshape(gt_shape);title('ground truth');
% figure(1);scatter3(gt_shape.X,gt_shape.Y,gt_shape.Z,1);title('ground truth');

%% add noise
noise_level = 0.5;
noisy_shape = addNoise(gt_shape,noise_level);
h=figure(2);showshape(gt_shape);hold all; pcshow([noisy_shape.X noisy_shape.Y noisy_shape.Z],uint8(repmat([0 0 100],[Nv 1])));title('noisy');

[MSE_noisy,err_per_point] = calc_MSE(gt_shape,noisy_shape);
err_per_point = err_per_point';
err_per_point = err_per_point./max(err_per_point);
showshape(gt_shape,err_per_point)
saveoff_color(['./../results/noisy_shape.off'],[gt_shape.X gt_shape.Y gt_shape.Z],gt_shape.TRIV,err_per_point);

%% Denoise using meshlab, method: HC laplacian

cmnd = ['C:' ' && ' 'cd C:\Program Files\VCG\MeshLab' ' && ' 'meshlabserver -i '...
[pwd '\..\Results\noisy_shape.off'] ' -s ' [pwd '\..\Utils\meshlab_scripts\HC_laplacian.mlx'] ' -o ' [pwd '\..\Results\meshlab_denoise.off'] ];
system(cmnd);

meshlab_denoised_shape = loadoff('./../Results/meshlab_denoise.off');

pcshow([meshlab_denoised_shape.X meshlab_denoised_shape.Y meshlab_denoised_shape.Z],uint8(repmat([0 0 100],[Nv 1])));title('noisy');


MSE_meshlab = calc_MSE(gt_shape,meshlab_denoised_shape);


%% Denoise using our method: 

%parameters:
my_params.num_of_atoms = 20; %if ksvd then this is num of frequencies
my_params.k_neighbors = 1024;
my_params.knn_radius = 5;
my_params.num_of_patches = 20000;
my_params.sigma = noise_level;%noise_level;
my_params.L = 10;%
% my_params.dict_type = 'cos'; %other type: 'cos'
load('./../Results/my_trained_dictionary');

K = 5;
[wx,wy]=meshgrid(pi*[0:K-1],pi*[0:K-1]);
wx = wx(:)'; wy = wy(:)';
Dcont = @(xy)continousDictionary((xy+my_params.knn_radius),wx,wy);



my_params.dict = @(xy)Dcont(xy)*Dtrained;

my_params.patch_collecting_rounds = 2;



%% collect patches - takes time!!!
[ patch_points_ind,patch_points_dist] = pach_collector(noisy_shape,my_params);



%% Clean (fast)
recon_shape = my_pcl_denoise_geodesic(noisy_shape,patch_points_ind,patch_points_dist,my_params);
h=figure(4);showshape(gt_shape);hold all; pcshow([recon_shape.X recon_shape.Y recon_shape.Z],uint8(repmat([255 0 0],[Nv 1])));title('denoised');
MSE_recon = calc_MSE(gt_shape,recon_shape);


%%
pc_gt = pointCloud([gt_shape.X gt_shape.Y gt_shape.Z]);
pc_noisy = pointCloud([noisy_shape.X noisy_shape.Y noisy_shape.Z]);pc_noisy.Color = uint8(repmat([255 0 0],Nv,1));
pc_recon = pointCloud([recon_shape.X recon_shape.Y recon_shape.Z]);pc_recon.Color = uint8(repmat([255 0 0],Nv,1));
pc_meshlab = pointCloud([meshlab_denoised_shape.X meshlab_denoised_shape.Y meshlab_denoised_shape.Z]);pc_meshlab.Color = uint8(repmat([255 0 0],Nv,1));
figure;showshape(gt_shape);hold all;pcshow(pc_noisy);
figure;showshape(gt_shape);hold all;pcshow(pc_meshlab);
figure;showshape(gt_shape);hold all;pcshow(pc_recon);


recon_shape.TRIV = gt_shape.TRIV;
%     showshape(recon_shape);
%     saveas(h,'./results/reconstruction.png');
saveoff_color(['./../Results/my_denoise.off'],[recon_shape.X recon_shape.Y recon_shape.Z],recon_shape.TRIV)
MSE_recon = calc_MSE(gt_shape,recon_shape);
disp(['Noisy Shape MSE: ',num2str(MSE_noisy),...
      '; Meshlab denoising MSE: ',num2str(MSE_meshlab),...
      '; Our denoising MSE: ',num2str(MSE_recon)]);
    
figure;subplot(1,3,1);showshape(noisy_shape);title('Noisy shape')
subplot(1,3,2);showshape(meshlab_denoised_shape);title('Meshlab laplacian denoise')
subplot(1,3,3);showshape(recon_shape);title('Our method')
showshape(gt_shape);title('Original shape')


