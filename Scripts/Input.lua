--//================================================================

function MenuInputActor()
    return Def.ActorFrame{
        UnlockCommand=function() Global.lockinput = false; MESSAGEMAN:Broadcast("Unlock"); end;
        MenuUpP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_1 }); end; 
        MenuUpP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_2 }); end; 
        MenuDownP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_1 }); end; 
        MenuDownP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Back", Player = PLAYER_2 }); end; 
        MenuLeftP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Prev", Player = PLAYER_1 }); end;
        MenuLeftP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Prev", Player = PLAYER_2 }); end; 
        MenuRightP1MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = PLAYER_1 }); end; 
        MenuRightP2MessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "Next", Player = PLAYER_2 }); end; 
        LeftClickMessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "LMB", Player = Global.master }); end;
        RightClickMessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "RMB", Player = Global.master }); end;
        MiddleClickMessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = "MMB", Player = Global.master }); end;
        CodeMessageCommand=function(self,param) MESSAGEMAN:Broadcast("MenuInput", { Input = param.Name, Player = param.PlayerNumber }); end;
        MouseWheelUpMessageCommand=function(self,dt) 
            if Global.debounce <= 0 then 
                MESSAGEMAN:Broadcast("MenuInput", { Input = "Up", Player = Global.master }); 
            end; 
            Global.debounce = Global.delta/1.75; 
        end; 
        MouseWheelDownMessageCommand=function(self,dt) 
            if Global.debounce <= 0 then 
                MESSAGEMAN:Broadcast("MenuInput", { Input = "Down", Player = Global.master }); 
            end;
            Global.debounce = Global.delta/1.75;  
        end;
    }
end;

--//================================================================

function MouseOver(self, range)
	local radius;
	if range == nil then radius = 0.8; else radius = range end;

	if Global.mouseX >= self:GetX() - (self:GetWidth()*self:GetZoomX()*radius) and
	   Global.mouseX <= self:GetX() + (self:GetWidth()*self:GetZoomX()*radius) and
	   Global.mouseY >= self:GetY() - (self:GetHeight()*self:GetZoomY()*radius) and 
	   Global.mouseY <= self:GetY() + (self:GetHeight()*self:GetZoomY()*radius) then
		return true;
	else
		return false;
	end
end;

--//================================================================

function MouseDown(self, range, scr)
	if ButtonHover(self,range) then
		self:stoptweening();
		self:glow(1,1,1,1);
		self:linear(0.2)
		self:glow(1,1,1,0);
		if GAMESTATE:GetNumSidesJoined() == 0 then
			GAMESTATE:JoinPlayer(PLAYER_1);
		end;
		SCREENMAN:SetNewScreen(scr)
	end;
end;	

--//================================================================

function ButtonHover(self,range)
	if MouseOver(self,range) then
		self:playcommand("GainFocus");
		return true;
	else
		self:playcommand("LoseFocus");
		return false;
	end;
end;	

--//================================================================