--!strict
-- Bottom-center placements. The starting sofa uses its native visible/collision parts;
-- keep the ambiguous imported sofa overlay disabled so it cannot obscure the corrected seat.
return {
    { Asset = "CeramicMug", Name = "LivingMug", Position = Vector3.new(4, 6.5, 1), Width = 1.7, Yaw = 0, Hide = { { "Accessories/LivingRoom", "CoffeeMug" } } },
    { Asset = "CeramicMug", Name = "KitchenMug", Position = Vector3.new(86, 6.7, 2), Width = 1.7, Yaw = 0, Hide = { { "Accessories/Kitchen", "BreakfastMug" } } },
    { Asset = "CeramicMug", Name = "GamerMug", Position = Vector3.new(100, 30.5, 97), Width = 1.7, Yaw = 0, Hide = { { "Accessories/Upstairs", "GamerMug" } } },
    { Asset = "PottedFern", Name = "LivingFern", Position = Vector3.new(39, 0, -30), Width = 3.8, Yaw = 0, Hide = { { "Accessories/LivingRoom", "CornerFern" } } },
    { Asset = "PottedFern", Name = "UpstairsFern", Position = Vector3.new(113, 24, -28), Width = 3.4, Yaw = 0, Hide = { { "Accessories/Upstairs", "UpstairsFern" } } },
    { Asset = "PottedFern", Name = "KitchenHerb", Position = Vector3.new(64, 6.7, -33), Width = 1.2, Yaw = 0, Hide = { { "Accessories/Kitchen", "KitchenHerb" } } },
    { Asset = "Toaster", Name = "KitchenToaster", Position = Vector3.new(67, 6.7, -32), Width = 4, Yaw = 180, Hide = { { "Accessories/Kitchen", "Toaster" } } },
    { Asset = "FruitBowl", Name = "KitchenFruit", Position = Vector3.new(91, 6.7, -1), Width = 4, Yaw = 0, Hide = { { "Accessories/Kitchen", "Fruit" } } },
    { Asset = "GameController", Name = "LivingController", Position = Vector3.new(28, 4, -32), Width = 3, Yaw = 0, Hide = { { "Accessories/LivingRoom", "TVController" } } },
    { Asset = "GameController", Name = "UpstairsController", Position = Vector3.new(87, 30.5, 96), Width = 3, Yaw = 0, Hide = { { "Accessories/Upstairs", "SpareController" } } },
    { Asset = "GamingMonitor", Name = "UpstairsMonitor", Position = Vector3.new(91, 30.5, 97), Width = 7, Yaw = 0, Hide = { { "Accessories/Upstairs", "GamingMonitor" }, { "Accessories/Upstairs", "GamingScreen" }, { "Accessories/Upstairs", "GamingGame" } } },
    { Asset = "DeskLamp", Name = "BedsideLamp", Position = Vector3.new(-11, 5, 99), Width = 3, Yaw = 0, Hide = { { "Bedroom", "LampStem-11" }, { "Bedroom", "LampShade-11" }, { "Accessories/Bedroom", "AlarmClock" }, { "Accessories/Bedroom", "ClockDisplay" } } },
    { Asset = "PictureFrame", Name = "LivingLandscape", Position = Vector3.new(23, 12, -37.05), Width = 11, Yaw = 180, Hide = { { "Accessories/LivingRoom", "Landscape" } } },
    { Asset = "PictureFrame", Name = "BedroomPicture", Position = Vector3.new(11, 12, 109.05), Width = 11, Yaw = 0, Hide = { { "Accessories/Bedroom", "BedPicture" } } },
    { Asset = "PictureFrame", Name = "UpstairsPicture", Position = Vector3.new(80, 35, -37.05), Width = 12, Yaw = 180, Hide = { { "Accessories/Upstairs", "LoungePicture" } } },
}
