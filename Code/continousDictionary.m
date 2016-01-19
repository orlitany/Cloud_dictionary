function [ D ] = continousDictionary( XY,R,K )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[wx,wy]=meshgrid(pi*[0:K-1],pi*[0:K-1]);
wx = wx(:)';
wy = wy(:)';

D = cos( bsxfun(@times,(XY(:,1)+R)./(2*R),wx) ).*cos( bsxfun(@times,(XY(:,2)+R)./(2*R),wy) );
D = bsxfun(@rdivide,D,sqrt(sum(D.^2,1)));



end

