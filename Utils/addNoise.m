function [ noisy_shape ] = addNoise(gt_shape,sigma)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
N = numel(gt_shape.X);
noisy_shape.X = gt_shape.X + sigma*randn(N,1);
noisy_shape.Y = gt_shape.Y + sigma*randn(N,1);
noisy_shape.Z = gt_shape.Z + sigma*randn(N,1);

noisy_shape.TRIV = gt_shape.TRIV;

end

