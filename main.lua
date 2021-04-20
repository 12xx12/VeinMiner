PLUGIN = nil
ToggleState = {}

function Initialize(Plugin)
	Plugin:SetName("VeinMiner")
	Plugin:SetVersion(2)

	-- Use the InfoReg shared library to process the Info.lua file:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()

	-- Hooks

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that

	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, BreakingBlock)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_JOINED, RegisterPlayer)

	LOG("Initialised " .. Plugin:GetName() .. " Version" .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

--------------------------------------------------------------------------------------------------------------------------------
-- Utility stuff

function containsCoords(list, x)
	for _, Value in pairs(list) do
		if Value.x == x.x and Value.y == x.y and Value.z == x.z then return true end
	end
	return false
end

function contains(list, x)
	for _, Value in pairs(list) do
		if x == Value then return true end
	end
	return false
end


--------------------------------------------------------------------------------------------------------------------------------
-- toggle stuff

-- function that toggles the VeinMiner behaviour
function Toggle(Split, Player)
	ToggleState[Player:GetUUID()] = not ToggleState[Player:GetUUID()]
	if ToggleState[Player:GetUUID()] then
		Player:SendSystemMessage("Toggled VeinMiner On")
	else
		Player:SendSystemMessage("Toggled VeinMiner Off")
	end
	return true
end

-- initially adds a player to the array to make sure there are no errors becase of a missing value
function RegisterPlayer(Player)
	ToggleState[Player:GetUUID()] = true
end

--------------------------------------------------------------------------------------------------------------------------------
-- actual functionality

-- function that is called by the break hook
function BreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	MarkedBlocks = {}
	LOG(Player:GetPermissions())
	if (not Player:IsGameModeSurvival() or not ToggleState[Player:GetUUID()]) or (not Player:HasPermission("veinminer.use") and not Player:HasPermission("*")) then
		return false
	end
	if IsOreType(BlockType) then
		ScanNeighbours(Player:GetWorld(), Vector3i(BlockX, BlockY, BlockZ), MarkedBlocks, BlockType)
		if BlockType == E_BLOCK_REDSTONE_ORE then
			ScanNeighbours(Player:GetWorld(), Vector3i(BlockX, BlockY, BlockZ), MarkedBlocks, E_BLOCK_REDSTONE_ORE_GLOWING)
		end
		if BlockType == E_BLOCK_REDSTONE_ORE_GLOWING then
			ScanNeighbours(Player:GetWorld(), Vector3i(BlockX, BlockY, BlockZ), MarkedBlocks, E_BLOCK_REDSTONE_ORE)
		end

		for _, Block in pairs(MarkedBlocks) do
			Player:GetWorld():DropBlockAsPickups(Block, Player, Player:GetEquippedItem())
		end
	else
		return false
	end
end

-- finds valid neighbours and adds coords to MarkedBlocks
function ScanNeighbours(World, Pos, MarkedBlocks, BlockToFind)
	for x = -1,1,1 do
		for y = -1,1,1 do
			for z = -1,1,1 do
				if not containsCoords(MarkedBlocks, Pos + Vector3i(x, y, z)) then
					if World:GetBlock(Pos + Vector3i(x, y, z)) == BlockToFind then
						MarkedBlocks[#MarkedBlocks+1] = Pos + Vector3i(x, y, z)
						ScanNeighbours(World, Pos + Vector3i(x, y, z), MarkedBlocks, BlockToFind)
					end
				end
			end
		end
	end
end

function IsOreType(BlockType)
	if BlockType == E_BLOCK_COAL_ORE or
		BlockType == E_BLOCK_IRON_ORE or
		BlockType == E_BLOCK_GOLD_ORE or
		BlockType == E_BLOCK_EMERALD_ORE or
		BlockType == E_BLOCK_LAPIS_ORE or
		BlockType == E_BLOCK_REDSTONE_ORE or
		BlockType == E_BLOCK_REDSTONE_ORE_GLOWING or
		BlockType == E_BLOCK_NETHER_QUARTZ_ORE or
		BlockType == E_BLOCK_DIAMOND_ORE 
		then
			return true
	else
		return false
	end
end
