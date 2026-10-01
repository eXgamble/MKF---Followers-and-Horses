# MKF - Followers and Horses

A small Skyrim Anniversary Edition mod built on
[Modifier Key Framework](https://www.nexusmods.com/skyrimspecialedition/mods/193566): quick
actions on your followers and your own horses, with Modifier Key Framework's key for the second one.

| Target | Activate | Hold the modifier key |
|---|---|---|
| A follower | `Talk +`: vanilla dialogue | `Inventory`: opens their inventory |
| A follower in combat | `Give Potion +`: your cheapest healing potion | `Give Restore Potion`: your cheapest magicka or stamina potion, whichever they need most |
| Your own horse | `Ride +`: vanilla riding | `Inventory`: opens its inventory |
| Your own horse in combat | `Ride +`: vanilla riding | `Command: Flee`: it stops fighting and flees; `Command: Fight` calls it back |

- The follower takes the potion and drinks it, with the drinking animation. A follower who doesn't
  need it keeps you the potion.
- Potions: food, poisons and blood potions (unless the follower is a vampire) are never given.
  *Give Restore Potion* picks magicka or stamina by the lower percentage, and gives the other type
  if you carry none of the first.
- Horses: only horses you own (bought or claimed), including modded mounts.
- *Command: Flee* makes the horse cowardly until you order *Command: Fight* or your fight ends; its
  own courage and aggression are then restored exactly. Don't uninstall the mod in the middle of a fight.
- The modifier key is Modifier Key Framework's: Left Shift, or Left Shoulder on a gamepad, by default.

## Requirements

- [SKSE64](https://skse.silverlock.org/)
- [Address Library for SKSE Plugins](https://www.nexusmods.com/skyrimspecialedition/mods/32444)
- [Modifier Key Framework](https://www.nexusmods.com/skyrimspecialedition/mods/193566)
- [powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)
- Optional: [FormList Manipulator](https://www.nexusmods.com/skyrimspecialedition/mods/74037)
  (CACO blood potions are recognised as vampire-only)

Works alongside [Death Timer - Immersive Bleedout](https://github.com/eXgamble/Death-Timer---Immersive-Bleedout):
a downed follower gets Death Timer's *Give Potion* / *Search*.

## Repository layout

```
mod/   the mod exactly as installed: plugin (ESL), scripts + source, rule file, translation, SEQ, FLM ini
```

The author's MO2 mod folder is a directory junction to `mod/`.
