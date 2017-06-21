local spacing = 16;
local width = 0;
local height = 12;
local pn = nil;
local tick_width = 2;
local cornersize = 6;
local corneradjust = 1;

local t = Def.ActorFrame{
    BuildMessageCommand=function(self,param)
        pn = param.Player;
        local gameplay = SCREENMAN:GetTopScreen();
        local player = gameplay:GetChild("Player" .. ToEnumShortString(pn))
        local field = player:GetChild("NoteField");
        local dist = math.abs(player:GetX() - _screen.cx);
        local style = string.lower(GAMESTATE:GetCurrentStyle():GetName());
    
        if style == "double" or style == "routine" or (GAMESTATE:GetNumSidesJoined() == 1 and PREFSMAN:GetPreference("Center1Player")) then
            width = _screen.w - (spacing*4);
        else
            width = (dist*2) - (spacing*2);
        end;

        self:x(player:GetX());
        self:y(SCREEN_TOP+24);
    end;

    -- base
    Def.Quad{
        InitCommand=cmd(diffuse,0.2,0.2,0.2,1);
        BuildCommand=function(self,param)
            self:zoomto(width+2,height+4);
        end;
    },

    -- background
    LoadActor(THEME:GetPathG("","lifebg"))..{
        BuildCommand=function(self,param)
            self:zoomto(width,height);
            self:diffuse(BoostColor(PlayerColor(pn),0.2));
            self:diffusetopedge(BoostColor(PlayerColor(pn),0.1));
            self:customtexturerect(0,0,width/16,1); 
        end;

        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                if param.LifeMeter:IsInDanger() and not param.LifeMeter:IsFailing() then
                    self:diffuseshift();
                    self:effectcolor1(0.25,0,0,1);
                    self:effectcolor2(0.50,0,0,1);
                    self:effectperiod(0.2);
                elseif param.LifeMeter:IsFailing() then
                    self:diffuseshift();
                    self:effectcolor1(0.15,0.1,0.1,1);
                    self:effectcolor2(0.15,0.1,0.1,1);
                    self:effectperiod(1);
                else
                    self:stopeffect();
                end
            end;
        end;
    },

    -- mask
    Def.Quad{
        InitCommand=cmd(MaskSource;diffuse,1,0,0,1);
        EffectCommand=cmd(bounce;effectmagnitude,-math.min(width,480) * pnSide(pn) * 0.175,0,0;effecttiming,0,0,1,0,0;effectclock,"bgm");
        BuildCommand=function(self,param)
            if style == "double" or style == "routine" then
                self:horizalign(right);
            else
                self:horizalign(pnAlign(OtherPlayer[pn]));
            end;
            self:zoomto(math.min(width,480) * 0.175,height);
            self:playcommand("Effect");
        end;

        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                local life = param.LifeMeter:GetLife();
                if life < 1 then
                    self:playcommand("Effect");
                    self:visible(true);
                else
                    self:stopeffect();
                    self:visible(false);
                end;
                self:x(width * pnSide(pn) * ((1 - (life*2))*0.5));
            end;
        end;
    },

    -- sub meter
    Def.Quad{
        InitCommand=cmd(diffuseshift;effecttiming,0,0,1,0,0;effectclock,"bgm";blend,Blend.Add);
        BuildCommand=function(self,param)
            if style == "double" or style == "routine" then
                self:x(-width*0.5);
                self:horizalign(left);
            else
                self:x(width * 0.5 * pnSide(pn));
                self:horizalign(pnAlign(pn));
            end;
            self:zoomto(width * 0.5,height);
            self:effectcolor2(BoostColor(PlayerColor(pn),1));
            self:effectcolor1(0,0,0,0);
        end;
        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                local life = param.LifeMeter:GetLife();
                self:zoomto(width * life, height);
                if param.LifeMeter:IsInDanger() then
                    self:effectcolor2(1,0,0,1);
                    self:effectcolor1(1,0,0,0);
                else
                    self:effectcolor2(BoostColor(PlayerColor(pn),1));
                    self:effectcolor1(0,0,0,0);
                end;
            end;
        end;
    },

    -- meter
    Def.Quad{
        InitCommand=cmd(MaskDest);
        BuildCommand=function(self,param)
            if style == "double" or style == "routine" then
                self:x(-width*0.5);
                self:horizalign(left);
            else
                self:x(width * 0.5 * pnSide(pn));
                self:horizalign(pnAlign(pn));
            end;
            self:zoomto(width * 0.5,height);
            self:diffuse(BoostColor(PlayerColor(pn),1));
            self:diffusebottomedge(BoostColor(HighlightColor(),1.25));
        end;
        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                local life = param.LifeMeter:GetLife();
                self:zoomto(width * life, height);
            end;
        end;
    },

    -- wave
    LoadActor(THEME:GetPathG("","wave"))..{
        InitCommand=cmd(blend,Blend.Add);
        BuildCommand=function(self,param)
            if style == "double" or style == "routine" then
                self:x(-width*0.5);
                self:horizalign(left);
            else
                self:x(width * 0.5 * pnSide(pn));
                self:horizalign(pnAlign(pn));
            end;
            self:zoomto(width,height+8);
            self:customtexturerect(0,0,width/256,1);
            self:texcoordvelocity(0.3,0);
            self:diffuse(BoostColor(PlayerColor(pn),1.75));
            self:diffusealpha(0);
        end;
        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                local life = param.LifeMeter:GetLife();
                self:stoptweening();
                if life == 1 then
                    self:linear(0.5);
                    self:diffusealpha(1);
                else
                    self:diffusealpha(0);
                end;
            end;
        end;
    },


    --bars
    Def.ActorFrame{
        BuildCommand=cmd(diffuse,0.6,0.6,0.6,1);
        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                if param.LifeMeter:IsInDanger() and not param.LifeMeter:IsFailing() then
                    self:diffuseshift();
                    self:effectcolor1(1,0.75,0.75,1);
                    self:effectcolor2(1,0.5,0.5,1);
                    self:effectperiod(1);
                elseif param.LifeMeter:IsFailing() then
                    self:diffuseshift();
                    self:effectcolor1(0.75,0.3,0.3,1);
                    self:effectcolor2(0.75,0.3,0.3,1);
                    self:effectperiod(1);
                elseif param.LifeMeter:IsHot() then
                    self:diffuseshift();
                    self:effectcolor1(1,1,1,1);
                    self:effectcolor2(1,1,1,1);
                    self:effectperiod(0.5);
                else
                    self:stopeffect();
                end
            end;
        end;

        -- center
        LoadActor(THEME:GetPathG("","lifeborder"))..{
            InitCommand=cmd(animate,false;setstate,1;y,-0.5);
            BuildCommand=function(self,param)
                self:zoomto(width - cornersize + (corneradjust*2),height+10);
            end;
        },

        --corner left
        LoadActor(THEME:GetPathG("","lifeborder"))..{
            InitCommand=cmd(animate,false;setstate,0;halign,0;y,-0.5);
            BuildCommand=function(self,param)
                self:zoomto(cornersize,height+10);
                self:x(-width*0.5 - (cornersize*0.5) - corneradjust);
            end;
        },

        --corner right
        LoadActor(THEME:GetPathG("","lifeborder"))..{
            InitCommand=cmd(animate,false;setstate,0;halign,0;y,-0.5);
            BuildCommand=function(self,param)
                self:zoomto(-cornersize,height+10);
                self:x(width*0.5 + (cornersize*0.5) + corneradjust);
            end;
        },

    },

    -- tick
    Def.ActorFrame{
        LifeChangedMessageCommand=function(self,param)
            if param.Player == pn then
                local life = param.LifeMeter:GetLife();
                self:visible(not param.LifeMeter:IsFailing());
                self:x((width-tick_width) * pnSide(pn) * ((1 - (life*2))*0.5));
            end;
        end;


        LoadActor(THEME:GetPathG("","tick"))..{
            InitCommand=cmd(diffuseshift;effecttiming,0,0,1,0,0;effectclock,"bgm";blend,Blend.Add);
            BuildCommand=cmd(zoomto,12,height+8;effectcolor2,PlayerColor(pn);effectcolor1,1,1,1,0);
            LifeChangedMessageCommand=function(self,param)
                if param.Player == pn then
                    if param.LifeMeter:IsFailing() then
                        self:diffuse(1,0,0,1);
                        self:stopeffect();
                    else
                        self:diffuseshift()
                        self:effectcolor2(PlayerColor(pn));
                        self:effectcolor1(1,1,1,0);
                    end;
                end;
            end;
        },

        Def.Quad{
            BuildCommand=cmd(zoomto,tick_width,height);
        }, 


    },





};


return t;