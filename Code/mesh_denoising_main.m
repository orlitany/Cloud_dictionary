%myclear;
%% add dependencies
addpath(genpath('./Utils/'));
addpath(genpath('./spams-matlab-v2.5-svn2014-07-04/'));
addpath(genpath('C:\Code\3D_shapes_tools\'));
addpath(genpath('./../'));

%% load shape
rng(1);
gt_shape = loadoff('./../Data/null.off');
figure(1);showshape(gt_shape);title('ground truth');
% figure(1);scatter3(gt_shape.X,gt_shape.Y,gt_shape.Z,1);title('ground truth');

%% add noise
noise_level = 0.5;
noisy_shape = addNoise(gt_shape,noise_level);
h=figure(2);showshape(noisy_shape);title('noisy');
% figure(2);scatter3(noisy_shape.X,noisy_shape.Y,noisy_shape.Z,1);title('noisy');
saveas(h,'./../Results/noisy.png');

Nv = numel(noisy_shape.X);
MSE_noisy = calc_MSE(gt_shape,noisy_shape);

lambda_l1=0;
save(['./../results/lambda0'],'noisy_shape','MSE_noisy','lambda_l1');

saveoff_color(['./../results/noisy_shape.off'],[noisy_shape.X noisy_shape.Y noisy_shape.Z],noisy_shape.TRIV);

%% Denoise using meshlab, method: HC laplacian

cmnd = ['C:' ' && ' 'cd C:\Program Files\VCG\MeshLab' ' && ' 'meshlabserver -i '...
[pwd '\..\Results\noisy_shape.off'] ' -s ' [pwd '\..\Utils\meshlab_scripts\HC_laplacian.mlx'] ' -o ' [pwd '\..\Results\meshlab_denoise.off'] ];
system(cmnd);

meshlab_denoised_shape = loadoff('./../Results/meshlab_denoise.off');
MSE_meshlab = calc_MSE(gt_shape,meshlab_denoised_shape);
% 
% for i=1:1
%     cmnd = ['C:' ' && ' 'cd C:\Program Files\VCG\MeshLab' ' && ' 'meshlabserver -i '...
%     [pwd '\results\meshlab_denoise.off'] ' -s ' [pwd '\meshlab_scripts\HC_laplacian.mlx'] ' -o ' [pwd '\results\meshlab_denoise.off'] ];
%     system(cmnd);
% 
%     meshlab_denoised_shape = loadoff('./results/meshlab_denoise.off');
%     MSE_meshlab(i+1) = calc_MSE(gt_shape,meshlab_denoised_shape);
%     
% end
% figure;plot(MSE_meshlab,'*')

%% Denoise using our method: 

%parameters:
my_params.num_of_frequencies = 20;
my_params.k_neighbors = 1024;
my_params.knn_radius = 10;
my_params.num_of_patches = 10000;
my_params.sigma = 0;%noise_level;
my_params.L = 1;%
i=1;

%run
recon_shape = my_pcl_denoise(gt_shape,my_params);

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


