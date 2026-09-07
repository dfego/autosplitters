state("Supraland-Win64-Shipping", "v1.23.7 Steam")
{
    bool inputDisabled : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x580, 0x390;
    bool gotSword : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7D8;
    bool gotSpeed : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DB;
    bool gotForceCube : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DC;
    bool gotLoot : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E4;
    bool gotDoubleJump : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DF;
    bool gotTripleJump : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E0;
    int maxCoins : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x830;
    bool gotGun : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E1;
    float gunRefireRate : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x0838;
    bool gotGunAlt : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E2;
    bool gotBelt : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E7;
    bool gotForceBeam : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EA;
    bool gotForceBeamGold : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB80;
    bool gotForceBeamCube : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EB;
    bool gotTranslocator : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7ED;
    float translocatorForce : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBC8;
    float translocatorCooldown : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBD0;
    bool strong : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB22;
    bool endgame : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC33;
}

state("Supraland-Win64-Shipping", "v1.23.9 Epic")
{
    bool inputDisabled : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x580, 0x390;
    bool gotSword : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7D8;
    bool gotSpeed : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DB;
    bool gotForceCube : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DC;
    bool gotLoot : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E4;
    bool gotDoubleJump : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DF;
    bool gotTripleJump : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E0;
    int maxCoins : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x830;
    bool gotGun : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E1;
    float gunRefireRate : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x0838;
    bool gotGunAlt : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E2;
    bool gotBelt : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E7;
    bool gotForceBeam : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EA;
    bool gotForceBeamGold : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB80;
    bool gotForceBeamCube : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EB;
    bool gotTranslocator : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7ED;
    float translocatorForce : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBC8;
    float translocatorCooldown : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBD0;
    bool strong : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB22;
    bool endgame : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC33;
}

startup
{
    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    settings.Add("gotSword", true, "Sword");
    settings.SetToolTip("gotSword", "Split on the player getting the sword.");
    settings.Add("gotSpeed", true, "Speed");
    settings.SetToolTip("gotSpeed", "Split on the player getting the speed upgrade.");
    settings.Add("gotForceCube", true, "Force Cube");
    settings.SetToolTip("gotForceCube", "Split on the player getting the force cube.");
    settings.Add("gotLoot", true, "Loot");
    settings.SetToolTip("gotLoot", "Split on the player getting loot upgrade.");
    settings.Add("gotDoubleJump", true, "Double Jump");
    settings.SetToolTip("gotDoubleJump", "Split on the player getting the double jump.");
    settings.Add("gotTripleJump", true, "Triple Jump");
    settings.SetToolTip("gotTripleJump", "Split on the player getting the triple jump.");
    settings.Add("maxCoins", true, "Max Coins Upgrades");
    settings.SetToolTip("maxCoins", "Split on the player getting a max coins upgrade.");
    settings.Add("gotGun", true, "Blaster");
    settings.SetToolTip("gotGun", "Split on the player getting the blaster.");
    settings.Add("gunRefireRate", true, "Blaster Fire Rate Upgrade");
    settings.SetToolTip("gunRefireRate", "Split on the player getting the gun fire rate upgrade.");
    settings.Add("gotGunAlt", true, "Blaster Alternate Fire");
    settings.SetToolTip("gotGunAlt", "Split on the player getting the blaster alternate fire.");
    settings.Add("gotBelt", true, "Magnet Belt");
    settings.SetToolTip("gotBelt", "Split on the player getting the magnet belt.");
    settings.Add("gotForceBeam", true, "Force Beam");
    settings.SetToolTip("gotForceBeam", "Split on the player getting the force beam.");
    settings.Add("gotForceBeamGold", true, "Force Beam Gold Upgrade");
    settings.SetToolTip("gotForceBeamGold", "Split on the player getting the force beam gold upgrade.");
    settings.Add("gotForceBeamCube", true, "Force Beam Cube Upgrade");
    settings.SetToolTip("gotForceBeamCube", "Split on the player getting the force beam cube upgrade.");
    settings.Add("gotTranslocator", true, "Translocator");
    settings.SetToolTip("gotTranslocator", "Split on the player getting the translocator.");
    settings.Add("translocatorForce", true, "Translocator Force Upgrade");
    settings.SetToolTip("translocatorForce", "Split on the player getting the translocator force upgrade.");
    settings.Add("translocatorCooldown", true, "Translocator Cooldown Upgrade");
    settings.SetToolTip("translocatorCooldown", "Split on the player getting the translocator cooldown upgrade.");
    settings.Add("strong", true, "Strong");
    settings.SetToolTip("strong", "Split on the player becoming strong.");
    settings.Add("endgame", true, "Endgame");
    settings.SetToolTip("endgame", "Split on the player reaching the endgame.");
}

init
{
    if (modules.First().ModuleMemorySize == 0x04b45000) {
        version = "v1.23.7 Steam";
    } else if (modules.First().ModuleMemorySize == 0x04b44000) {
        version = "v1.23.9 Epic";
    }
}

start
{
    return (old.inputDisabled && !current.inputDisabled);
}

split
{
    if (settings["gotSword"] && !old.gotSword && current.gotSword) return true;
    if (settings["gotSpeed"] && !old.gotSpeed && current.gotSpeed) return true;
    if (settings["gotForceCube"] && !old.gotForceCube && current.gotForceCube) return true;
    if (settings["maxCoins"] && old.maxCoins == 30 && current.maxCoins == 60) return true;
    if (settings["gotLoot"] && !old.gotLoot && current.gotLoot) return true;
    if (settings["gotDoubleJump"] && !old.gotDoubleJump && current.gotDoubleJump) return true;
    if (settings["gotTripleJump"] && !old.gotTripleJump && current.gotTripleJump) return true;
    if (settings["maxCoins"] && old.maxCoins == 60 && current.maxCoins == 120) return true;
    if (settings["gotGun"] && !old.gotGun && current.gotGun) return true;
    if (settings["gunRefireRate"] && old.gunRefireRate > 0.75 && current.gunRefireRate < 0.75) return true;
    if (settings["gotGunAlt"] && !old.gotGunAlt && current.gotGunAlt) return true;
    if (settings["gotBelt"] && !old.gotBelt && current.gotBelt) return true;
    if (settings["gotForceBeam"] && !old.gotForceBeam && current.gotForceBeam) return true;
    if (settings["gotForceBeamGold"] && !old.gotForceBeamGold && current.gotForceBeamGold) return true;
    if (settings["gotForceBeamCube"] && !old.gotForceBeamCube && current.gotForceBeamCube) return true;
    if (settings["gotTranslocator"] && !old.gotTranslocator && current.gotTranslocator) return true;
    if (settings["translocatorForce"] && old.translocatorForce < 900 && current.translocatorForce > 900) return true;
    if (settings["translocatorCooldown"] && old.translocatorCooldown > 1.5 && current.translocatorCooldown < 1.5) return true;
    if (settings["strong"] && !old.strong && current.strong) return true;
    if (settings["endgame"] && !old.endgame && current.endgame) return true;
}
