local t = Def.ActorFrame{}

local spacing = 48;
local originY = SCREEN_CENTER_Y-100;
--local src = {PLAYER_1,PLAYER_2};
local src = GAMESTATE:GetHumanPlayers()
local sides = 200;

local button;
if Game() == "Kb7" then 
	button = "Key1" 
else 
	button = "UpLeft" 
end;


function NoteskinController(self,param)

	if param.Player == PLAYER_1 then
		if param.Input == "Prev" and Global.noteskinp1 > 1 then Global.noteskinp1 = Global.noteskinp1-1; MESSAGEMAN:Broadcast("NoteskinChanged",{Direction="Prev",Player=PLAYER_1}); end;
		if param.Input == "Next" and Global.noteskinp1 < #Global.noteskins then Global.noteskinp1 = Global.noteskinp1+1; MESSAGEMAN:Broadcast("NoteskinChanged",{Direction="Next",Player=PLAYER_1}); end;
	elseif param.Player == PLAYER_2 then
		if param.Input == "Prev" and Global.noteskinp2 > 1 then Global.noteskinp2 = Global.noteskinp2-1;MESSAGEMAN:Broadcast("NoteskinChanged",{Direction="Prev",Player=PLAYER_2}); end;
		if param.Input == "Next" and Global.noteskinp2 < #Global.noteskins then Global.noteskinp2 = Global.noteskinp2+1; MESSAGEMAN:Broadcast("NoteskinChanged",{Direction="Next",Player=PLAYER_2});  end;	
	end;

	if param.Input == "Cancel" or param.Input == "Back" and Global.level == 2 then 
		Global.level = 1; 
		Global.selection = 6; 
		Global.state = "MainMenu";  
		MESSAGEMAN:Broadcast("StateChanged"); 
		MESSAGEMAN:Broadcast("Block"); 
	end;
	
end

--[[

for pn in ivalues(src) do
	

	
	for i=1,#Global.noteskins do 
	
	
	
	t[#t+1] = NOTESKIN:LoadActorForNoteSkin(button,"Tap Note",Global.noteskins[i])..{
		InitCommand=cmd(y,originY;zoom,0.55;visible,false);
		OnCommand=function() 
		
			if pn == PLAYER_1 and Global.noteskinp1 == -1 then 
				Global.noteskinp1= NoteskinSelection(pn); 
			elseif pn == PLAYER_2 and Global.noteskinp2 == -1 then 
				Global.noteskinp2 = NoteskinSelection(pn); 
			end; 
			MESSAGEMAN:Broadcast("NoteskinChanged"); 
		end;

		NoteskinChangedMessageCommand=function(self,param)	
				
				local index;	
							
				if pn == PLAYER_1 then index = Global.noteskinp1; elseif pn == PLAYER_2 then index = Global.noteskinp2; end;
				if math.abs(index-i) ~= 0 then self:visible(false); else self:visible(true); end;
						

							self:stoptweening();
						
						if param then
							if param.Player == pn then
								self:zoomx(0);
							end;	
						end;
						
						self:decelerate(0.12);
						
						if pn == PLAYER_1 then 
							self:x(SCREEN_CENTER_X-sides); 
							self:zoomx(0.55); 
						elseif pn == PLAYER_2 then 
							self:x(SCREEN_CENTER_X+sides);
							self:zoomx(-0.55); 
						end;
					
					
					if GAMESTATE:IsSideJoined(pn) and Global.noteskins[index] then
						local options = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred");
						GAMESTATE:ApplyGameCommand("mod,"..string.lower(Global.noteskins[index])..";",pn);
					end;
					
			end;
	};
	




	end;
	
	
	
	
	
	
	
	
t[#t+1] = LoadFont("helvetica bold")..{
		InitCommand=cmd(y,originY+24;zoom,0.4;visible,true;strokecolor,0.1,0.1,0.1,0.95;maxwidth,260);
		OnCommand=function() 
		
			if pn == PLAYER_1 and Global.noteskinp1 == -1 then 
				Global.noteskinp1= NoteskinSelection(pn); 
			elseif pn == PLAYER_2 and Global.noteskinp2 == -1 then 
				Global.noteskinp2 = NoteskinSelection(pn); 
			end; 
			MESSAGEMAN:Broadcast("NoteskinChanged"); 
		end;
		
		NoteskinChangedMessageCommand=function(self,param)
				self:stoptweening();
				local index;
							
				if pn == PLAYER_1 then index = Global.noteskinp1; elseif pn == PLAYER_2 then index = Global.noteskinp2; end;
					if Global.noteskins[index] then self:settext(Global.noteskins[index]); end
					
					if pn == PLAYER_1 then 
					self:x(SCREEN_CENTER_X-sides); 
					elseif pn == PLAYER_2 then 
					self:x(SCREEN_CENTER_X+sides);
					end; 
					
			end;
	};
	
	

t[#t+1] = LoadFont("helvetica bold")..{
		InitCommand=cmd(y,originY-28;zoom,0.405;visible,true;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
		OnCommand=function(self,param)
				self:settext("Select Noteskin");

					if pn == PLAYER_1 then 
					self:x(SCREEN_CENTER_X-sides); 
					elseif pn == PLAYER_2 then 
					self:x(SCREEN_CENTER_X+sides);
					end; 	
			end;

};

	
t[#t+1] = LoadActor(THEME:GetPathG("","arrows"))..{
		InitCommand=cmd(y,originY;zoom,0.35;visible,true;animate,false;setstate,1;diffusealpha,0.25);
		OnCommand=function(self,param)
					if pn == PLAYER_1 then 
					self:x(SCREEN_CENTER_X-sides-42); 
					elseif pn == PLAYER_2 then 
					self:x(SCREEN_CENTER_X+sides-42);
					end; 	
		end;
		MenuInputMessageCommand=function(self,param) 
			if GAMESTATE:IsSideJoined(param.Player) and param.Input == "Prev" and param.Player == pn and Global.state == "Noteskins" then 
				self:stoptweening(); self:diffusealpha(1); self:sleep(0.1); self:linear(0.3); self:diffusealpha(0.25); 
			end; 
		end;
};

	
t[#t+1] = LoadActor(THEME:GetPathG("","arrows"))..{
		InitCommand=cmd(y,originY;zoom,0.35;visible,true;animate,false;setstate,1;diffusealpha,0.25);
		OnCommand=function(self,param)
					if pn == PLAYER_1 then 
					self:x(SCREEN_CENTER_X-sides+42); 
					self:zoomx(-0.35);
					elseif pn == PLAYER_2 then 
					self:x(SCREEN_CENTER_X+sides+42);
					self:zoomx(-0.35);
					end; 	
		end;
		MenuInputMessageCommand=function(self,param) 
			if GAMESTATE:IsSideJoined(param.Player) and param.Input == "Next" and param.Player == pn and Global.state == "Noteskins" then 
				self:stoptweening(); self:diffusealpha(1); self:sleep(0.1); self:linear(0.3); self:diffusealpha(0.25); 
			end;
		end;
};
	
end




t.OnCommand=cmd(playcommand,"StateChanged");
t.StateChangedMessageCommand=function(self)
	if Global.state == "Noteskins" then
		self:visible(true);
	else	
		self:visible(false);
	end;
end;


]]


return t;