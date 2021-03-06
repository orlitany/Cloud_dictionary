% train dictionary test file
%% add dependencies
addpath(genpath('./Utils/'));
addpath(genpath('./spams-matlab-v2.5-svn2014-07-04/'));
addpath(genpath('C:\Code\3D_shapes_tools\'));
addpath(genpath('./../'));

%% parameters
num_atoms = 25;
patch_collecting_rounds = 2;
K = 5;
geodesic_radius = 5;
L = 4;
train_iterations = 20;

%% Prepare continuous dictionary
[wx,wy]=meshgrid(pi*[0:K-1],pi*[0:K-1]);
wx = wx(:)'; wy = wy(:)';
Dcont = @(xy)continousDictionary((xy+geodesic_radius),wx,wy);

%% choose shape
shape = loadoff('./../Data/null.off');

%% Prepare patches

fprintf('Collecting patches...');
ii=0;
f = fastmarchmex('init', int32(shape.TRIV-1), double(shape.X(:)), double(shape.Y(:)), double(shape.Z(:)));
for outer_loop = 1:patch_collecting_rounds
    set_of_unused_points = randperm(numel(shape.X));
    pt = [];
    all_distances = Inf(numel(shape.X),1);
    
    while ~isempty(set_of_unused_points)
        ii = ii+1;
        if mod(ii,50)==0, disp(num2str(ii)), end;
         %pt = [pt;set_of_unused_points(1)];  
        [~,fp] = max(all_distances(set_of_unused_points));
        pt = [pt;set_of_unused_points(fp)];

        [patch_points_ind{ii},patch_points_dist{ii},distances] = extractPointsInsideBall(shape,pt(end),geodesic_radius,f);
        all_distances = min(all_distances,distances);

        set_of_unused_points = setdiff(set_of_unused_points,patch_points_ind{ii},'stable');
    
    end
end

fastmarchmex('deinit', f);
num_of_patches = ii;clear ii;
fprintf('Done.\n');

%% Patch to xy - val pairs

for ii = 1:num_of_patches    
    XYZ = [shape.X(patch_points_ind{ii}) shape.Y(patch_points_ind{ii}) shape.Z(patch_points_ind{ii})];
    [coeff,score,~,~,~,mu]=pca(XYZ);
    patches_val{ii} = score(:,3);
    patches_XY{ii} = score(:,1:2);
end

%% Train the dictionary
[Dtrained,err_per_iter] = trainDictionary( train_iterations,Dcont,patches_XY,patches_val,num_atoms,L );
figure;plot(err_per_iter)
save('./../Results/my_trained_dictionary','Dtrained');

%%
[xx,yy] = meshgrid(-geodesic_radius:geodesic_radius/50:geodesic_radius); 
ddd = Dcont(xy)*Dtrained;
ind = find(xx.^2+yy.^2 > 25);
ddd(ind,:) = 0;
for i=1:100, figure(1);imagesc(reshape(ddd(:,i),[101 101]));pause(1);end
