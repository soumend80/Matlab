targetfolder='D:\Money Heist\S03';
mkdir(targetfolder)
t=tic;
parfor i=1:4
    tic
    url = strcat('http://dl2.mojdl.com/upload/Tv-Series/Money%20Heist/S03/1080p/Money_Heist_S03E',num2str(i,'%02d'),'_x265_1080p_WEBRip_[Mojoo].mkv');
    filename = strcat(targetfolder,'\Money_Heist_S03E',num2str(i,'%02d'),'_x265_1080p_WEBRip_[Mojoo].mkv');
    outfilename = websave(filename,url);
    toc
end
toc(t)
