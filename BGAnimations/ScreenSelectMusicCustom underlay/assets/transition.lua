local t = Def.ActorFrame{}


--//==================================================================
--GROUP
--//==================================================================
t[#t+1] = Def.Quad{
	InitCommand=cmd(FullScreen;diffusealpha,0);
	FolderChangedMessageCommand=cmd(diffusealpha,1;sleep,0.15;linear,0.25;diffusealpha,0);
};

t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
	InitCommand=cmd(Center;diffuse,Global.bgcolor;diffusealpha,0);
	FinalDecisionMessageCommand=cmd(diffusealpha,0;sleep,0.1;linear,0.5;diffusealpha,1;sleep,1;queuecommand,"Action");
	ActionCommand=function(self)
		ReadyDecision();
	end;
};

return t;