% clear
% create 'magic square' matrix 5x5
% Z=magic(5);
% write it to 'magic.txt' 
tic
mex_WriteMatrix('F:\Soumen\Orbital Shaker\Raw Data\1100 balls\1.5 v 1100 balls run 1 05.08.2019 exp 1821\Results\New2_Unnormalized velocity_1.5v_1100balls_min duration 2frames.txt',[vx_all,vy_all],'%.0f',',','w+');
toc
% append it transposed to 'magic.txt' 
% mex_WriteMatrix('magic.txt',Z','%10.10f',',','a+');
% free mex function
clear mex_WriteMatrix;
% tic
% dlmwrite('magic_dlmwrite.txt',Z,'precision','%2.0f');
% toc