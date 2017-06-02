local t = Def.ActorFrame{}
local originX = SCREEN_CENTER_X;
local originY = SCREEN_CENTER_Y+128;
local spacing = 90;
local spacing2 = 290;
local arrowzoom = 0.5
local arrowzoom2 = 0.425

for i=1,2 do 


	
	t[#t+1] = LoadActor(THEME:GetPathG("","arrows"))..{
		InitCommand=cmd(zoom,arrowzoom;y,originY;animate,false;setstate,3;diffusealpha,0);
		OnCommand=function(self) 
			if i==1 then 
				self:zoomx(self:GetZoom())
				self:x(originX-spacing);
			elseif i==2 then 
				self:zoomx(self:GetZoom()*-1); 
				self:x(originX+spacing);
			end; 
		end;
		MusicWheelMessageCommand=function(self,param)
			if param.Direction == "Prev" and i==1 
			or param.Direction == "Next" and i==2 then
			self:playcommand("Animate");
			end;
		end;
		AnimateCommand=cmd(stoptweening;diffusealpha,1;sleep,0.075;linear,0.4;diffusealpha,0);
	};

	
	t[#t+1] = LoadActor(THEME:GetPathG("","reflection"))..{
		InitCommand=cmd(zoom,0.445;y,originY+64;diffusealpha,0;blend,Blend.Add);
		OnCommand=function(self) 
			if i==1 then 
				self:zoomx(0.445) 
				self:x(originX-spacing);
			elseif i==2 then 
				self:zoomx(-0.445); 
				self:x(originX+spacing);
			end; 
		end;
		
		MusicWheelMessageCommand=function(self,param)
			if param.Direction == "Prev" and i==1 
			or param.Direction == "Next" and i==2 then
			self:playcommand("Animate");
			end;
		end;
		AnimateCommand=cmd(stoptweening;diffusealpha,0.66;sleep,0.075;linear,0.6;diffusealpha,0);
	};
	
	
	
	
	
	
	
	
	
	
	
end;

return t