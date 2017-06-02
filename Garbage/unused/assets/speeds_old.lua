local t = Def.ActorFrame{}

local spacing = 15;
local originY = SCREEN_CENTER_Y-100;
--local src = {PLAYER_1,PLAYER_2};
local src = GAMESTATE:GetHumanPlayers()
local sides = 200;

local menu = {"Mode","Reset","Exit"};

local digitsp1 = {0,0,0};
local digitsp2 = {0,0,0};

for d=1,3 do 
		
		if GAMESTATE:IsSideJoined(PLAYER_1) then 
			digitsp1[d] = tonumber(string.sub(SpeedSelection(PLAYER_1)[1],d,d));
		end;
		
		if GAMESTATE:IsSideJoined(PLAYER_2) then 
			digitsp2[d] = tonumber(string.sub(SpeedSelection(PLAYER_1)[1],d,d));
		end; 
		
end;


function SpeedController(self,param)

	if param.Player == PLAYER_1 and Global.substatep1 == "" then
		if param.Input == "Prev" and Global.selectionp1 > 1 then Global.selectionp1 = Global.selectionp1-1; MESSAGEMAN:Broadcast("SpeedChanged",{Direction="Prev"}); end;
		if param.Input == "Next" and Global.selectionp1 < 5 then Global.selectionp1 = Global.selectionp1+1; MESSAGEMAN:Broadcast("SpeedChanged",{Direction="Next"}); end;
	elseif param.Player == PLAYER_2 and Global.substatep2 == "" then
		if param.Input == "Prev" and Global.selectionp2 > 1 then Global.selectionp2 = Global.selectionp2-1;MESSAGEMAN:Broadcast("SpeedChanged",{Direction="Prev"}); end;
		if param.Input == "Next" and Global.selectionp2 < 5 then Global.selectionp2 = Global.selectionp2+1; MESSAGEMAN:Broadcast("SpeedChanged",{Direction="Next"}); end;	
	end;
	
	if param.Player == PLAYER_1 and Global.substatep1 ~= "" then
		if param.Input == "Prev"  then MESSAGEMAN:Broadcast("SpeedValue", { Input = "Prev", Player = PLAYER_1}); end;
		if param.Input == "Next" then MESSAGEMAN:Broadcast("SpeedValue", { Input = "Next", Player = PLAYER_1}); end;
	elseif param.Player == PLAYER_2 and Global.substatep2 ~= "" then
		if param.Input == "Prev"  then MESSAGEMAN:Broadcast("SpeedValue", { Input = "Prev", Player = PLAYER_2}); end;
		if param.Input == "Next" then MESSAGEMAN:Broadcast("SpeedValue", { Input = "Next", Player = PLAYER_2}); end;
	end;
	
	if param.Input == "Cancel" or param.Input == "Back" and Global.level == 2 then 
		
		if param.Player == PLAYER_1 and Global.substatep1 ~= "" then
			Global.substatep1 = "";
			MESSAGEMAN:Broadcast("SpeedChanged");
		elseif param.Player == PLAYER_2 and Global.substatep2 ~= "" then
			Global.substatep2 = "";	
			MESSAGEMAN:Broadcast("SpeedChanged");
		else
			Global.level = 1; Global.selection = 5; Global.selectionp1 = 1; Global.selectionp2 = 1; Global.substatep1 = ""; Global.substatep2 = "";
			Global.state = "MainMenu";  MESSAGEMAN:Broadcast("StateChanged"); MESSAGEMAN:Broadcast("Block"); 
		end;
		
	end;

		
end;
			
			

t[#t+1] = Def.Actor{
	--OnCommand=cmd(playcommand,"SpeedValue");
	SpeedValueMessageCommand=function(self,param) 
		if param.Input and GAMESTATE:IsSideJoined(param.Player) then 
		
			local state; 
			local array;
			
			local speed = SpeedSelection(param.Player)[1];
			local mode = SpeedSelection(param.Player)[2];
			local newmode = mode;
			--if mode == "x" then speed = speed*100 end;
			
			if param.Player == PLAYER_1 then 
				state = Global.substatep1 
				array = {
					tonumber(string.sub(speed,1,1)),
					tonumber(string.sub(speed,2,2)),
					tonumber(string.sub(speed,3,3)),
				};
			elseif param.Player == PLAYER_2 then 
				state = Global.substatep2 
				array = {
					tonumber(string.sub(speed,1,1)),
					tonumber(string.sub(speed,2,2)),
					tonumber(string.sub(speed,3,3)),
				};
			end; 
				
			if param.Input == "Prev" then
				if state == "Digit1" and array[1] > 1 then array[1] = array[1]-1; 
				elseif state == "Digit2" and array[2] > 0 then array[2] = array[2]-1; 
				elseif state == "Digit3" and array[3] > 0 then array[3] = array[3]-1; 
				elseif state == "Mode" then 
					if mode == "x" then newmode = "c"
					elseif mode == "m" then newmode = "x" 
					elseif mode == "c" then newmode = "m" 
					end;
				end;
			elseif param.Input == "Next" then
				if state == "Digit1" and array[1] < 9 then array[1] = array[1]+1; 
				elseif state == "Digit2" and array[2] < 9 then array[2] = array[2]+1; 
				elseif state == "Digit3" and array[3] < 9 then array[3] = array[3]+1;
				elseif state == "Mode" then 
					if mode == "x" then newmode = "m"
					elseif mode == "m" then newmode = "c" 
					elseif mode == "c" then newmode = "x" 
					end;
				end;
			end

			
			local total = math.floor(tonumber(table.concat(array,"")));
			
			if newmode == "x" then 
				GAMESTATE:ApplyGameCommand("mod,"..(total/100).."x,no mmod,no cmod",param.Player)
			elseif newmode == "m" then
				GAMESTATE:ApplyGameCommand("mod,m"..(total)..",no xmod,no cmod",param.Player)
			elseif newmode == "c" then
				GAMESTATE:ApplyGameCommand("mod,c"..(total)..",no xmod,no mmod",param.Player)
			end
			
			MESSAGEMAN:Broadcast("SpeedChanged");
			--SCREENMAN:SystemMessage(table.concat(array,"\n"));
			
		
		end;		
	end;	
};





