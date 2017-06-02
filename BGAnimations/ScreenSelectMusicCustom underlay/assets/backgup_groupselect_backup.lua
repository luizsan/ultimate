local t = Def.ActorFrame{}
local originX = SCREEN_CENTER_X;
local originY = 6;
local itemspacing = 120;

if #Global.allgroups == 0 then
	SetGroups();
end

local numgroups = #Global.allgroups

function GroupController(self,param)
	Global.blocksteps = false;
	if param.Input == "Prev" then
		if Global.selection > 1 then 
			Global.selection = Global.selection-1;
		else
			Global.selection = #Global.allgroups;
		end
		MESSAGEMAN:Broadcast("SongGroup",{Direction=param.Input}); 
	end

	if param.Input == "Next" then 
		if Global.selection < #Global.allgroups then 
			Global.selection = Global.selection+1;
		else
			Global.selection = 1;
		end
		MESSAGEMAN:Broadcast("SongGroup",{Direction=param.Input}); 
	end;

	if param.Input == "Cancel" or param.Input == "Back" and Global.level == 2 then 
		Global.level = 1; 
		Global.selection = 1; 
		Global.state = "MainMenu"; 
		MESSAGEMAN:Broadcast("StateChanged"); 
		MESSAGEMAN:Broadcast("Return");
	end;
end

--//================================================================

function SetGroups()
	Global.allgroups = SONGMAN:GetSongGroupNames();
	Global.allgroups = FilterGroups(Global.allgroups);

	local pref = GAMESTATE:GetPreferredSong();
	local first = SONGMAN:GetSongsInGroup(Global.allgroups[1]);

	if #FilterSteps(pref)>0 then
		Global.song = pref;
		Global.songgroup = pref:GetGroupName();
	else
		Global.songgroup = first[1]:GetGroupName();
		Global.song = first[SetWheelSelection()];
	end;

	GAMESTATE:SetCurrentSong(Global.song);

	Global.songlist = SONGMAN:GetSongsInGroup(Global.songgroup)
	Global.songlist = FilterSongList(Global.songlist);
end;

--//================================================================

function SelectFolder()
	if Global.songgroup == Global.allgroups[Global.selection] then
		Global.level = 1; 
		Global.selection = 1; 
		Global.state = "MainMenu"; 
		MESSAGEMAN:Broadcast("StateChanged");
	else
		Global.songgroup = Global.allgroups[Global.selection];
		Global.songlist = FilterSongList(SONGMAN:GetSongsInGroup(Global.songgroup));

		MESSAGEMAN:Broadcast("FolderChanged"); 
		MESSAGEMAN:Broadcast("MainMenu");

		Global.p1steps = 1;
		Global.p2steps = 1;
		Global.selection = 1;
	
		Global.selection = 1;
		Global.level = 2;
		Global.state = "MusicWheel";

		Global.song = Global.songlist[Global.selection];
		Global.steps = StepsList(Global.song);
		if Global.p1steps and Global.p1steps > #Global.steps then Global.p1steps = #Global.steps; end
		if Global.p2steps and Global.p2steps > #Global.steps then Global.p2steps = #Global.steps; end


		MESSAGEMAN:Broadcast("BuildMusicList"); 
		MESSAGEMAN:Broadcast("StateChanged"); 
		MESSAGEMAN:Broadcast("MusicWheel",{ silent = true });

	end;
end;

--//================================================================

for i=1,#Global.allgroups do 

	t[#t+1] = Def.ActorFrame{
		InitCommand=cmd(x,originX;y,SCREEN_BOTTOM-112+originY;diffusealpha,0);
		OnCommand=cmd(playcommand,"SongGroup");
		SongGroupMessageCommand=function(self)
			self:stoptweening();
			self:decelerate(0.175);
			if Global.state == "GroupSelect" then self:diffusealpha(1); end;
			self:x(originX+(itemspacing*(i-1))-(Global.selection*itemspacing)+(itemspacing));
		end;

		StateChangedMessageCommand=function(self)
			self:stoptweening();
			if Global.state == "GroupSelect" then 
				self:x(originX+(itemspacing*(i-1))-(Global.selection*itemspacing)+(itemspacing));
				self:decelerate(0.2);
				self:diffusealpha(1);
			else
				self:decelerate(0.2);
				self:diffusealpha(0);
			end;
		end;

		LoadActor(THEME:GetPathG("","glow"))..{
			InitCommand=cmd(zoomto,80,24;diffuse,0.1,0.1,0.1,0.33;y,24);
		};
			
		LoadActor(THEME:GetPathG("","folder"))..{
			InitCommand=cmd(zoom,0.5;diffuse,0.66,0.66,0.66,1);
		};

		LoadFont("neotech")..{
			InitCommand=cmd(zoom,0.42;diffusealpha,1;strokecolor,0.175,0.175,0.175,0.85;y,8;
				maxheight,108;maxwidth,(itemspacing-16)/self:GetZoom();wrapwidthpixels,(itemspacing-10)/self:GetZoom();vertspacing,-4;vertalign,bottom);
			OnCommand=cmd(playcommand,"SongGroup");
			SongGroupMessageCommand=cmd(playcommand,"StateChanged");
			StateChangedMessageCommand=function(self)
				self:settext(Global.allgroups[i]); 
			end;
		};
		
		LoadFont("neotech")..{
			InitCommand=cmd(zoom,0.38;diffuse,HighlightColor();diffusealpha,1;strokecolor,BoostColor(HighlightColor(),0.25);y,16);
			OnCommand=cmd(playcommand,"SongGroup");
			SongGroupMessageCommand=cmd(playcommand,"StateChanged");
			StateChangedMessageCommand=function(self)
				if Global.state=="GroupSelect" then 
					local songs = SONGMAN:GetSongsInGroup(Global.allgroups[i]);
					songs = FilterSongList(songs);
					if #songs == 1 then 
						self:settext(#songs.." song"); 
					else 
						self:settext(#songs.." songs"); 
					end;
				end
			end;
		};
	};

	t[#t+1] = Def.ActorFrame{
		InitCommand=cmd(x,originX;y,SCREEN_BOTTOM-64);
			
			LoadActor(THEME:GetPathG("ScrollBar","middle"))..{
				InitCommand=cmd(rotationz,90;zoomto,6,80;diffusealpha,0;queuecommand,"StateChanged");
				StateChangedMessageCommand=function(self)
					if Global.state=="GroupSelect" then 
						self:diffuse(1,1,1,0.6); 
					else 
						self:diffuse(1,1,1,0); 
					end; 
				end;
			};
			
			LoadActor(THEME:GetPathG("ScrollBar","TickThumb"))..{
				InitCommand=cmd(diffusealpha,0;zoom,0.5);
				OnCommand=cmd(playcommand,"StateChanged");
				SongGroupMessageCommand=function(self)
					self:stoptweening();
					if Global.state == "GroupSelect" then 
						index = Global.selection 
						self:decelerate(0.15);
					end;
					self:x((((index-1)/(numgroups-1))*80)-40);
				end;

				StateChangedMessageCommand=function(self)
					if Global.state=="GroupSelect" then 
						self:diffuse(1,1,1,1); 
					else 
						self:diffuse(1,1,1,0); 
					end; 
					index = Global.selection 
					self:x((((index-1)/(numgroups-1))*80)-40);
					self:playcommand("SongGroup")
				end;

			};
		
	};
		
end;


return t