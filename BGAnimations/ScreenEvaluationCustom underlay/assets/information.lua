local display_fulltitle
local display_title;
local display_subtitle;
local display_artist;
local translit_fulltitle
local translit_title;
local translit_subtitle;
local translit_artist;

local maxwidth = 360;

local setTitle = cmd(settext,display_title,translit_title);
local setArtist = cmd(settext,display_artist,translit_artist);
local setPack = cmd(settext,"// "..Global.song:GetGroupName());

local t = Def.ActorFrame{
    InitCommand=function()
        display_fulltitle = Global.song:GetDisplayFullTitle()
        display_title = Global.song:GetDisplayMainTitle()
        display_subtitle = Global.song:GetDisplaySubTitle()
        display_artist = Global.song:GetDisplayArtist()
        translit_fulltitle = Global.song:GetTranslitFullTitle()
        translit_title = Global.song:GetTranslitMainTitle()
        translit_subtitle = Global.song:GetTranslitSubTitle()
        translit_artist = Global.song:GetTranslitArtist()
    end;
}

--//================================================================

function LoadJacket(self,song)
    local path;
    --self:Load(nil);
    path = song:GetJacketPath(); 
    if path ~= nil --[[and FILEMAN:DoesFileExist(path)]] then
        self:Load(path)
    else
        path = song:GetBannerPath(); 
        if path ~= nil --[[and FILEMAN:DoesFileExist(path)]] then
            self:LoadBanner(path)
            --self:Load(path)
        else
            self:Load(THEME:GetPathG("Common fallback","banner"));  
            --self:Load(THEME:GetPathG("Common fallback","banner"));
        end;
    end;
end;

--// CAPTION =================
t[#t+1] = LoadFont("regen small")..{
        InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+32;zoomx,0.32;zoomy,0.3;diffuse,0.66,0.66,0.66,0.75;diffusebottomedge,1,1,1,0.75;strokecolor,0.1,0.1,0.1,1);
        OnCommand=cmd(settext,"RESULTS");
}

--// LEFT =================
t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X-275;y,SCREEN_TOP+46);

    Def.Sprite{
        InitCommand=cmd(horizalign,left;vertalign,top);
        OnCommand=function(self)
            LoadJacket(self,Global.song);
            self:scaletoclipped(48,48);
        end;
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,left;vertalign,top;zoom,0.6;x,60;y,2;maxwidth,maxwidth/self:GetZoom();
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=setTitle;
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,left;vertalign,top;zoom,0.475;x,60;y,20;maxwidth,maxwidth/self:GetZoom();
            diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2);shadowlength,1.25);
        OnCommand=setArtist;
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,left;vertalign,top;zoom,0.475;x,60;y,36;maxwidth,maxwidth/self:GetZoom();
            diffuse,0.75,0.75,0.75,1;strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=setPack;
    },
};

--// RIGHT =================
t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X+275;y,SCREEN_TOP+52);

    --[[
    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.45;x,-12;y,0;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=cmd(settext,"Music Rate: "..GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate().."x");
    },
    ]]--

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.6;x,-12;y,-4;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=cmd(settext,"Stage "..GAMESTATE:GetCurrentStageIndex()+1);
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.45;x,-12;y,16;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=cmd(settext,"Timing Difficulty: "..GetTimingDifficulty());
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.4;x,-12;y,32;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=cmd(settext,"Life Difficulty: "..GetLifeDifficulty());
    },
};

t[#t+1] = Def.Quad{
    InitCommand=cmd(zoomto,560,1;diffuse,1,1,1,0.2;x,SCREEN_CENTER_X;y,SCREEN_TOP+106);
}

return t;