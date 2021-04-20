g_PluginInfo =
{
	Name = "VeinMiner Plugin",
	Date = "2021-04-20",
	Description = "This Plugin emulates the VeinMiner plugin functionality for Cuberite. It breaks all ores similar to any initial broken ore.",

	-- The following members will be documented in greater detail later:
	AdditionalInfo = {},
	Commands =
	{
		["/toggleveinminer"] =
		{
			HelpString = "Enables/Disables the VeinMiner functionality",
			Permission = "veinmimer.toogle",
			Handler = Toggle,
		},
	},
	ConsoleCommands = {},
	Permissions = 
	{
		["veinminer.use"] =
		{
			Description = "Allows the Player to use the VeinMiner plugin",
			RecommendedGroups = "players",
		},
		["veinmimer.toogle"] =
		{
			Description = "Allows the Player to to toggle the VeinMiner functionality",
			RecommendedGroups = "players",
		},
	},
	Categories = {},
}
