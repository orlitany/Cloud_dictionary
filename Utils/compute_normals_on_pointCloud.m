function Nv = compute_normals_on_pointCloud(pcl)

k_neighbors = 12;
tree = ann('init', [pcl.X pcl.Y pcl.Z]');

[IDX,mind] = ann('search', tree, [pcl.X pcl.Y pcl.Z]', k_neighbors);

% D(1,:,:) = pcl.X(IDX);
% D(2,:,:) = pcl.Y(IDX);
% D(3,:,:) = pcl.Z(IDX);

vec=ones(size(IDX,2),1);

Nv = cellfun(@(A,B,C)singleNormalCalc(A,B,C),mat2cell(pcl.X(IDX),k_neighbors,vec),...
    mat2cell(pcl.Y(IDX),k_neighbors,vec),mat2cell(pcl.Z(IDX),k_neighbors,vec),'UniformOutput',false);

% 
% parfor i=1:size(IDX,2)
%     
% %     D = [pcl.X(IDX(:,i)) pcl.Y(IDX(:,i)) pcl.Z(IDX(:,i))];    
%     [coeff,~,~] = pca(D);
%     Nv(i,:) = coeff(:,3)';
%     
%     
% end
% XY = score(:,1:2);
% Nv = coeff(3);
% da(i) = sqrt(vars(1)*vars(2));

Nv = cell2mat(Nv)';

end
% 
function normalVector = singleNormalCalc(X,Y,Z)
    
    [coeff,~,~] = pca([X Y Z]);
%     [coeff,~,~] = pca(D);
    normalVector = coeff(:,3);

%     D = [pcl.X(IDX(:,i)) pcl.Y(IDX(:,i)) pcl.Z(IDX(:,i))];    


end
