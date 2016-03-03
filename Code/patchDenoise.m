function [recon_XYZ]= patchDenoise(dict,sigma,L,XYZ)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% n=1000;ang=15;
% XYZ = [cosd(ang) sind(ang) 0;-sind(ang) cosd(ang) 0; 0 0 1]*[50*randn(n,1) 20*randn(n,1) 30+randn(n,1)]';
% XYZ = XYZ';
% scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'*')
% axis([-100 100 -100 100 -100 100]);
% 
% [coeff,score,latent]=pca(XYZ);
% figure;scatter3(score(:,1),score(:,2),score(:,3),'*')
% axis([-100 100 -100 100 -100 100]);

N = size(XYZ,1);
if N<4,
    recon_XYZ = XYZ;
    return
end

[coeff,score,~,~,~,mu]=pca(XYZ);

val = score(:,3);
pts = score(:,1:2);
D = dict(pts);
D = bsxfun(@rdivide,D,sqrt(sum(D.^2,1)));

param.eps = 1.1*N*sigma^2;
param.L = L;
[z,~] = mexOMP(val,D,param);

recon_XYZ = bsxfun(@plus,(coeff*[pts D*z]')' ,mu);

end

