SpeedyMount = LibStub("AceAddon-3.0"):NewAddon("SpeedyMount-BCC", "AceConsole-3.0", "AceEvent-3.0");

local name, sm = ...;
local options  = {
    name = "SpeedyMount-BCC",
    handler = SpeedyMount,
    type = 'group',
    args = {
        gloves = {
            type = "input",
            name = "Gloves",
            desc = "Name of your speed increasing gloves",
            usage = "<item name>",
            set = "SetGloves",
        },
        boots = {
            type = "input",
            name = "Boots",
            desc = "Name of your speed increasing boots",
            usage = "<item name>",
            set = "SetBoots"
        },
        trinket = {
            type = "input",
            name = "Trinket",
            desc = "Name of your speed increasing trinket",
            usage = "<item name>",
            set = "SetTrinket",
        },
        trinketSlot = {
          type = "input",
            name = "TrinketSlot",
            desc = "What slot do you want your speed increasing trinket in",
            usage = "13 or 14",
            set = "SetTrinketSlot",
        },
        reset = {
          type = "input",
          name = "Reset",
          desc = "Reset outfit to non-riging gear",
          usage = "",
          set = "Reset",
        },
        on = {
          type = "input",
          name = "On",
          desc = "Enables SpeedyMount",
          usage = "",
          set = "On",
        },
        off = {
          type = "input",
          name = "Off",
          desc = "Disables SpeedyMount",
          usage = "",
          set = "Off",
        }
    }
};

do
	local locale = GetLocale();
	local convert = { enGB = "enUS", esES = "esMX", itIT = "enUS" };
	local gameLocale = convert[locale] or locale or "enUS";

	function SpeedyMount:GetLocale()
		return gameLocale;
	end
end

function SpeedyMount:OnEnable()
    -- Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UNIT_AURA");
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("PLAYER_UNGHOST");
    self:RegisterEvent("PLAYER_ALIVE");
    self:RegisterEvent("ZONE_CHANGED");
    self:RegisterEvent("ZONE_CHANGED_INDOORS");
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
  
    -- Addon Loaded
    self:Print("Type /sm for Options");
    sm.CheckMountStatus();
end

local function InitItemDB()
  return {
    gloves = { nil, 10 },
    boots = { nil, 8 },
    trinket = { nil, SpeedyMount.db.profile.trinketSlot }
  };
end

function SpeedyMount:OnInitialize()
    -- Register the Database
    self.db = LibStub("AceDB-3.0"):New("SpeedyMountDB");
    
    -- Change default profile to character specific
    local currentProfile = self.db:GetCurrentProfile();
    local nameAndRealm = select(1, UnitName("player")).." - "..GetRealmName();
    
    if currentProfile == "Default" then
      self.db:SetProfile(nameAndRealm);
      self.db:DeleteProfile("Default", true);
    end
    
    if SpeedyMount.db.profile.trinketSlot == nil then
      SpeedyMount.db.profile.trinketSlot = 14;
    end

    if SpeedyMount.db.profile.enabled == nil then
      SpeedyMount.db.profile.enabled = true;
    end

    if SpeedyMount.db.profile.riding == nil then
        SpeedyMount.db.profile.riding = InitItemDB();
    end

    if SpeedyMount.db.profile.normal == nil then
        SpeedyMount.db.profile.normal = InitItemDB();
    end

    if SpeedyMount.db.profile.inRidingGear == nil then
        SpeedyMount.db.profile.inRidingGear = false;
    end

    if SpeedyMount.db.profile.swapGearAfterCombat == nil then
        SpeedyMount.db.profile.swapGearAfterCombat = false;
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("SpeedyMount", options);
    self:RegisterChatCommand("sm", "ChatCommand");
end

function SpeedyMount:DisplayMessage(item, name)
  return print("|cff1683d1SpeedyMount|r: ", item, " was updated to ", name);
end

function SpeedyMount:ChatCommand(input)
  if not input or input:trim() == "" then
    print("|cff1683d1SpeedyMount|r Options:");
    print("    /sm (gloves | boots | trinket) (item link | item name | item id) (on | off)");
  else
    LibStub("AceConfigCmd-3.0"):HandleCommand("sm", "SpeedyMount", input);
  end
end

function SpeedyMount:PLAYER_ENTERING_WORLD()
  sm.CheckMountStatus();
end

function SpeedyMount:UNIT_AURA()
  local inLockdown = InCombatLockdown();

  if inLockdown then
    if SpeedyMount.db.profile.inRidingGear then
      SpeedyMount.db.profile.swapGearAfterCombat = true;
    end
  else
    sm.CheckMountStatus();
  end
end

function SpeedyMount:PLAYER_REGEN_ENABLED()
  if SpeedyMount.db.profile.swapGearAfterCombat then
    sm.CheckMountStatus();
    SpeedyMount.db.profile.swapGearAfterCombat = false;
  end
end

function SpeedyMount:PLAYER_UNGHOST()
  sm.CheckMountStatus();
end

function SpeedyMount:PLAYER_ALIVE()
  sm.CheckMountStatus();
end

function SpeedyMount:ZONE_CHANGED()
  sm.CheckMountStatus();
end

function SpeedyMount:ZONE_CHANGED_INDOORS()
  sm.CheckMountStatus();
end

function SpeedyMount:ZONE_CHANGED_NEW_AREA()
  sm.CheckMountStatus();
end

--------------------------------------------------
---  Getters and Setters
--------------------------------------------------
function SpeedyMount:SetGloves(_, value)
    sm.SetGloves(value);
end

function SpeedyMount:SetBoots(_, value)
    sm.SetBoots(value);
end

function SpeedyMount:SetTrinket(_, value)
    sm.SetTrinket(value);
end

function SpeedyMount:SetTrinketSlot(_, value)
  local val = tonumber(value);

  if val ~= 13 and val ~= 14 then
    return;
  end

  SpeedyMount.db.profile.trinketSlot = val;
  SpeedyMount.db.profile.normal.trinket[2] = val;
  SpeedyMount.db.profile.riding.trinket[2] = val;
  print("|cff1683d1SpeedyMount|r: Trinket slot is set to "..value);
end

function SpeedyMount:Reset()
  sm.Reset();
end

function SpeedyMount:On()
  SpeedyMount.db.profile.enabled = true;
  print("|cff1683d1SpeedyMount|r: Addon is enabled");
end

function SpeedyMount:Off()
  SpeedyMount.db.profile.enabled = false;
  print("|cff1683d1SpeedyMount|r: Addon is disabled");
end