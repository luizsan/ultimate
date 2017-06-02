local wheelspacing = 45;
local maxitems = 13;
local allsongs = SONGMAN:GetAllSongs();

local originX = SCREEN_CENTER_X+(640/2.35);
local originY = SCREEN_CENTER_Y-6;

local t = Def.ActorFrame{
		InitCommand=cmd(fov,120;vanishpoint,SCREEN_CENTER_X+(640/2.35),SCREEN_CENTER_Y-6;fov,120);
		SongGroupMessageCommand=function(self) 
			Global.songlist = SONGMAN:GetSongsInGroup(Global.songgroup) 	
			MESSAGEMAN:Broadcast("BuildMusicList");
		end;
};


--=======================================================================================================================
--HIGHLIGHT
--=======================================================================================================================



--=======================================================================================================================
--ITEM
--=======================================================================================================================

for i=1,#allsongs do

	t[#t+1] = LoadActor(THEME:GetPathG("","bar"))..{
		InitCommand=cmd(zoom,0.625;horizalign,right;x,originX+16;diffuse,1,1,1,0;shadowlength,1.25;shadowcolor,0.3,0.3,0.3,1;playcommand,"CloseWheel");
		CloseWheelMessageCommand=cmd(stoptweening;decelerate,0.15;y,originY;x,originX+16;diffusealpha,0);
		MusicWheelMessageCommand=function(self)
			self:stoptweening();
			
			local yPos = (i-1)*wheelspacing-(wheelspacing*(Global.selection-1))+8;
			self:decelerate(0.2);
			self:y(originY+yPos-1);
			self:x(originX+(Global.selection-i)*6+16);
			self:skewx(-0.135);
		
			if Global.selection-i==0 then self:diffuse(HighlightColor()); self:diffusetopedge(BoostColor(HighlightColor(),2)); self:shadowcolor(BoostColor(HighlightColor(),0.25)); else self:diffuse(1,1,1,1); self:shadowcolor(0.3,0.3,0.3,1); end;
			if math.abs(yPos)>(math.floor((maxitems/2)*wheelspacing)) then self:diffusealpha(0) else self:diffusealpha(1); end;
			if math.abs(Global.selection-i)>(math.floor(maxitems/2)+3) or i>#Global.songlist then self:visible(false) else self:visible(true); end;
			
		end;
	};
	--artist
	t[#t+1] = LoadFont("helvetica bold")..{
		InitCommand=cmd(zoom,0.415;maxwidth,300/self:GetZoom();strokecolor,0.2,0.2,0.2,1;horizalign,right;diffuse,0.7,0.7,0.7,0;playcommand,"CloseWheel");
		CloseWheelMessageCommand=cmd(stoptweening;decelerate,0.15;y,originY;x,originX;diffusealpha,0);
		BuildMusicListMessageCommand=function(self) if Global.songlist[i]~=nil then self:settext(Global.songlist[i]:GetDisplayArtist()); end; end;
		MusicWheelMessageCommand=function(self)
			self:stoptweening();
			
			local yPos = (i-1)*wheelspacing-(wheelspacing*(Global.selection-1))+14;
			self:bounceend(0.275);
			self:y(originY+yPos);
			self:x(originX+(Global.selection-i)*6-4);
			
			if Global.selection-i==0 then self:diffuse(BoostColor(HighlightColor(),0.95)); self:strokecolor(BoostColor(HighlightColor(),0.25)); else self:diffuse(0.7,0.7,0.7,1); self:strokecolor(0.2,0.2,0.2,1); end;
			if math.abs(yPos)>(math.floor((maxitems/2)*wheelspacing)) then self:diffusealpha(0) else self:diffusealpha(1); end;
			if math.abs(Global.selection-i)>(math.floor(maxitems/2)+3) or i>#Global.songlist then self:visible(false) else self:visible(true); end;
		
		end;
	};
	--song
	t[#t+1] = LoadFont("helvetica bold")..{
		InitCommand=cmd(zoom,0.455;maxwidth,300/self:GetZoom();strokecolor,0.3,0.3,0.3,1;horizalign,right;diffusealpha,0;playcommand,"CloseWheel");
		CloseWheelMessageCommand=cmd(stoptweening;decelerate,0.15;y,originY+1;x,originX;diffusealpha,0);
		BuildMusicListMessageCommand=function(self) if Global.songlist[i]~=nil then self:settext(Global.songlist[i]:GetDisplayFullTitle()); end; end;
		MusicWheelMessageCommand=function(self)
			self:stoptweening();
			
			local yPos = (i-1)*wheelspacing-(wheelspacing*(Global.selection-1));
			self:bounceend(0.25);
			self:y(originY+yPos+1);
			self:x(originX+(Global.selection-i)*6);
			
			if Global.selection-i==0 then self:diffuse(BoostColor(HighlightColor(),1.66)); self:strokecolor(BoostColor(HighlightColor(),0.25)); else self:diffuse(1,1,1,1); self:strokecolor(0.3,0.3,0.3,1); end;
			if math.abs(yPos)>(math.floor((maxitems/2)*wheelspacing)) then self:diffusealpha(0) else self:diffusealpha(1); end;
			if math.abs(Global.selection-i)>(math.floor(maxitems/2)+3) or i>#Global.songlist then self:visible(false) else self:visible(true); end;
		
		end;
	};

end;


--=======================================================================================================================
return t