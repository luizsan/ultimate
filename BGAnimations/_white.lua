local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(diffuse,1,1,1,1;FullScreen);
};

return t