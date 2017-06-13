
--//================================================================

function LoadBanner(self,item)
    local path;

    --self:Load(nil);
    path = Global.songlist[item]:GetJacketPath(); 
    if path ~= nil --[[and FILEMAN:DoesFileExist(path)]] then
        self:Load(path)
    else

        path = Global.songlist[item]:GetBannerPath(); 
        if path ~= nil --[[and FILEMAN:DoesFileExist(path)]] then
            self:LoadFromCachedBanner(path)
            --self:Load(path)
        else
            self:Load(THEME:GetPathG("Common fallback","banner"));  
            --self:Load(THEME:GetPathG("Common fallback","banner"));
        end;

    end;
end;

--//================================================================

function LoadBackground(self,song)

    local mov = FindRandomMovie(Global.song)
    local bga = Global.song:GetSongDir()..FindBGA(FILEMAN:GetDirListing(Global.song:GetSongDir()));
    local vid = Global.song:GetPreviewVidPath();
    local path = Global.song:GetBackgroundPath();
    --SCREENMAN:SystemMessage(mov)

    if vid ~= nil and FILEMAN:DoesFileExist(vid) then
        self:Load(vid);
    elseif mov ~= nil and FILEMAN:DoesFileExist(mov) then
        self:Load(mov);
    elseif bga ~= nil and FILEMAN:DoesFileExist(bga) then
        self:Load(bga);
    elseif path ~= nil and FILEMAN:DoesFileExist(path) then
        self:Load(path);
    else
        self:Load(THEME:GetPathG("Common fallback","preview"));
    end;
end;


--//================================================================

function FindBGA(dir)
    local path = nil;
    for i=1,#dir do
        if  string.find(dir[i],".avi")~=nil or 
            string.find(dir[i],".mpg")~=nil or 
            string.find(dir[i],".mpeg")~=nil or 
            string.find(dir[i],".mp4")~=nil or 
            string.find(dir[i],".m1v")~=nil or 
            string.find(dir[i],".m2v")~=nil then
            path = dir[i];
            break;
        end;
    end;
    
    return tostring(path);
end;

--//================================================================

function FindRandomMovie(song)
    local rmovies = FILEMAN:GetDirListing("/RandomMovies/",false,true);
    local path = nil;
    local file = nil;

    for i=1,#rmovies do

        file = rmovies[i];
        file = string.gsub(file,".avi","")
        file = string.gsub(file,".mpg","")
        file = string.gsub(file,".mpeg","")
        file = string.gsub(file,".mp4","")
        file = string.gsub(file,".m1v","")
        file = string.gsub(file,".m2v","")
        file = string.gsub(file,"/RandomMovies/","")

        if file == GetFolder(song) then
            path = rmovies[i];
            break;
        end;

    end;

    return path;

end;

--//================================================================

function LoadJacket(self,song)
    local path;
    path = song:GetJacketPath(); 
    if path ~= nil then
        self:Load(path)
    else
        path = song:GetBannerPath(); 
        if path ~= nil then
            self:LoadBanner(path)
        else
            self:Load(THEME:GetPathG("Common fallback","banner"));  
        end;
    end;
end;

--//================================================================
