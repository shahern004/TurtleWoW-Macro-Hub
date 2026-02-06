# Warrior Raiding on Turtle WoW

***

## Intro

Warrior is no doubt the most important class of vanilla, and this is true even on Turtle WoW after two rounds of class changes. We boast some of the most game-changing cooldowns in lip+challenging shout and shield wall/recklessness, as well as the ability to swap between tank and dps on a dime, and providing important debuffs in sunder armor/demo shout/thunder clap. This is all on top of having two of the top five overall DPS specs in the game, and the most versatile tank spec in the game in furyprot. The only thing a warrior can't do is heal, but even after CC2 you can somewhat heal yourself while farming with blood drinker now. I highly recommend anyone that hasn't tried a warrior at 60 yet to try the updated leveling experience and give warrior raiding a shot. The biggest problem with the class at this point is that so many people play it, which is a good problem to have.

***

## General

### PRESS SUNDER ARMOR

EVERY SINGLE MOB THAT LIVES FOR MORE THAN 4 SECONDS IN RAID SHOULD BE SUNDERED. THIS IS NOT ONLY THE TANKS JOB, OR THE FURY WARRIOR'S JOB, OR THE ARMS WARRIOR'S JOB. EVERY WARRIOR AUTOATTACKING A MOB SHOULD SUNDER IT AS THEIR FIRST AND MOST IMPORTANT ACTION.

If every warrior in the raid sunders the target, you should get 5 sunders instantly. If sunders fall off, you get them back up. If SKULL has five sunders and CROSS has none, swap target and sunder it. Very few mobs in raid shouldn't be sundered at all.

You do almost 40% more flat damage vs a mob with 5 sunders compared to a mob without. This increased damage means more rage, which means more abilities, which means more damage. And importantly, it means the tank does more threat, so THE ENTIRE RAID can do more damage. 

***

### Macros / Keybinds / Setup

The very first thing I recommend to any new warrior is writing `/startattack` macros into all of their abilities. One of the biggest DPS losses for overall (boss + trash) damage is auto-attack uptime, and a very easy way to significantly increase uptime is by ensuring that pressing any of your abilities toggles your auto-attack on.

