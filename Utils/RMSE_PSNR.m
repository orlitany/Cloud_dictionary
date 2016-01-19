function [ RMSE,PSNR ] = RMSE_PSNR( orig,comp )
%RMSE_PSNR Summary of this function goes here
%   Detailed explanation goes here

RMSE = orig(:);
max_intensity_value = max(RMSE);
RMSE = sqrt(mean((comp(:)-RMSE(:)).^2));
PSNR = 10*log10((max_intensity_value/RMSE)^2);


end

