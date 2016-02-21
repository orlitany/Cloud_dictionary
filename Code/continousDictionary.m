function [ Dxy ] = continousDictionary(xy,wx,wy)
% Add R to x to get 0<x<2R
%   Detailed explanation goes here
N = 2*max(xy(:));

xy = (xy*2+1)./N;

% normalize_x = 1/sqrt(N/2)*ones(size(wx,2),1);
% normalize_x(wx==0) = 1/sqrt(N);
% normalize_y = 1/sqrt(N/2)*ones(size(wy,2),1);
% normalize_y(wy==0) = 1/sqrt(N);

Dx = cos(bsxfun(@times,xy(:,1),wx));
%Dx = Dx./repmat(normalize_x',[size(Dx,1) 1]);

Dy = cos( bsxfun(@times,xy(:,2),wy));
%Dy = Dy./repmat(normalize_y',[size(Dy,1) 1]);

% Dxy = bsxfun(@rdivide,Dxy,sqrt(sum(Dxy.^2,1)));
Dxy = Dx.*Dy;


end

