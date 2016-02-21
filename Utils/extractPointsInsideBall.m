function [patch_points_ind,patch_points_dist,d] = extractPointsInsideBall(surface,source_pnt_ind,radius,f)  
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% f = fastmarchmex('init', int32(surface.TRIV-1), double(surface.X(:)), double(surface.Y(:)), double(surface.Z(:)));
source = Inf(size(surface.X,1), 1);
source(source_pnt_ind) = 0;

d = fastmarchmex('march', f, double(source));
d(d>=9999999) = Inf;
% fastmarchmex('deinit', f);

patch_points_ind = find(d <= radius);
patch_points_dist = d(patch_points_ind);




end

