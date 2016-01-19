%# store breakpoints
imtool close all;
close all;

tmp = dbstatus;
save('tmp.mat','tmp')

%# clear all
% close all
clear classes %# clears even more than clear all
clc

%# reload breakpoints
load('tmp.mat')
dbstop(tmp)

%# clean up
clear tmp
delete('tmp.mat')