// Supraland & Supraland Crash Autosplitter
// Author: Dan Fego / Delphi
state("Supraland-Win64-Shipping", "v1.23.7 Steam")
{
    // Both
    bool inputDisabled : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x580, 0x390;
    bool strong : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB22;
    bool gotSpeed : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DB;
    int maxCoins : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x830;
    bool gotForceBeam : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EA;
    bool gotForceBeamGold : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB80;
    bool gotForceBeamCube : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EB;
    bool gotForceCube : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DC;
    bool gotSword : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7D8;

    // Supraland
    bool gotLoot : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E4;
    bool gotDoubleJump : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DF;
    bool gotTripleJump : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E0;
    bool gotGun : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E1;
    float gunRefireRate : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x0838;
    bool gotGunAlt : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E2;
    bool gotBelt : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E7;
    bool gotTranslocator : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7ED;
    float translocatorForce : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBC8;
    float translocatorCooldown : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBD0;
    bool endgame : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC33;

    // Crash
    byte loop : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xD0C;
    bool jumpHeightPlus : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xCA0;
    bool gotForceCubeStompJump : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC8A;
    bool skillHasSmashDown : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E6;
    float translocatorWeight : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC90;
    bool translocatorModule : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC8B;
}

state("Supraland-Win64-Shipping", "v1.23.9 Epic")
{
    // Both
    bool inputDisabled : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x580, 0x390;
    bool strong : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB22;
    bool gotSpeed : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DB;
    int maxCoins : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x830;
    bool gotForceBeam : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EA;
    bool gotForceBeamGold : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xB80;
    bool gotForceBeamCube : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7EB;
    bool gotForceCube : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DC;
    bool gotSword : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7D8;

    // Supraland
    bool gotLoot : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E4;
    bool gotDoubleJump : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7DF;
    bool gotTripleJump : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E0;
    int maxCoins : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x830;
    bool gotGun : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E1;
    float gunRefireRate : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x0838;
    bool gotGunAlt : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E2;
    bool gotBelt : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E7;
    bool gotTranslocator : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7ED;
    float translocatorForce : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBC8;
    float translocatorCooldown : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xBD0;
    bool endgame : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC33;

    // Crash
    byte loop : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xD0C;
    bool jumpHeightPlus : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xCA0;
    bool gotForceCubeStompJump : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC8A;
    bool skillHasSmashDown : 0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x598, 0x7E6;
    float translocatorWeight : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC90;
    bool translocatorModule : 0x4687960, 0x180, 0x38, 0x0, 0x30, 0x598, 0xC8B;
}

