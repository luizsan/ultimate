local display_fulltitle
local display_title;
local display_subtitle;
local display_artist;
local translit_fulltitle
local translit_title;
local translit_subtitle;
local translit_artist;

local maxwidth = 360;

local t = Def.ActorFrame{
    InitCommand=function(self)
        display_fulltitle = Global.song:GetDisplayFullTitle()
        display_title = Global.song:GetDisplayMainTitle()
        display_subtitle = Global.song:GetDisplaySubTitle()
        display_artist = Global.song:GetDisplayArtist()
        translit_fulltitle = Global.song:GetTranslitFullTitle()
        translit_title = Global.song:GetTranslitMainTitle()
        translit_subtitle = Global.song:GetTranslitSubTitle()
        translit_artist = Global.song:GetTranslitArtist()
        self:diffusealpha(0);
    end;
    OnCommand=cmd(stoptweening;sleep,0.1;linear,0.2;diffusealpha,1);
}

--// CAPTION =================
t[#t+1] = LoadFont("regen small")..{
        InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+32;zoomx,0.32;zoomy,0.3;diffuse,0.66,0.66,0.66,0.75;diffusebottomedge,1,1,1,0.75;strokecolor,0.1,0.1,0.1,1);
        OnCommand=cmd(settext,"RESULTS");
}

--// LEFT =================
t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X-275;y,SCREEN_TOP+48);
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
        OnCommand=cmd(settext,display_title,translit_title);
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,left;vertalign,top;zoom,0.475;x,60;y,20;maxwidth,maxwidth/self:GetZoom();
            diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2);shadowlength,1.25);
        OnCommand=cmd(settext,display_artist,translit_artist);
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,left;vertalign,top;zoom,0.475;x,60;y,36;maxwidth,maxwidth/self:GetZoom();
            diffuse,0.75,0.75,0.75,1;strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=cmd(settext,Global.song and Global.song:GetGroupName() or GAMESTATE:GetCurrentSong():GetGroupName());
    },
};

--// RIGHT =================
t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X+284;y,SCREEN_TOP+54);
    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.6;x,-12;y,-2;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=cmd(settext,"Stage "..GAMESTATE:GetCurrentStageIndex()+1);
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,0.4;x,-12;y,18;
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


return t;