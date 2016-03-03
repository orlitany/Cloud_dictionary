function [ Dtrained,tot_err_per_iter ] = trainDictionary( num_iterations,Dcont,patches_XY,patches_val,num_atoms,L,Dinit )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

num_freq = size(Dcont([0 0]),2);

num_patches = numel(patches_XY);

param.eps = 0;
param.L = L;


if isempty(Dinit),
    Dtrained = [eye(num_atoms);zeros(num_freq-num_atoms,num_atoms)]; %Init
else
    Dtrained = Dinit;
end
%Dtrained = rand(num_freq,num_atoms);

Z = zeros(num_atoms,num_patches);
tot_err_per_iter = 0;

for iter = 1:num_iterations
    total_err = 0;
%     D = @(xy)bsxfun(@rdivide,Dcont(xy)*Dtrained,sqrt(sum((Dcont(xy)*Dtrained).^2,1)));
    D = @(xy)Dcont(xy)*Dtrained;
    Dtrained_new = Dtrained;
    
    %- find representation z_i for each patch
    parfor patch = 1:num_patches
        dict_norm_coeff = sqrt(sum(D(patches_XY{patch}).^2,1));
        Z(:,patch) = mexOMP(patches_val{patch},bsxfun(@rdivide,D(patches_XY{patch}),dict_norm_coeff),param);         
        Z(:,patch) = Z(:,patch)./dict_norm_coeff';        
        total_err(patch) = norm(D(patches_XY{patch})*Z(:,patch) - patches_val{patch} ,2);
    end
    tot_err_per_iter(iter) = sum(total_err);
    disp(['Total error: ' num2str(tot_err_per_iter(iter))]);
    
    %- update the dictionary one atom at the time
    for at = 1:num_atoms
        
        uses_atom_ind = find(Z(at,:));        
        
        numerator = zeros(num_freq,numel(uses_atom_ind));
        denominator = zeros(num_freq,num_freq,numel(uses_atom_ind));
        
        if isempty(uses_atom_ind), disp(['Atom number ' num2str(at) ' is not used by any patch']); continue; 
        else
            disp(['Atom number ' num2str(at) ' is used by ' num2str(numel(uses_atom_ind)) ' patches']);
        end
        
%         tic
        parfor cnt = 1:numel(uses_atom_ind)
            ind = uses_atom_ind(cnt);
            z_ = Z(:,ind);
            z_(at) = 0;
            err = patches_val{ind} - D(patches_XY{ind})*z_;            
            D_at = Dcont(patches_XY{ind})*Dtrained(:,at);           
            Z_at_ind = err'*D_at / (D_at'*D_at);
            
            numerator(:,cnt) = Z_at_ind*Dcont(patches_XY{ind})'*err;
            denominator(:,:,cnt) = Z_at_ind^2 * Dcont(patches_XY{ind})'*Dcont(patches_XY{ind});
        end
%         toc
        Dtrained_new(:,at) = sum(denominator,3) \ sum(numerator,2)  ;        
        
        
    end
    
    Dtrained = Dtrained_new;   
    
    
end






end