for pn in ivalues(src) do

	t[#t+1] = LoadFont("regen silver")..{
		InitCommand=cmd(uppercase,true;y,originY-10;zoom,0.475;strokecolor,0.1,0.1,0.1,0.95);
		OnCommand=function(self) 		
			if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-sides); elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+sides); end; 
			self:playcommand("SpeedChanged"); 
		end;
		
		StateChangedMessageCommand=cmd(playcommand,"SpeedChanged");
		SpeedChangedMessageCommand=function(self)	
		
			local state;
			local index;
			local value = SpeedSelection(pn)[1];
			local mode = SpeedSelection(pn)[2];
			
			--if mode == "x" then value = value*100 end;
			
			local additive = "";
			
			if pn == PLAYER_1 then index = Global.selectionp1; state = Global.substatep1; elseif pn == PLAYER_2 then index = Global.selectionp2; state = Global.substatep2; end; 

			if state ~= "" then self:diffuse(0.66,0.66,0.66,1); else self:diffuse(1,1,1,1); end;
			
					if mode == "x" then
						local final = math.floor(value)/100;
						self:settext(string.format("%01.02f",final).."x");
					else
						self:settext(mode..value);
					end
				
				

				self:ClearAttributes();
				if index <= 3 then
					if mode == "x" then
						if index == 1 then self:AddAttribute(index-1,{Length=1;Diffuse=HighlightColor()}); else self:AddAttribute(index,{Length=1;Diffuse=HighlightColor()}); end;
					else
						self:AddAttribute(index,{Length=1;Diffuse=HighlightColor()});
					end
				end;
				

				
			--if pn == PLAYER_1 then self:settext(Global.selectionp1); elseif pn == PLAYER_2 then self:settext(Global.selectionp2); end;
			
		end;
	};

	
	for i=1,#menu-1 do 
	
	t[#t+1] = LoadFont("helvetica bold")..{
		InitCommand=cmd(;y,originY+4+((i-1)*(spacing-1));zoom,0.42;vertalign,top;strokecolor,0.1,0.1,0.1,0.66);
		OnCommand=function(self) 		
			if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-sides); elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+sides); end; 
			self:playcommand("SpeedChanged"); 
		end;
		
		StateChangedMessageCommand=cmd(playcommand,"SpeedChanged");
		SpeedChangedMessageCommand=function(self)		
			
			local state;
			if pn == PLAYER_1 then state = Global.substatep1; elseif pn == PLAYER_2 then state = Global.substatep2; end;

			
			if Global.selectionp1-3 == i and pn == PLAYER_1 or Global.selectionp2-3 == i and pn == PLAYER_2 then 
				self:diffuse(HighlightColor());
				self:strokecolor(BoostColor(HighlightColor(),0.15)); 
			else 
					if state ~= "" then 
						self:diffuse(0.66,0.66,0.66,1); 
					else 
						self:diffuse(1,1,1,1); 
					end;
				self:strokecolor(0.1,0.1,0.1,0.66); 
			end;
			
			
			
			local value = SpeedSelection(pn)[1];
			local mode = SpeedSelection(pn)[2];
			
				if i==1 then
					self:settext("Mode: "..mode);
				else
					self:settext(menu[i]);
				end;
				
			end;
	};

	end;

--//==

--title

t[#t+1] = LoadFont("helvetica bold")..{
		InitCommand=cmd(y,originY-28;zoom,0.405;diffuse,HighlightColor();strokecolor,BoostColor(HighlightColor(),0.2));
		OnCommand=function(self,param)
				self:settext("Select Speed");
					if pn == PLAYER_1 then 
					self:x(SCREEN_CENTER_X-sides); 
					elseif pn == PLAYER_2 then 
					self:x(SCREEN_CENTER_X+sides);
					end; 	
			end;
};
	
end

t.OnCommand=cmd(playcommand,"StateChanged");
t.StateChangedMessageCommand=function(self)
	if Global.state == "SpeedMods" then
		self:visible(true);
	else	
		self:visible(false);
	end;
end;




return t;