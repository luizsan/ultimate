local t = Def.ActorFrame{
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(sleep,0.15;linear,0.2;diffusealpha,1);
	ExitMessageCommand=cmd(sleep,0.15;linear,0.2;diffusealpha,0;queuemessage,"Next");

	LoadActor(THEME:GetPathG("","cursor"))..{
		InitCommand=cmd(x,_screen.cx;y,_screen.cy + 48;animate,false;setstate,5;zoom,0.4;spin;effectmagnitude,0,0,720);
	},

	LoadFont("roboto")..{
		Text="Saving Profiles";
		InitCommand=cmd(Center;diffuse,1,1,1,1;shadowlength,1);
		NextMessageCommand=function(self) MESSAGEMAN:Broadcast("Load"); end;
	},
};

t[#t+1] = Def.Actor{
	OnCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then 
			self:sleep(1); 
		end;
		self:queuecommand("Fadeout");
	end;
	FadeoutCommand=function() MESSAGEMAN:Broadcast("Exit"); end;
	LoadMessageCommand=function() SCREENMAN:GetTopScreen():Continue(); end;
};

return t;