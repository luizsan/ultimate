local display_fulltitle
local display_title;
local display_subtitle;
local display_artist;
local translit_fulltitle
local translit_title;
local translit_subtitle;
local translit_artist;

local titlezoom = 0.8;
local artistzoom = 0.53;
local subzoom = 0.475;
local titlemaxwidth = 600;

local originX = SCREEN_CENTER_X;
local originY = SCREEN_TOP+80;

local spacing = 272;

local t = Def.ActorFrame{
    InitCommand=function()

        display_fulltitle = Global.song:GetDisplayFullTitle();
        display_title = Global.song:GetDisplayMainTitle();
        display_subtitle = Global.song:GetDisplaySubTitle();
        display_artist = Global.song:GetDisplayArtist();
        translit_fulltitle = Global.song:GetTranslitFullTitle();
        translit_title = Global.song:GetTranslitMainTitle();
        translit_subtitle = Global.song:GetTranslitSubTitle();
        translit_artist = Global.song:GetTranslitArtist();

    end;

}


-- banner
t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_TOP+64;zoomx,0.8;zoomy,0.85);
    Def.Sprite{
        InitCommand=cmd(LoadFromSongBanner,Global.song;scaletoclipped,256,80);
    },
    LoadActor(THEME:GetPathG("","bannerframe"))..{
    }

}


--// ARTIST =================
t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,originX;y,originY;zoomx,0.975);

        Def.BitmapText{
            Font = "roboto";
            InitCommand=cmd(x,-1;y,-1;vertalign,top;zoom,artistzoom;diffuse,BoostColor(HighlightColor(),0.25);strokecolor,BoostColor(HighlightColor(),0.25);
                maxwidth,500/self:GetZoom();vertspacing,-16;shadowcolor,BoostColor(HighlightColor(),0.25);shadowlengthx,2.2;shadowlengthy,2.2);
            OnCommand=function(self)
                self:settext(display_artist,translit_artist);
            end;
        },

        Def.BitmapText{
            Font = "roboto";
            InitCommand=cmd(vertalign,top;zoom,artistzoom;diffuse,BoostColor(HighlightColor(),0.25);strokecolor,BoostColor(HighlightColor(),0.25);
                maxwidth,500/self:GetZoom();vertspacing,-16;shadowcolor,BoostColor(HighlightColor(),0.25);shadowlengthx,1.2;shadowlengthy,1.2);
            OnCommand=function(self)
                self:settext(display_artist,translit_artist);
            end;
        },

        Def.BitmapText{
            Font = "roboto";
            InitCommand=cmd(x,-1;y,-1;vertalign,top;zoom,artistzoom;diffuse,BoostColor(HighlightColor(),1.0);strokecolor,BoostColor(HighlightColor(),0.3);
                maxwidth,500/self:GetZoom();vertspacing,-16;shadowcolor,BoostColor(HighlightColor(),0.25);shadowlengthx,1;shadowlengthy,1);
            OnCommand=function(self)
                self:settext(display_artist,translit_artist);
            end;
        },
};

t[#t+1] = Def.ActorFrame{
    InitCommand=cmd(x,originX;y,originY+16;zoomx,0.98);

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(vertalign,top;x,-1;y,-1;zoom,titlezoom;diffuse,0.25,0.25,0.25,1;strokecolor,0.25,0.25,0.25,1;
            maxwidth,titlemaxwidth/self:GetZoom();vertspacing,-2;shadowcolor,0.25,0.25,0.25,0.75;shadowlengthx,2.5;shadowlengthy,2.5);
        OnCommand=function(self)
            self:settext(display_fulltitle,translit_fulltitle);
        end;
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(vertalign,top;zoom,titlezoom;diffuse,0.3,0.25,0.25,1;strokecolor,0.25,0.25,0.25,1;
            maxwidth,titlemaxwidth/self:GetZoom();vertspacing,-2;shadowcolor,0.25,0.25,0.25,0.8;shadowlengthx,1.2;shadowlengthy,1.2);
        OnCommand=function(self)
            self:settext(display_fulltitle,translit_fulltitle);
        end;
    },

    Def.BitmapText{
        Font = "roboto";
        InitCommand=cmd(x,-1;y,-1;vertalign,top;zoom,titlezoom;strokecolor,0.275,0.275,0.275,1;
            maxwidth,titlemaxwidth/self:GetZoom();vertspacing,-2);
        OnCommand=function(self)
            self:settext(display_fulltitle,translit_fulltitle);

            local index;

            if self:GetText() == display_fulltitle then
                index = string.utf8len(display_title)
            elseif self:GetText() == translit_fulltitle then
                index = string.utf8len(translit_title)
            end;
            
            self:AddAttribute(
                index,{
                Length = -1;
                --Diffuse = {1,0.925,0.5,1}; --fuck SAO
                Diffuse = BoostColor({1,1,1,1},0.7);
                }
            );

        end;
    },

};




return t;