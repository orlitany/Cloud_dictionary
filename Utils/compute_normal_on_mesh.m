function [Nv,Nt] = compute_normal_on_mesh(surface_x)


% Triangle areas and normals
At   = zeros(size(surface_x.TRIV,1),1);
Nt = zeros(size(surface_x.TRIV,1),3);
x = surface_x.X(surface_x.TRIV);
y = surface_x.Y(surface_x.TRIV);
z = surface_x.Z(surface_x.TRIV);
v1 = [x(:,1)-x(:,3) y(:,1)-y(:,3) z(:,1)-z(:,3)];
v2 = [x(:,2)-x(:,3) y(:,2)-y(:,3) z(:,2)-z(:,3)];
Nt = cross(v1,v2);
At = sqrt(sum(Nt.^2,2));
Nt = Nt./repmat(At,[1 3]);
At = 0.5*At;

% Vertex-triangle neighborhood matrix
% TNEIGH(v,t) = i if vertex v is an i-th vertex of the triangle t or 0
%               otherwise.
TNEIGH = sparse(length(surface_x.X), size(surface_x.TRIV,1));

id1 = [surface_x.TRIV(:,1), [1:size(surface_x.TRIV,1)]'];
id2 = [surface_x.TRIV(:,2), [1:size(surface_x.TRIV,1)]'];
id3 = [surface_x.TRIV(:,3), [1:size(surface_x.TRIV,1)]'];

TNEIGH(id1)=1;
TNEIGH(id2)=1;
TNEIGH(id3)=1;

s = sum(TNEIGH,2);
s(find(s>0)) = 1./s(find(s>0));
T = spdiags(s(:), 0, size(TNEIGH,1), size(TNEIGH,1)) * TNEIGH;

Nv = T*Nt;


g = zeros(size(surface_x.X));