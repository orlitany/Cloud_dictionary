function [mse,mind] = calc_MSE(shape_gt,shape_denoise)

tree = ann('init', [shape_denoise.X shape_denoise.Y shape_denoise.Z]');
[~,mind] = ann('search', tree, [shape_gt.X shape_gt.Y shape_gt.Z]',1);
mse = mean(mind.^2);



end





