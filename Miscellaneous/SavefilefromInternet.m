clearvars
targetfolder='E:\Lecture Notes\Brownian Motion';
mkdir(targetfolder)
for i=1:10
	url = strcat('http://physics.gu.se/~frtbm/joomla/media/mydocs/LennartSjogren/kap',num2str(i),'.pdf');
	filename = strcat(targetfolder,'/Chapter ',num2str(i),'.pdf');
	outfilename = websave(filename,url);
end
