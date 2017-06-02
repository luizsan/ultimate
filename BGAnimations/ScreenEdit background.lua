local t = Def.ActorFrame {};

t[#t+1] = Def.Sprite{
		InitCommand=cmd(Center;diffuse,1,1,1,0.2;fadetop,1);
		OnCommand=function(self)
			self:LoadFromSongBackground(GAMESTATE:GetCurrentSong())
			self:scaletoclipped(SCREEN_WIDTH,SCREEN_HEIGHT)
		end;
};

t[#t+1] = Def.Quad{
		InitCommand=cmd(zoomto,150,SCREEN_HEIGHT;diffuse,0,0,0,0.75;horizalign,left;x,SCREEN_LEFT;y,SCREEN_CENTER_Y);
};
t[#t+1] = Def.Quad{
		InitCommand=cmd(zoomto,150,SCREEN_HEIGHT;diffuse,0,0,0,0.75;horizalign,right;x,SCREEN_RIGHT;y,SCREEN_CENTER_Y);
};


return t;