You can do this by installing an addon like [SuperCleveRoidMacros](https://github.com/jrc13245/SuperCleveRoidMacros) and writing a macro like the one listed below:

```
/run --CastSpellByName("Sunder Armor")
/startattack
/cast Sunder Armor
```
You can then put this on your bars wherever you previously had Sunder Armor, and it will dynamically display both the tooltip and the cooldown thanks to the first line (little roidmacros trick).

***

### Consumes

Recommended consumes have a checkmark below. Non-recommended consumes have no checkmark.

- [x] Juju Power. Purchaseable on the AH as "Winterfall E'ko". Requires a short prequest in Winterspring and the Cache of Mau'ri in your inventory when using. Can be farmed from the same mobs as firewater.

- [ ] Elixir of Giants. Craftable by alchemists, or purchaseable on the AH. Doesn't stack with Juju Power.

- [x] Winterfall Firewater. Purchaseable on the AH, or farmable from furbolgs around Winterspring.

- [ ] Juju Might. Purchaseable on the AH as "Frostmaul E'ko". Doesn't stack with firewater, gives 5 more AP, but lasts only 10 minutes. Leave these to hunters who can't use firewater, unless you're parsing a specific boss. Too expensive to use all the time compared to the much cheaper and easy alternative.

- [x] Juju Flurry. Purchaseable on the AH as "Frostsaber E'ko". Neat little button to press during last 20s of your death wish, or on trash pulls. Easy to forget about, best to macro this into your abilities if you care about that sort of thing. Not worth buying compared to farming from the cats in winterspring.

- [x] Elixir of the Mongoose. Craftable by alchemists, or purchaseable from AH. Doesn't fade on death, so very high bang for your buck.

- [x] Elixir of Fortitude. Craftable by alchemists, or purchaseable from AH. 

- [ ] Elixir of Superior Defense. Craftable by alchemists, or purchaseable from AH. Only recommended for tanks.

- [x] Power Mushroom. Obtained from the gardening profession, or purchasable from AH. 

- [x] Smoked Desert Dumplings. Farmed from Silithus mobs and cooked, or purchaseable from AH. Doesn't stack with power mushrooms, but easy to farm solo if you don't know how to do gardening. 

- [ ] Hardened Mushroom. Obtained from the gardening profession, or purchaseable from AH. Doesn't stack with other foods, and only recommended for tanks or very high raid damage pulls/progression/hardcore. If you're really health maxxing, stacks with Gurubashi Gumbo for an extra 10 stam.

- [x] Rumsey Rum Black Label. Fished from high level pools or purchaseable on AH. 

- [x] Medivh's Merlot. Looted from barrels in lower kara. Doesn't stack with rumsey rum, but gives 10 more stamina, though more expensive to compensate.

- [x] ROIDS. Farmed from Blasted Lands quest (The Rage of Ages), or components bought from AH (snickerfang jowls, blasted boar lungs, scorpok pincers)

- [x] Ground Scorpok Assay. Farmed the same way as ROIDS, and doesn't stack with them. Only recommended as a lower geared fury without much crit for flurry uptime, or for furyprot.

- [ ] Boar Lung Juice. Farmed the same way as other blasted lands buffs, doesn't stack with them, but also doesn't stack with zanza. Only recommended for those without rep for zanza.

- [x] Spirit of Zanza. Obtained from a repeatable quest at the troll island in NW stranglethorn vale, only with Revered Zandalar Tribe rep. Tokens can be bought from AH or looted from ZG runs as Hakkari Bijous or sets of coins. The best consume in terms of bang for your buck, it lasts two hours.

- [ ] Swiftness of Zanza. Obtained the same way as spirit of zanza. Only recommended if you dont need the stamina (its 550 hp bro wtf), and don't have a druid in raid for the Emerald Blessing movespeed buff.

- [ ] Flask of the Titans. Expensive as hell. Crafted by alchemists with the (rare) recipe, and only in BWL. Only recommended for progression, or sub 2 hour naxx clears for sweaty gamers. In comparison Spirit of Zanza is THREE gold and gives almost half as much stam, and like flask doesn't fade on death. Now imagine using both.

- [x] Mighty Rage Potion. Craftable by alchemists or purchaseable on the AH. You should at least have these in your bags, warriors that want to push their limits will use these on every boss fight, and some trash. Basically an extra active trinket. Don't recommend using these as main tank, since you want to use stoneshields instead. 

- [x] Great Rage Potion. Craftable by alchemists or purchaseable on the AH. Cheap version of mighty rage, a lot of people swear by these especially while in lower raids or in worse gear where rage generation is overall worse. Doesn't have the +str effect like mighty rage but gives a considerable amount of instant rage that can make the difference if you get ragestarved.

- [ ] Greater Stoneshield Potion. Craftable by alchemists or purchaseable on the AH. Great for maintanks in upper tier raids, or any tank in progression. Mitigates a ton of damage over its duration, but quite expensive for each use.

- [x] Consecrated Sharpening Stones. ONLY IN NAXX VS UNDEAD MOBS. Obtained from repeatable Argent Dawn quest or purchaseable on the AH. Probably the best dps consume in the entire game when you get to use it, you can literally feel the damage difference immediately after putting them on. Can safely put them on both mainhand and offhand after patch 1.17.2

- [x] Elemental Sharpening Stones. VS ANYTHING THAT ISNT UNDEAD. Crafted by blacksmiths, or purchaseable on the AH. Not quite as good as consecrated, but can be used in any raid at any time. Especially nice for fury and furyprot who value crit higher than arms/deep prot. Pretty expensive but worth it imo.

- [x] Free action pots/protection pots/juju ember/juju chill/frozen runes/nordanaar herbal tea/etc. Required for any raid content, depends on the exact raid and your guild ofc. If you don't keep yourself alive with these, what was the point of showing up in the first place.

- [x] Goblin Sapper Charges/Dense Dynamite/Stratholme Holy Water. First two are crafted by engineers and purchaseable on the AH, both require engineering to use. Great for aoe trash pulls. Holy water is looted from stratholme in the crates scattered around the instance. Unlike the other two it doesn't require engineering, but is only useable vs undead mobs. Causes 0 threat, and scales with spellpower if for some reason you enjoy using SP consumes.

- [x] Limited Invulnerability Potions (LIP). One of the most powerful consumes in the game, it serves two purposes. Firstly, it's your safety net when you rip threat both on trash or bosses. You can pre-emptively use this, and then dump a fat WW+cleave+sapper and the mobs will just ignore you. Secondly, it's essential when used in conjunction with **challenging shout**. I recommend keybinding both close to eachother, so you can hit LIP -> challenging shout, which is a 6 second immune-to-damage aoe taunt. Any warrior needs to be ready to do this at any moment on trash/bosses when a raidleader calls for it.

***

## Fury

### Playstyle

Fury is one of the most dynamic and interesting specs in the entire game. Your rotation can include up to 15 different abilities, all important, and all used at different times, depending on rage, number of mobs, weapon, mob positioning, and a bunch of other factors. This sounds intimidating at first but this is the exact thing that makes fury so fun to play; someone might have relatively more execute damage because they like maximizing their executes on trash, someone else might have more cleaves than everyone else because they press it as much as humanly possible, someone else might have the most ability casts on bosses because they perform their bloodthirst/whirlwind/HS/hms/execute in a super clean way.

Overall, there is almost never one specific "correct" button to press in a given situation, there is generally just more intelligent and less intelligent ways of utilizing your rage resource. This is best represented by thinking of your buttons in terms of a priority system. Sometimes, the best thing you can do is press nothing at all.

Fury is a spec that benefits the most from using cooldowns on aoe/cleave pulls, or very short (sub 60 second) boss fights. Ideally you keep death wish on cooldown by using it on as much aoe as possible without depriving from boss usage. If you've gone more than 5 minutes without pressing death wish, you almost certainly missed an opportunity to use it. **On most bosses, you should aim to time your death wish to run out exactly as the boss dies**. The same is true for your trinkets, and other cooldowns like berserking/blood fury/recklessness. Learning to perfect this is key to maximizing fury dps, since your damage spikes heavily when you can use execute.

Recklessness is best planned ahead of time based on the raid speed, since the cooldown is so long. You might choose to use it on the same bosses every week, or alternate different bosses to show up higher on turtlogs if you're a rankings player. Don't be afraid to use it on huge aoe trash pulls if that's what makes you happy.

Higher prio abilities are higher on the list, rotations are listed below.

**Single target DW fury**: 

1. Sunder Armor  until the mob has 5 sunders.
2. Execute  if the mob has less than 20% hp, whenever you have enough rage to use it. Sometimes it's better to use bloodthirst instead if certain conditions are met, this is touched on in a section below.
3. Bloodthirst . Keep this on cooldown as much as you possibly can. When whirlwind has 1 second left on cd and bloodthirst has 2 seconds, don't press whirlwind. Wait and press bloodthirst (this comes up a lot).
4. Whirlwind . Keep this on cooldown as much as you can without clipping bloodthirst cd. If using a dagger mainhand, prio this below HS.
5.  Heroic Strike . This is one of your rage dumps, and it makes your mainhand both unable to MISS or GLANCE while hitcapped. Causes excess threat compared to damage dealt, so this is the first thing you stop pressing if threatcapped.
6. Master Strike/Pummel/Hamstring/Sunder . This is solely to try to proc windfury/flurry/crusader/weapon procs, it should never clip your bloodthirst/whirlwind cd, or prevent you from using HS.

**Multi target DW fury**:

1. Sunder Armor  first gcd. You don't need to sunder every mob to 5 on aoe pulls, but at least sunder each mob you auto once.
2. Whirlwind . This spikes in value massively when fighting more than one mob, since the damage is duplicated for each mob nearby up to 4.
3.  CLEAVE . By far the best and most consistent ability you have for AOE in your toolkit. Has no cd, only tied to your swing timer. Deprives you of the rage from the swing, which you gain back from your offhand hit and possible windfury proc. This button is the reason we are a top dps spec. 
4. Execute . Still does insane damage on aoe packs, but not as much as whirlwind. Execute on trash can be a gear luxury, so you might consider skipping it if you find yourself ragestarved going into packs after.
5. Bloodthirst . Kind of outshined by other buttons on aoe since they hit two or four mobs at once, or do a stupid amount of damage of frontloaded damage like execute.
6. Master Strike/Pummel/Hamstring/Sunder . Really not important to be pressing during aoe since the windfury procs you gain delete your cleaves by turning them into regular autos. Still great to sunder random un-sundered mobs though.

***

**Single target 2h fury**:

Mostly the same as DW fury, but  Heroic Strike  is very low prio. Instead of  Heroic Strike  you use  Slam  right after your swing hits. As of 1.18  Slam  cast time scales with flurry, and haste from gear, so you can sometimes even fit two slams in one auto if using a 3.7/3.8 wep. Depending on your talent build (if you have bloodthirst or not) you will be using slam on practically every swing on single target, similar to single target arms. Overpower  is considerably better for 2h fury than DW fury, especially in lower gear. Try not to waste rage by swapping stance too much for it.

**Multi target 2h fury**:

Same as DW fury, with even more emphasis on ww/cleave, and sometimes utilizing slam on mobs that live longer.

**note** When is bloodthirst > execute?
    As hinted above, it can be a more efficient use of your rage to press bloodthirst instead of execute, which may sound paradoxical at first; isn't our damage supposed to spike during execute? We can use bloodthirst all the time!
    This is a quirk of the formula for bloodthirst at high levels of AP. Since execute does a static amount of damage per point of rage while bloodthirst scales with your AP, it's a more efficient use of 30 rage to press a >2000 AP bloodthirst compared to a 30 rage execute. This value is obtained from combining both formulas: execute does 600 + 20\*15 = 900 damage at 30 rage, while bloodthirst does 200 + 0.35\*X, where X is your AP. This means when 200 + 0.35\*X > 900, your rage is better spent on bloodthirst (and the value of X that solves this is 2000)
    There is a caveat with this however, which is that any rage over 100 is completely wasted, and bloodthirst being more damage *per rage* is irrelevant at that point since you essentially just threw extra damage down the drain in the form of rage.
    **This means that you only want to use bloodthirst instead of execute, when you are**:
    - Above 2000 AP
    - Between 30-60 rage
    - Not having insane constant rage income from recklessness/loatheb buff/thaddius buff/raid damage
    - Expecting to get at least one more gcd to use execute afterwards

***

### Talents

This is the current DW fury build as of 1.18:

[17/34 DW Fury](https://talents.turtlecraft.gg/warrior?points=dQIAIYAQ-AoFAoAAoZCVAB-)

Improved berserker rage, added in 1.18, is a huge sleeper talent for raiding fury warriors. You can dispel almost any slow in any raid at 30s cd, even stuff like curses: curse of the rift/king's curse in kara40, noth cripple and gothik horse stomp in naxx. You can even dispel things like mind flay on scientist packs to remove it from the entire raid, and roots like on anub'rekhan or ZG spider boss.

***

There are currently two potential specs for 2h fury, depending on whether or not you drop bloodthirst to pick up sweeping strikes. 

[21/30 2h Fury](https://talents.turtlecraft.gg/warrior?points=NQQACYDQB-AoAooAAoZBF-)

[20/31 2h Fury](https://talents.turtlecraft.gg/warrior?points=NQQACYDQ-AoAooAAoZBFAB-)

Despite only differing by one talent point, these specs are rotationally distinct. Sweeping strikes allows for a ton of aoe burst when combined with enrage+DW+trinket, though you lose out on bloodthirst for single target. With current numbers it seems like bloodthirst does the same or less damage than slam in bis gear, so just using slam whenever you would use bloodthirst otherwise should work out on single target.

***

### Trinkets / Cooldown usage

Both trinkets and your ability cooldowns (death wish, recklessness, bloodrage, and any racial you might have) are completely crucial to your damage in raids as a warrior. The inherently high damage of aoe phases and <20% hp execute phases serve as ideal points to stack these cooldowns. In a two hour raid, you should be using death wish close to 30 times, and any trinkets (depending on cd ofc) close to 40 times. It's better to use cooldowns (close to) on cooldown than waste time waiting for the perfect opportunity to use it, similar to any class. 

As mentioned above, on most boss fights you want to time your death wish with boss death, to both take advantage of the damage spike in execute phase, and maximize the damage before that as much as possible. 30 second cooldowns are pressed 30 seconds before boss death, 20 second cooldowns 20 seconds before boss death, and 15 second cooldowns 15 seconds before boss death. There is debate about whether or not you should use mighty rage potion with that 20-second timing or if you should save it to take full advantage of the rage gain for a specific execute gcd, but there isn't really a clear correct winner there.

Keep in mind that if you are unfamiliar with your raid's kill times, or they seem to vary a lot from week to week, it's better to use them early rather than late. You will lose more damage from only having 25 seconds of your death wish but having it for the whole execute phase, compared to having a full 30 seconds where the last 5 seconds of execute phase had no cds. **A great way to get a feel for your raid's kill times is recording your gameplay each week**. You can then note the boss hp% 30 seconds before death, and know to use your cds right before that hp% next week.

The new bloodrage-enrage proc interaction is overlooked, but it is *very* powerful especially for trash. Considering trash pulls never last a full minute, the relative uptime on it is quite high, and it should be pressed literally as much as possible while in combat, while not depriving from use during boss execute phase. It's like a more frequent death wish in a way, since the cooldown is one-third as long, and it lasts one-third as long.

***

## Arms

### Playstyle

Arms is the trash melting spec. If you want to see big numbers on trash and may not have the best gear, this is the spec for you. Despite what you may think, arms is less focused on cleaving than fury. Instead, it relies on sweeping strikes and whirlwind damage.

Another important important distinction of arms is that unlike DW fury, you only need one weapon. It can be slightly easier to get going with arms as a fresh warrior since you don't need to hunt two different drops in each raid tier to maximize your performance. In addition, a lot of good two-handers are found in MC and BWL, and don't need to be upgraded until naxx. Having said that, 2h fury is a more than viable option that only needs one weapon.

The spec loses some power and interaction by not having the cooldowns of fury, but gains it back in the form of extra attacks and the master of arms talent, as well as mortal strike, which hits about 20% harder than bloodthirst in equal gear. When using a mace (including the illustrious MoM or shart) it gains 360 flat armour penetration, which on most bosses and a lot of trash translates to about a 7-8% raw dps increase. Axe spec is 5% raw crit, which is equal to if not better than mace spec in many situations. In addition, slam has been changed to allow your weapon swing timer to keep going in the background, only pausing if the swing is complete to wait until your slam is finished. All of these factors serve to make arms rotation a calculated, swing-timer based single target rotation in contrast to DW fury:

Enrage from bloodrage is an optional talent choice for arms as of 1.18; you can use it for +20% damage for 8 seconds similar to fury, though you might not want to save it for execute like a fury warrior would and instead use it during trinkets/recklessness etc during burst phase/aoe.

**Single target arms**: 

Sunder Armor  \->  Slam  \-> (auto) \-> Mortal Strike  \->  Slam  \-> (auto) \-> Whirlwind  \->  Slam  \-> (auto) \-> (repeat, starting from mortal strike) 

\->(target at 20% hp) Execute 

!!! note
	If your auto just went off, and both MS and WW are on cd, you can do Slam \-> Slam if your weapon speed is slow enough (between 3.6-3.8). If you would ragecap with your next swing, you can queue a Heroic Strike instead for a bit of extra damage. In low gear, when you get dodged you can use Overpower instead of Slam if it doesn't lose you much rage from swapping. Also, when a mob is about to hit 20% hp, you should pause your rotation momentarily to pool rage for a 120 rage execute immediately. Afterwards, if your swing isnt about to happen, you can use a mighty/great rage potion and get another high rage execute using the rage refund, then swing and get a third high rage execute. 

If using a 3.4 speed wep, or if you have a decent amount of haste, you can instead open with:

Sunder Armor  \->  Slam  \-> (auto) \-> Mortal Strike  \-> Whirlwind   \-> (auto) \->  Slam  \-> (auto) \-> (MS>WW on CD>Slam)

\-> (target at 20% hp) Execute  (but weave in slam/MS before pressing it)

There are many variables that can change your rotation, be dynamic, don't overthink it. Prioritize keeping Mortalstrike and Whirlwind Cooldowns rolling after you sunder. If you're under-geared and/or rage starved, it's often preferable to Slam instead of using Whirlwind.

***

AoE rotation is quite different, and follows more of a priority system similar to how fury plays, since you shouldn't really use slam.

**Multi target arms**:

(prepop Sweeping Strikes as early as possible and use again during the pull)

1. Whirlwind . Hits like an absolute truck when you have Sweeping Strikes up. Be prepared to LIP if you find yourself ripping threat and getting too low from using this frequently on trash.

2. Sunder Armor . You don't need to sunder every mob to 5 on aoe pulls, but at least sunder each mob you auto once.

3.  Cleave . Still great to keep queued for aoe, but your inherently slow swing timer (no flurry) means it's not quite as high dps overall compared to your instants. Best part of cleave is you can keep it queued in the background while pressing everything else.

4. Mortal Strike . Technically last in your aoe ability rotation, but gets used every single aoe pack many times nonetheless. Great damage for the rage cost when your gcd is open after Whirlwind .

5. Execute . Heavily nerfed since 1.17.2, only worth using as a last gcd or when using mighty rage potions.

!!! info Arms quirks to keep in mind
	There are a few small quirks of arms that are often overlooked. The first is that you can queue cleave/heroic strike before your slam, and your bars will get grayed out, but you will still get a heroic strike/cleave instead of an auto.  The second and more esoteric trick relies on some knowledge of your raid's pace. It is best to use sweeping strikes as early before a pull as possible, while ensuring that you can still use all the charges on pull. This is because the cooldown on sweeping strikes starts upon using it, and the charges last for almost the entire cooldown. The consequence of this is that you can run into pulls with sweeping strikes charges about to expire, then whirlwind, swap stance as sweeping strikes comes off cooldown, use it again, swap stance, then cleave/mortal strike and get a second set of sweeping strikes charges.

### Talents

There is not much variation in arms talent choice, since the good talents are very clear cut. Most of the changes you might make are at the top of the tree, and are just choosing a different combination of charge/overpower/heroic strike/parry. Here is one common build:

[Arms 31/20](https://talents.turtlecraft.gg/warrior?points=dQAAKYDQpIQAB-AoAooAAo-)

### Weapons

There are less two-handers overall to choose from than one-handers, but many are absolute powerhouses that are hard to replace. Ideally you want a slow (3.5-3.8) weapon, since most of your abilities (mortal strike, whirlwind, cleave, sweeping strikes) use weapon damage instead of AP. Standout 3.4 weapons exist, those being Bonereaver's Edge (BRE) and The Untamed Blade (UTB), which both have such insanely overtuned procs that they are usuable until late naxx despite their speed. Anything faster than 3.4 is borderline unusable currently. 

## Furyprot (by Sayeana aka Marinatall Ironside)

Before going Furyprot, you have to decide if your group is already performing at a sufficiently high level to justify having a Furyprot warrior on the roster. If your healers aren’t that great and DPS threat isn’t too much of a problem mostly due to undergeared players, you’re better off choosing at least the Deep Prot warrior build, or Defensive Tactics tanking. Both have more than adequate threat generation, while giving you the mitigation to keep your incoming damage under control for those scenarios. Those same tank builds also works exceptionally well in smaller/bad raid comps. But if your group has amazing healers, you have mad pumpers, and a very good comp, then Furyprot is the way to go.

Despite the versatility that Furyprot brings into a raid, they’re not great at any particular niche besides having the most cooldowns. There may be times when even if you’re in full mitigation gear with a shield equipped, the Defensive Tactics build offers more mitigation while sacrificing little overall threat and some cooldowns. Your raids shouldn’t exclusively rely on Furyprot warriors, and you should also consider setting up a Defensive Tactics build for those exceptionally mitigation-heavy fights. Having prot paladins, bear tanks, and shaman tanks to synergize with the Furyprot warrior is always the best thing to have in a raid.


### Playstyle

This is primarily written by a warrior who primarily DPS’s, and tanks when required. The tanking gear from all stages of the game are suitable for Furyprot in raid instances one tier above a given gearset.

Furyprot combines elements from both the Fury tree and the Protection tree by heavily leaning into Fury for its high DPS/Threat generation and the key defensive elements of Protection, hence the name Furyprot. This build back then had the potential for some of the most explosive snap threat that can be generated within a few GCDs, and it still remains the case here on Turtle WoW. Despite some of its power being lost to the Defensive Tactics Prot build, Furyprot still remains not only a relatively popular warrior tank spec, but it still has advantages that the other tank builds don’t have. One advantage is they have two powerful offensive cooldowns in the form of Death Wish, and the Bloodrage-Enrage interaction they share with Fury DPS, the latter of which is often overlooked. 

The key advantage is they’re not pigeonholed into sword-and-board all the time compared to Defensive Tactics or Deep Protection due to Defensive Tactics and Shield Slam mechanics. Furyprot can use a shield, which makes for a solid middle ground between dual-wield tanking and sword-and-board tanking. When the Furyprot warrior is dual-wield tanking, they significantly raise their threat ceiling, so the whole raid can do more damage. However, any time you’re dual-wield tanking, you take significantly more damage, which you can really feel. You’re also asking for much more healing from your healers to compensate for the increased incoming damage. You can mitigate this downside by using Greater Stoneshield Potions on cooldown on every boss fight.

The key disadvantage that Furyprot has in any scenario is they are effectively locked into Defensive Stance for the entirety of a fight, only switching out of it to use stance-specific abilities. An important skill to learn as Furyprot is pooling rage so you can begin frontloading aggro before your DPS’ers begin DPS’ing them. Some groups will have a call where all the warriors and the bear tank just auto-attack trash mobs to get a full rage bar just before pulling a boss for the sake of speed-killing them.

!!! info

	I recommend any and all Furyprot warriors to have both shield swap and dual wield swap macros written and keybound. If you have RoidMacros or CleveRoidMacros installed, the macros look like this: 
	For shield swapping: /equip <your shield here> (put this into your Shield Block and Shield Bash macros)
	For DW swapping: /equipoh <your off hand weapon here> (make this its own macro)
	Be sure to delete the <> when you write the macros, otherwise they won’t work.

**Single target furyprot**: 

Similar to how DW Fury plays, you’re following a priority system, using abilities based on how much damage and threat the abilities do for every point of rage used. The following priority list below is taken from the DW Fury section found earlier in this guide, with some added/modified notes.

(prepop Greater Stoneshield Potion on bosses after popping any magic protection pots you may need beforehand. use a Free Action Potion instead on Gehennas, Sulfuron Harbinger, and Razorgore the Untamed (Phase 3) because the bosses stun. Use those +2000 armor potions on CD)

1. Sunder Armor  until the mob has 5 sunders. If you don’t have Revenge up, this is your next ability to use after Bloodthirst. You and your other warrior brothers and sisters should be PRESSING THIS ABILITY, NOT JUST YOU!

2. Bloodthirst . Keep this on cooldown as much as you possibly can. If you are threatmaxxing with endgame BIS gear and full raid buffs, this ability can hit incredibly hard, making it a significant threat generator per cast.

3.  Heroic Strike . This is one of two rage dumps, and it makes your main hand both unable to MISS or GLANCE while hit capped. Any time you have insane amounts of rage being generated, this becomes responsible for a massive portion of your threat generated, thanks to a high static threat modifier. At low rage amounts, you stop queueing this ability so you can use your more efficient threat generators.

4. Revenge . Anytime you block, dodge, or parry an attack, and this is off CD, use this right after Bloodthirst. If you’re using this before Bloodthirst, try not to clip its CD on this ability. You can force this to always be active by using a shield and using Shield Block. While it has the best threat per rage in our toolkit, it does not scale at all from weapons or stats.

5. Battle Shout . If you want to do single target threat and don't want to cause more parries, battle shout does slightly more threat than sunder assuming you hit all of your party members, but it doesn't proc windfury or thunderfury. Sundering is on pretty equal prio to this if there are 5 sunders up already, and sunder pulls ahead if there's more than 1 mob since battle shout threat is split.

6. Shield Bash. Can only be used if you have a shield equipped. You really only use this ability to interrupt spellcasting. Can be used in Defensive Stance, unlike Pummel, which can only be used in either Battle Stance or Berserker Stance. Almost every mob can be interrupted. Abuse it. DON’T LET HEALERS SPAM HEALS!

**Multi target furyprot**:

While warrior tanks can AOE tank, it is such an uphill battle if you don’t have a Force Reactive Disk, Thunderfury, or both. You’re mostly relying on tab-targeting to hit mobs with your abilities, as well as dynamite, sappers, and oils of immolation for AOE threat. If possible, try to keep those pulls to 4 mobs at a time to not overwhelm yourself and your party members.

1. Sunder Armor  first AOE. You don't need to sunder every mob to 5 on AOE pulls, but at least sunder each mob you auto once.

2. CLEAVE . By far your best and most consistent ability you have for AOE in your toolkit. Has no CD, only tied to your swing timer. Deprives you of the rage from the swing, which you gain back mostly from incoming damage. This ability is what lets us quickly establish threat on two targets, and quickly build threat on more than two. What the tooltip doesn’t disclose is there’s a static threat modifier in the ability, albeit lower than that of Heroic Strike.

3. Bloodthirst  Kind of outshined by Cleave on AOE since it hit two mobs at once. This still gets used a lot, even on AOE pulls. Great for building aggro on high-priority kill targets.

4. Thunder Clap  Zero scaling, but it still generates a good amount of threat for its rage cost when you can hit 4 mobs with it. Thunder Clap applies a -10% attack speed debuff on targets it hits, which is a pretty good source of damage reduction in any scenario not involving Thunderfury

5. Revenge . Mostly the same as single target, but if you have a shield equipped for AOE pulls, you can get some blocks passively from having 4+ mobs hitting you at once. You’re basically keeping this on CD if you have everything else on CD too.

6. Demoralizing Shout . Good to press once at the start of the pull to cause everything to auto you once for rage. Battle shout does the same but splits all its threat among all targets while demo is a flat amount.

7. Shield Bash . Same rules as single-target, but healer mobs have #1 prio on interrupts, then healing reduction debuffs, then slows.

**Cooldowns**:

Aside from any active on-use trinkets you may be wearing at any given moment, and active DPS racials available for your race, you have access to some important, high-impact cooldowns too. Furyprot has the most number of cooldowns out of any tank, and it is a healthy mixture of offensive and defensive cooldowns, with a dash of utility abilities that’s shared with any warrior build.

1. Death Wish . One of the key selling points of Furyprot, since it lets you frontload a huge amount of threat over its entire 30-second duration. The armor reduction portion can be somewhat countered by using a Greater Stoneshield Potion, but you’re still taking significantly more damage while it's active. Depending on the fight this gets used on, it may get you killed. Your healers need to be made aware when you activate this ability so they can increase their healing throughput on you.

2. Bloodrage . As it’s been emphasized in this guide up to this point, the Bloodrage-Enrage interaction is shared with Fury DPS, and Furyprot uses this interaction slightly differently. This cooldown is saved for the boss pull as a powerful, safe opener buff to quickly establish a threat lead. The Bloodrage-Enrage interaction goes well beyond merely using it for the instant 15 rage. You still use this on cooldown on trash fights during combat, because it also really helps with threat on trash, since damage dealers tend to DPS hard here.

3.  Taunt . Most mobs can be taunted if you lose aggro on them. Use this if a DPS’er is taking too much damage or if the mob goes to your healer, or when you perform a taunt swap when it’s called. This also forces the mob to fixate you for 3s, even if someone overtakes you on aggro. Contrary to the rest of your abilities, this, Thunder Clap, and all shouts are considered spells.

4.  Challenging Shout . Makes all affected targets focus attacks on you for 6 seconds. Combined with LIP, this becomes the most high-impact raid cooldown in the game. Any warrior should know this combo to abuse threat mechanics and help the rest of your DPS’ers (including other warriors) AOE mobs down by rotating the LIP+Challenging Shout cooldown between warriors. Its long cooldown means you can only LIP+AOE taunt once every 10 minutes.

5.  Mocking Blow . Makes whoever you use this on focus attacks on you for 6 seconds. The LIP and Mocking Blow cooldowns are the same, allowing you to LIP+Mocking Blow every two minutes, unlike LIP+Challenging Shout. Don’t waste money ranking up this ability. This can only be used in Battle Stance.

6.  Disarm . Any mob that can be disarmed makes this an extremely potent damage reduction cooldown. You can rotate Disarm with your other warriors to constantly swipe the mob’s weapon from them to extend the amount of time a mob spends punching you, not swinging a weapon and chunking your health.

7.  Shield Block . Usable only when you have a shield equipped, this almost guarantees that the next melee attack is blocked. A blocked attack cannot crit or crush, and while blocking attacks somewhat reduces the amount of damage you take against bosses, being able to avoid crits or crushes by blocking attacks is a substantial increase to your survivability.

8.  Last Stand . This temporarily increases your maximum health by 30% for 20s, after which you lose the bonus health. Its long cooldown of 10 minutes means it’s generally used to prepare for incoming large hits or extended lengths of no healing to reduce your chances of dying. It’s better to be talented in it and not needing it, than needing it but not having it talented.

9.  Shield Wall  Can only be used while a shield is equipped, and its effect continues for 10s while you’re still wearing a shield. Reduces all damage taken by 75%, which makes it one of the most high-impact defensive cooldowns in the game. While you should plan ahead on what you’ll use this on, you can use it reactively to try and save a pull from a wipe.

10. Recklessness . Causes almost all your attacks to be critical hits for 15s. While it also makes you immune to fear, it also causes you to take 20% more damage from everything. This can be used on pull along with the Bloodrage-Enrage interaction when you need to frontload a massive amount of threat right away. In most circumstances, I wouldn’t combine this with Death Wish. Must be in Berserker Stance to activate (try to keep your time in that stance as brief as possible).

### Talents

Because CC2 rearranged some talents in both the Fury and Protection trees, you’re spending all 51 talent points to take both Bloodthirst and Defiance. This is because Defiance was moved down one row, while Improved Taunt was moved up a row, so reaching that important talent stretches the points budget to the limits. There’s three showcased talent builds below. The first two are highly versatile and works well for both main-tanking and off-tanking, and can work well in dungeons. The third build really should only be used for off-tanking where you’ll spend the majority of your time DPS’ing. It can also be used outside of instances if for some godforsaken reason you don’t like changing talents all the time.

[Furyprot piercing howl & improved shouts 0/31/20](https://talents.turtlecraft.gg/warrior?points=-AoFYpAAoBAFAB-TAAoKQAo)

[Furyprot reckless execute 0/31/20](https://talents.turtlecraft.gg/warrior?points=-AoFAoAAoZBFAB-TAAoKQAo)

Improved Bloodrage is mandatory to take Last Stand. Toughness and Last Stand really are the best picks here, both talents really improve our odds of surviving. 5/5 Defiance is mandatory, and is a part of what makes Furyprot work. The points in the first three rows of prot really don't matter much, some may take anticipation while others don't since it lowers your enrage uptime, some might take improved revenge while others go improved taunt etc. Don't overthink it.

The Fury tree is where the majority of our talents points are spent. 5/5 Cruelty helps us with our threat generation in tank gear, especially while wearing full mitigation. Dual Wield Specialization was put into the second row, and is made incredibly powerful by giving 10% hit chance for the off hand. Both the third and fourth rows needs to have 7 to 9 points, and 5 to 7 points, respectively. That way we can still reach Bloodthirst. In both instances. Since we’re taking hits from mobs we are tanking, the overall uptime on Enrage goes way up compared to Fury DPS. Death Wish is needed to pick up Flurry, which is incredibly powerful for our threat generation. We can then get to our capstone: Bloodthirst.

## Defensive Tactics Prot (by Essee)

### Playstyle

This section is written by primarily a DPS player at end-game BIS Gear levels. It is more than viable across all current tiers of content from Dungeons to Naxxramas as both Maintank, and Offtank.

Content Changes 2 has brought into play changes to the Protection Tree which adds some variability to tanking. The key talent of this is Defensive Tactics allowing you to retain additional threat modifiers in stances other than Protection Stance, however Improved Shield Slam also adds a buff on Shield Slam to give you 75% block for 6 seconds.

For this, the mindset has to remain similar to that of traditional furyprot, in which we are aiming to hold the targets aggro by being as offensive as possible. Our off-hand sword is now gone, and instead we are ultimately using our Shield as on offensive weapon (which gives you additional armour also!), coupled with Shield Slam as a primary means of generating threat, in addition to Heroic Strike and of course…Sunder (EVERYONE SHOULD SUNDER!). Depending on the stance you tank in, your abilities will differ, which is a lot of the appeal of this spec compared to furyprot or deep prot.

ere are the pros/cons to each stance:

Defensive Stance:
- gains Revenge as part of your rotation. Revenge whilst very good threat per rage, does not have any scaling.
- gains access to taunt without swapping stance
- gains access to shield block for mitigation

Battle Stance (vs defensive stance):

- +10% Damage Taken
- +10% Damage Done 
-  gains Overpower as part of your rotation. Overpower is a powerhouse, due to the talented effect. At end-game gear levels it's very easy to attain 80%+ Critical Strike chance of Overpower in tank gear.

Berserker Stance (vs defensive stance):
- +20% Damage Taken
- +10% Damage Done
- +3% Critical Strike chance
- gains Whirlwind as a part of your priority abilities

Whilst Berserker Stance seems immediately the most appealing for threat, you are also asking a lot more of your healers. In addition, Whirlwind with a 1H weapon isn’t particularly appealing for single-target threat, but is a very good option for AoE when combined with Cleave and Berserker Rage. You could also consider this as a threat chasing stance in which you focus on Shield Slam, Heroic and Sunder to climb the threat table of the target.

**Defensive Stance rotation**:

1. Shield Slam

2. Concussion Blow

3. Revenge

4. Sunder Armor

5. Heroic Strike where rage allows

**Battle Stance rotation**:

1. Overpower

2. Shield Slam / Concussion Blow

3. Sunder Armor

4. Heroic Strike where rage allows

**Berserker Stance rotation**:

1. Shield Slam / Concussion Blow

2. Whirlwind

3. Sunder

4. Heroic Strike where rage allows

!!! info
For aoe, your rotation becomes whirlwind \-\> cleave \-\> other abilities.

### Talents 

There are a few choices to make with talents, but [this is the showcased spec](https://talents.turtlecraft.gg/warrior?points=dQAAQYAQAAAAAAAAAAAAAAAAAAAAUYAoIAAohQAYBAA=). 

The arms talents are taken for bigger crits from impale/improved overpower, as well as making heroic striker cheaper which is a consistent threat generator. In fury, your last 3 points go into cruelty, though some of these points can go into one-handed spec in prot instead. 

Most important are the prot talents. Only 4/5 shield block is taken, since in battle stance the difference in mitigation/rage generation is minimal, though these points are up to you. The points in anticipation are up to preference, you might want to put 3/3 in anticipation or you might want to go for the improved taunt/intervene talents. You kind of have to waste points in these upper talents to get to the juicy stuff at the bottom. Toughness and last stand are both no brainers, both massively help in keeping you alive.

Defiance is also (obviously) required, and gives us enough points to get row 5 for some of the most important talents. One-handed spec points are up for debate, you might go anywhere from 3/5 to 5/5. The choice is essentially between 2% weapon damage or 1% crit. Shield slam and improved shield slam are vital for our rotation, and improved shield slam helps us become avoidance capped. 

The standout talent in this build is **Defensive Tactics**, which makes the whole build work. It gives you a higher threat modifier in stances other than defensive stance, and lets you benefit from no longer having -10% damage done in defensive stance. Do note that this talent *only* works if you have a shield equipped. You don't get to dual wield as this spec.

## Raid optimizations

### Non raid-specific stuff 

- Positioning your character on trash (and bosses) is extremely important. You want to minimize the amount of time you get parried, and maximize the amount of time you can cleave nearby mobs. Sometimes you might need to move away briefly to avoid aoe dmg (think patchwork golem stacking in naxx or rain of fire in BWL) or position your character towards one side of a trash pull for safety. Sometimes parries are unavoidable, like standing on the tank on KT or thaddius, or if someone rips threat on trash. It is what it is. For the most part it's on your tanks to position mobs facing away from the raid, but sometimes that doesn't happen and you need to adjust.

- **Whirlwind**, along with all of your aoe abilities (mostly shouts, but also stuff like sapper) gains extra range when used while jumping, since your hitbox is extended slightly. This is used most notably on KT phase 1 to hit skeles, but it's good on all aoe trash for slightly extra range. 

- **Berserker Rage** is a very important ability that should not only be used to break fears. While active, it gives you a +60% rage bonus from damage taken. On fights where you take raidwide damage (think geddon trash/BWL techies/naxx spiders/sapphiron) it's well worth pressing, even if it uses a gcd. I would use this instead of pummel/sunder/hamstring, never clip your bloodthirst/whirlwind cd with it.

- **Disarm** can be used on many mobs as a way to prevent tanks from dying. Any mob with a weapon in their hand can be disarmed, massively reducing the damage intake. Typical uses for this are razuvious/four horsemen/deathknight captains in naxx, broodlord in BWL, and axe throwers in ZG.

- There are times when even as dps you should swap to a different stance to take less damage. Common examples of this are viscidus, sapphiron, and four horsemen when marks are about to go out. During progression you end up doing this a lot more, because fights tend to go long and healer mana becomes an issue.

- On some fights, it can fall to a dps to apply demo shout. If you're talented into improved shouts, do not be afraid to press it. The only fight where this can grief is twins, so just be aware to only press it when theres no bugs nearby the boss (you can jump maxrange to apply it if theres no bugs on one side of the boss). All warriors should be aware of the bugged demo/CoR interaction: **never apply demo shout BEFORE curse of recklessness is applied by a warlock**. The -AP debuff from demo shout is completely canceled out by the +AP buff from curse of reck, and leaves a bugged demo shout on the target until it falls off. Another warrior talented into improved shouts can fix this by overwriting your demo shout, which will update the demo shout to properly apply -AP again, but getting someone else to demo shout when it's already applied will require communication.

- Weapon swapping during combat is extremely clunky. This is because it causes gcd (though your mainhand can be swapped while gcd is active) and doesn't allow other abilities to be used at the same time. In addition, swapping any weapon will reset your swing timer. In particular, equipping/swapping an offhand is notably bad, and feels like it can take up to 5 seconds of spamming the button sometimes. The exception to this problem is shields, which can be swapped instantly in or out of combat with no penalty. 

***