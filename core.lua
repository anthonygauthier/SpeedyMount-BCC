local name, sm = ...;
local debug = false;

--------------------------------------------------
---  Addon Specific Options
--------------------------------------------------
local normal, riding = "normal", "riding";

local function PerformItemChanges(input)
  local count = 0;
  local items;
  local gloves = { nil, 10 };
  local boots = { nil, 8 };
  local trinket = { nil, SpeedyMount.db.profile.trinketSlot };

  if debug then
    print(trinket);
  end

  if (GetInventoryItemID("player", 10) ~= nil) then
    gloves[1] = GetItemInfo(GetInventoryItemID("player", 10));

    if debug then
      print(gloves[1]);
    end
  end

  if (GetInventoryItemID("player", 8) ~= nil) then
    boots[1] = GetItemInfo(GetInventoryItemID("player", 8));

    if debug then
      print(boots[1]);
    end
  end

  if (GetInventoryItemID("player", SpeedyMount.db.profile.trinketSlot) ~= nil) then
    trinket[1] = GetItemInfo(GetInventoryItemID("player", SpeedyMount.db.profile.trinketSlot));

    if debug then
      print(trinket[1]);
    end
  end

  if input == normal then
    items = SpeedyMount.db.profile.normal;
  elseif input == riding then
    items = SpeedyMount.db.profile.riding;
  end
  
  if (input == normal and SpeedyMount.db.profile.inRidingGear) or (input == riding and not SpeedyMount.db.profile.inRidingGear) then
    for i, item in pairs(items) do
      if debug then
        print(item[1])
      end
      
      if not IsEquippedItem(item[1]) then
        EquipItemByName(item[1], item[2]);
      end

      count = count + 1;
    end
  end
  
  if input == riding and not SpeedyMount.db.profile.inRidingGear then
    if (gloves[1] ~= nil) and (gloves[1] ~= SpeedyMount.db.profile.riding.gloves[1]) and (gloves[1] ~= SpeedyMount.db.profile.normal.gloves[1]) then
      if debug then
        print("Normal gloves changed to: ", gloves[1]);
      end

      SpeedyMount.db.profile.normal.gloves[1] = gloves[1];
    end

    if (boots[1] ~= nil) and (boots[1] ~= SpeedyMount.db.profile.riding.boots[1]) and (boots[1] ~= SpeedyMount.db.profile.normal.boots[1]) then
      if debug then
        print("Normal boots changed to: ", boots[1]);
      end

      SpeedyMount.db.profile.normal.boots[1] = boots[1];
    end

    if (trinket[1] ~= nil) and (trinket[1] ~= SpeedyMount.db.profile.riding.trinket[1]) and (trinket[1] ~= SpeedyMount.db.profile.normal.trinket[1]) then
      if debug then
        print("Normal trinket changed to: ", trinket[1]);
      end

      SpeedyMount.db.profile.normal.trinket[1] = trinket[1];
    end
  end

  if count == 3 then
    if input == normal then
      SpeedyMount.db.profile.inRidingGear = false;
    elseif input == riding then
      SpeedyMount.db.profile.inRidingGear = true;
    end
  end
end

function CheckMountStatus()
  if UnitLevel("player") < 40 or SpeedyMount.db.profile.enabled == false then 
    return;
  end

  if not IsMounted() then
    if SpeedyMount.db.profile.inRidingGear then
      PerformItemChanges(normal);
    end
  else
    if not SpeedyMount.db.profile.inRidingGear then
      PerformItemChanges(riding);
    end
  end
end

sm.CheckMountStatus = CheckMountStatus;

--------------------------------------------------
---  Getters and Setters
--------------------------------------------------
function SetGloves(value)
  local id = GetItemInfoInstant(value);
  local name = select(1, GetItemInfo(id));

  if name ~= nil then
    SpeedyMount.db.profile.riding.gloves = { name, 10 };
    SpeedyMount:DisplayMessage("Gloves", name);
  end
end

sm.SetGloves = SetGloves;

function SetBoots(value)
  local id = GetItemInfoInstant(value);
  local name = select(1, GetItemInfo(id));

  if name ~= nil then
    SpeedyMount.db.profile.riding.boots = { name, 8 };
    SpeedyMount:DisplayMessage("Boots", name);
  end
end

sm.SetBoots = SetBoots;

function SetTrinket(value)
  local id = GetItemInfoInstant(value);
  local name = select(1, GetItemInfo(id));

  if name ~= nil then
    SpeedyMount.db.profile.riding.trinket = { name, SpeedyMount.db.profile.trinketSlot };
    SpeedyMount:DisplayMessage("Trinket", name);
  end
end

sm.SetTrinket = SetTrinket;

function Reset()
  if debug then
    print("Reset in core. Is in riding gear: ", SpeedyMount.db.profile.inRidingGear);
  end

  SpeedyMount.db.profile.inRidingGear = true;
  PerformItemChanges(normal);
end

sm.Reset = Reset;