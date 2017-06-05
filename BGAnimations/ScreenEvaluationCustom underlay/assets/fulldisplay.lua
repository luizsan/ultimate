local t = Def.ActorFrame{}

t[#t+1] = Def.Sprite{
    InitCommand=cmd(Center;diffusealpha,0;valign,0);
    OnCommand=function(self)

        LoadBackground(self,Global.song);
        
        ratio = self:GetWidth()/self:GetHeight();
        adjust = ((16/9) - ratio)/4;
        
        self:fadeleft(adjust);
        self:faderight(adjust);

        self:stretchto(0,0,SCREEN_HEIGHT*ratio,SCREEN_HEIGHT);
        self:x(SCREEN_CENTER_X);
        self:y(SCREEN_TOP+20);

        self:linear(0.3);
        self:diffuse(0.2,0.2,0.2,0.8);

        self:cropbottom(0.15);
        self:fadebottom(0.05);

    end;
};

t[#t+1] = LoadActor(THEME:GetPathG("","overlay"))..{
    InitCommand=cmd(valign,0;diffuse,Global.bgcolor;visible,true);
    OnCommand=function(self)
        self:stretchto(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        self:x(SCREEN_CENTER_X);
        self:y(SCREEN_TOP+20);
    end;
};

t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
    InitCommand=cmd(FullScreen;diffuse,Global.bgcolor;diffusealpha,0.8;fadetop,0.8);
};

t[#t+1] = Def.Quad{
    --InitCommand=cmd(zoomto,(4/3)*(SCREEN_HEIGHT),SCREEN_HEIGHT;diffuse,1,0,0,0.2;Center);
}





return t;