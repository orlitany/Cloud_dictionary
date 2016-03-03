%combine data
folder = 'C:\Code\mesh_inpaiting\Data\titi\farman_tanagra\';
d =dir([folder '*.asc']);
shape.X = [];
shape.Y = [];
shape.Z = [];

for i=1:numel(d)
    disp(i)
    fileID = fopen([folder d(i).name],'r');
    formatSpec = '%f %f %f';
    data = fscanf(fileID,formatSpec,[3 Inf]);
    fclose(fileID);
    data = data';
    shape.X = [shape.X ; data(:,1)];
    shape.Y = [shape.Y ; data(:,2)];
    shape.Z = [shape.Z ; data(:,3)];    
    
end

save([folder 'merged.mat'],'shape');

%% clean-up
ind = find(shape.Z > 80);
shape.X = shape.X(ind);
shape.Y = shape.Y(ind);
shape.Z = shape.Z(ind);

saveoff_color([folder 'merged.off'],[shape.X shape.Y shape.Z],[]);




saveoff_color([folder 'merged.off'],[shape.X shape.Y shape.Z],[]);


pcshow([shape.X shape.Y shape.Z],'*')