local t = Def.ActorFrame{}
local firstpress = false;
local block = false;
--=======================================================================================================================
--BACKGROUND
--=======================================================================================================================
t[#t+1] = Def.Sprite{
	InitCommand=cmd(CenterY;x,SCREEN_RIGHT;horizalign,right;croptop,0.1;cropbottom,0.1;fadetop,0.33;fadebottom,0.33;scaletoclipped,SCREEN_HEIGHT*(4/3),SCREEN_HEIGHT;diffusealpha,0);
	OnCommand=cmd(playcommand,"Load");
	MenuInputMessageCommand=function(self,param) if param.Input == "Back" then block = true; end; end;
	MusicWheelMessageCommand=function(self)
			if firstpress == true then
				if block == true then
					block = false
				else
					self:stoptweening();
					self:linear(0.3);
					self:diffusealpha(0);
					self:queuecommand("Unload");
					self:sleep(0.2);
					self:queuecommand("Load");
				end;
			else
				firstpress = true
			end;

	end;
	UnloadMessageCommand=cmd(Load,nil);
	LoadCommand=function(self)
		self:stoptweening();
		local vid = Global.song:GetPreviewVidPath();
		local path = Global.song:GetBackgroundPath();
		if vid ~= nil then
			self:Load(vid);
		elseif path ~= nil and FILEMAN:DoesFileExist(path) then
			self:Load(path);
		else
			self:Load(THEME:GetPathG("Common fallback","background"));
		end;
		self:linear(0.3);
		self:diffuse(0.66,0.66,0.66,0.66);
	end;
};


t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements","background/bg"))..{
	InitCommand=cmd(Center;croptop,0.1;cropbottom,0.1;faderight,(SCREEN_WIDTH/1.666)/SCREEN_WIDTH;diffuse,0.5,0.5,0.5,1)
};



return t