startup
{
    // Set this at startup so we can change settings based on category.
    vars.isCrash = timer.Run.CategoryName.Contains("Crash");

    if (vars.isCrash) {
        settings.Add("splits", true, "Splits");
        settings.CurrentDefaultParent = "splits";

        settings.Add("jumpHeightPlus", true, "Jump Upgrade");
        settings.SetToolTip("jumpHeightPlus", "Split on the player getting the jump upgrade.");
        settings.Add("gotSpeed", true, "Speed");
        settings.SetToolTip("gotSpeed", "Split on the player getting the speed upgrade.");
        settings.Add("maxCoins", true, "Max Coins Upgrade (30 to 60)");
        settings.SetToolTip("maxCoins", "Split on the player getting the 30 to 60 max coins upgrade.");
        settings.Add("gotForceBeam", true, "Force Beam");
        settings.SetToolTip("gotForceBeam", "Split on the player getting the force beam.");
        settings.Add("gotForceBeamGold", true, "Force Beam Gold Upgrade");
        settings.SetToolTip("gotForceBeamGold", "Split on the player getting the force beam gold upgrade.");
        settings.Add("gotForceBeamCube", true, "Force Beam Cube Upgrade");
        settings.SetToolTip("gotForceBeamCube", "Split on the player getting the force beam cube upgrade.");
        settings.Add("gotForceCube", true, "Force Cube");
        settings.SetToolTip("gotForceCube", "Split on the player getting the force cube.");
        settings.Add("gotForceCubeStompJump", true, "Force Cube Stomp Jump");
        settings.SetToolTip("gotForceCubeStompJump", "Split on the player getting the force cube stomp jump upgrade.");
        settings.Add("skillHasSmashDown", true, "Smash Down (Loop 5)");
        settings.SetToolTip("skillHasSmashDown", "Split on the player getting back the smash skill near the end of the game.");
        settings.Add("gotSword", true, "Door Knocker");
        settings.SetToolTip("gotSword", "Split on the player getting the door knocker.");
        settings.Add("gotGun", true, "Mighty MacGuffin");
        settings.SetToolTip("gotGun", "Split on the player getting the mighty macguffin.");
        settings.Add("gotGunAlt", true, "Beam Weapon");
        settings.SetToolTip("gotGunAlt", "Split on the player getting the beam weapon.");
        settings.Add("translocatorWeight", true, "Translocator Weight");
        settings.SetToolTip("translocatorWeight", "Split on the player getting the translocator weight x3.");
        settings.Add("strong", true, "Strong");
        settings.SetToolTip("strong", "Split on the player becoming strong.");
        settings.Add("gotTranslocator", true, "Translocator");
        settings.SetToolTip("gotTranslocator", "Split on the player getting the translocator.");
        settings.Add("translocatorModule", true, "Translocator Teleport");
        settings.SetToolTip("translocatorModule", "Split on the player getting the translocator teleport module.");

        settings.Add("loops", true, "Loops");
        settings.SetToolTip("loops", "Split on the start of each game loop.");
        settings.Add("endscene", true, "End Scene");
        settings.SetToolTip("endscene", "Split on the beginning of the end cutscene.");
    } else {
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
}

init
{
    // Initialize these here so we don't get script errors.
    vars.oldEndsceneTriggered = false;
    vars.currentEndsceneTriggered = false;
    vars.currentLoop = 0;

    // This is where we separately track things that have happened to avoid weird issues with cutscenes
    // taking away our items.
    vars.triggered = new Dictionary<string, bool>();

    // Set the versions and initialize memory watchers used for the Crash end trigger.
    if (modules.First().ModuleMemorySize == 0x04b45000) {
        version = "v1.23.7 Steam";

        if (vars.isCrash) {
            DeepPointer numCutscenesPointer = new DeepPointer(0x4687960, 0x180, 0x38, 0x0, 0x30, 0x5C0 + 0x08);
            vars.numCutscenesWatcher = new MemoryWatcher<int>(numCutscenesPointer);

            DeepPointer cutsceneLookAtPointer = new DeepPointer(0x4687960, 0x180, 0x38, 0x0, 0x30, 0x5C0, 0x0, 0x2D0);
            vars.cutsceneLookAtWatcher = new MemoryWatcher<IntPtr>(cutsceneLookAtPointer);
        }
    } else if (modules.First().ModuleMemorySize == 0x04b44000) {
        version = "v1.23.9 Epic";

        if (vars.isCrash) {
            DeepPointer numCutscenesPointer = new DeepPointer(0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x5C0 + 0x08);
            vars.numCutscenesWatcher = new MemoryWatcher<int>(numCutscenesPointer);

            DeepPointer cutsceneLookAtPointer = new DeepPointer(0x46869a0, 0x180, 0x38, 0x0, 0x30, 0x5C0, 0x0, 0x2D0);
            vars.cutsceneLookAtWatcher = new MemoryWatcher<IntPtr>(cutsceneLookAtPointer);
        }
    }
}

start
{
    return (old.inputDisabled && !current.inputDisabled);
}

onStart
{
    // Reset these here so we don't get issues with back-to-back runs.
    vars.oldEndsceneTriggered = false;
    vars.currentEndsceneTriggered = false;
    vars.currentLoop = 0;
    vars.triggered = new Dictionary<string, bool>();
}

update
{
    if (vars.isCrash) {
        vars.numCutscenesWatcher.Update(game);
        vars.cutsceneLookAtWatcher.Update(game);
        vars.oldEndsceneTriggered = vars.currentEndsceneTriggered;
    }

    // The state for the endscene trigger is:
    // 1. The player is strong.
    // 2. The player is in a cutscene.
    // 3. That cutscene has a null LookAtThisObject1 pointer.
    //
    // These conditions should ideally restrict the endscene trigger that final
    // end cutscene, which is when the timer should stop.
    if (vars.isCrash &&
        settings["endscene"] &&
        current.strong &&
        vars.numCutscenesWatcher.Current == 1 &&
        vars.cutsceneLookAtWatcher.Current == IntPtr.Zero) {
        vars.currentEndsceneTriggered = true;
    }
}

split
{
    if (vars.isCrash) {
        // Prevent re-triggering on exiting to menu, because the loop will jump from 0 to the current one on loading in.
        // May be commented out because saving the script mid-run would mess this up.
        if (settings["loops"] && old.loop < current.loop/* && vars.currentLoop != current.loop*/) {
            vars.currentLoop = current.loop;
            return true;
        }
        // You get this twice -- once right away, then again later at the end. Only trigger on the loop 5 one.
        // I could have also checked for Strong, but this is fine.
        if (settings["skillHasSmashDown"] && current.loop == 5 && !old.skillHasSmashDown && current.skillHasSmashDown) return true;

        if (settings["endscene"] && !vars.oldEndsceneTriggered && vars.currentEndsceneTriggered) return true;
        if (settings["jumpHeightPlus"] && !vars.triggered.ContainsKey("jumpHeightPlus") && !old.jumpHeightPlus && current.jumpHeightPlus) {
            vars.triggered.Add("jumpHeightPlus", true);
            return true;
        }
        if (settings["gotForceCubeStompJump"] && !vars.triggered.ContainsKey("gotForceCubeStompJump") && !old.gotForceCubeStompJump && current.gotForceCubeStompJump) {
            vars.triggered.Add("gotForceCubeStompJump", true);
            return true;
        }
        if (settings["translocatorModule"] && !vars.triggered.ContainsKey("translocatorModule") && !old.translocatorModule && current.translocatorModule) {
            vars.triggered.Add("translocatorModule", true);
            return true;
        }

        // Floats are annoying. Just use big wide numbers to check.
        if (settings["translocatorWeight"] && old.translocatorWeight < 1.1 && current.translocatorWeight > 2) return true;
    } else {
        if (settings["gotLoot"] && !old.gotLoot && current.gotLoot) return true;
        if (settings["gotDoubleJump"] && !old.gotDoubleJump && current.gotDoubleJump) return true;
        if (settings["gotTripleJump"] && !old.gotTripleJump && current.gotTripleJump) return true;
        if (settings["maxCoins"] && old.maxCoins == 60 && current.maxCoins == 120) return true;
        if (settings["gunRefireRate"] && old.gunRefireRate > 0.75 && current.gunRefireRate < 0.75) return true;
        if (settings["gotBelt"] && !old.gotBelt && current.gotBelt) return true;
        if (settings["translocatorForce"] && old.translocatorForce < 900 && current.translocatorForce > 900) return true;
        if (settings["translocatorCooldown"] && old.translocatorCooldown > 1.5 && current.translocatorCooldown < 1.5) return true;
        if (settings["endgame"] && !old.endgame && current.endgame) return true;
    }

    // Splits that apply to both
    if (settings["gotSword"] && !vars.triggered.ContainsKey("gotSword") && !old.gotSword && current.gotSword) {
        vars.triggered.Add("gotSword", true);
        return true;
    }
    if (settings["gotSpeed"] && !vars.triggered.ContainsKey("gotSpeed") && !old.gotSpeed && current.gotSpeed) {
        vars.triggered.Add("gotSpeed", true);
        return true;
    }
    if (settings["gotForceCube"] && !vars.triggered.ContainsKey("gotForceCube") && !old.gotForceCube && current.gotForceCube) {
        vars.triggered.Add("gotForceCube", true);
        return true;
    }
    if (settings["gotForceBeam"] && !vars.triggered.ContainsKey("gotForceBeam") && !old.gotForceBeam && current.gotForceBeam) {
        vars.triggered.Add("gotForceBeam", true);
        return true;
    }
    if (settings["gotForceBeamGold"] && !vars.triggered.ContainsKey("gotForceBeamGold") && !old.gotForceBeamGold && current.gotForceBeamGold) {
        vars.triggered.Add("gotForceBeamGold", true);
        return true;
    }
    if (settings["gotForceBeamCube"] && !vars.triggered.ContainsKey("gotForceBeamCube") && !old.gotForceBeamCube && current.gotForceBeamCube) {
        vars.triggered.Add("gotForceBeamCube", true);
        return true;
    }
    if (settings["gotGun"] && !vars.triggered.ContainsKey("gotGun") && !old.gotGun && current.gotGun) {
        vars.triggered.Add("gotGun", true);
        return true;
    }
    if (settings["gotGunAlt"] && !vars.triggered.ContainsKey("gotGunAlt") && !old.gotGunAlt && current.gotGunAlt) {
        vars.triggered.Add("gotGunAlt", true);
        return true;
    }
    if (settings["strong"] && !vars.triggered.ContainsKey("strong") && !old.strong && current.strong) {
        vars.triggered.Add("strong", true);
        return true;
    }
    if (settings["gotTranslocator"] && !vars.triggered.ContainsKey("gotTranslocator") && !old.gotTranslocator && current.gotTranslocator) {
        vars.triggered.Add("gotTranslocator", true);
        return true;
    }

    if (settings["maxCoins"] && old.maxCoins == 30 && current.maxCoins == 60) return true;

}
