state("Supraland-Win64-Shipping")
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

start
{
    return (old.inputDisabled && !current.inputDisabled);
}

split
{
    if (!old.gotSword && current.gotSword) return true;
    if (!old.gotSpeed && current.gotSpeed) return true;
    if (!old.gotForceCube && current.gotForceCube) return true;
    if (old.maxCoins == 30 && current.maxCoins == 60) return true;
    if (!old.gotLoot && current.gotLoot) return true;
    if (!old.gotDoubleJump && current.gotDoubleJump) return true;
    if (!old.gotTripleJump && current.gotTripleJump) return true;
    if (old.maxCoins == 60 && current.maxCoins == 120) return true;
    if (!old.gotGun && current.gotGun) return true;
    if (old.gunRefireRate > 0.75 && current.gunRefireRate < 0.75) return true;
    if (!old.gotGunAlt && current.gotGunAlt) return true;
    if (!old.gotBelt && current.gotBelt) return true;
    if (!old.gotForceBeam && current.gotForceBeam) return true;
    if (!old.gotForceBeamGold && current.gotForceBeamGold) return true;
    if (!old.gotForceBeamCube && current.gotForceBeamCube) return true;
    if (!old.gotTranslocator && current.gotTranslocator) return true;
    if (old.translocatorForce < 900 && current.translocatorForce > 900) return true;
    if (old.translocatorCooldown > 1.5 && current.translocatorCooldown < 1.5) return true;
    if (!old.strong && current.strong) return true;
    if (!old.endgame && current.endgame) return true;
}