function [ patch_points_ind,patch_points_dist] = pach_collector(noisy_shape,params)


if strcmp(params.method,'euc')
    tree = ann('init', [noisy_shape.X noisy_shape.Y noisy_shape.Z]');

    opt.search_sch = 'fr';
    opt.radius = params.knn_radius;
    seed_points = randperm(numel(noisy_shape.X));
    seed_points = seed_points(1:params.num_of_patches);
    [IDX,~] = ann('search', tree, [noisy_shape.X(seed_points) noisy_shape.Y(seed_points) noisy_shape.Z(seed_points)]',params.k_neighbors, opt);

    %cut to patches
    patch_points_ind = num2cell(IDX,1);
    patch_points_ind = cellfun(@(x)[x(x~=0)],patch_points_ind,'UniformOutput',false);

    % patches_XYZ = cellfun(@(x)[noisy_shape.X(x) noisy_shape.Y(x) noisy_shape.Z(x)],IDX_cl,'UniformOutput',false);
    patch_points_dist = [];
    
    return

elseif strcmp(params.method,'geo')




    %- for every point - (a) find neighboring points 
    fprintf('Collecting patches...');
    ii=0;
    f = fastmarchmex('init', int32(noisy_shape.TRIV-1), double(noisy_shape.X(:)), double(noisy_shape.Y(:)), double(noisy_shape.Z(:)));
    for outer_loop = 1:params.patch_collecting_rounds
        set_of_unused_points = randperm(numel(noisy_shape.X));
        pt = [];
        all_distances = Inf(numel(noisy_shape.X),1);

        while ~isempty(set_of_unused_points)
            ii = ii+1;
             %pt = [pt;set_of_unused_points(1)];  
             if mod(ii,50)==0, 
                 disp(num2str(ii)), 
    %              clr = ones(size(noisy_shape.X,1),1);
    %              clr(set_of_unused_points)=0;
    %              showshape(noisy_shape,clr);
             end;

            [~,fp] = max(all_distances(set_of_unused_points));
            pt = [pt;set_of_unused_points(fp)];

            [patch_points_ind{ii},patch_points_dist{ii},distances] = extractPointsInsideBall(noisy_shape,pt(end),params.knn_radius,f);
            all_distances = min(all_distances,distances);

            set_of_unused_points = setdiff(set_of_unused_points,patch_points_ind{ii},'stable');
        end
    end

    fastmarchmex('deinit', f);
    num_of_patches = ii;clear ii;
    fprintf('Done.\n');

end



end

