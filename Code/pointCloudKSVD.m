function D = pointCloudKSVD(rad,num_of_cont_atoms,num_of_discrete_atoms)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Phi = @(x)continousDictionary(x,rad,num_of_cont_atoms);

A = rand(num_of_cont_atoms,num_of_discrete_atoms);





end

