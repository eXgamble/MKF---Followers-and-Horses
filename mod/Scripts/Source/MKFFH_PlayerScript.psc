ScriptName MKFFH_PlayerScript Extends ReferenceAlias
{MKF - Followers and Horses: the actions behind the Modifier Key Framework rules in
SKSE/Plugins/ModifierKeyFramework/MKF - Followers and Horses.json.}

Event OnInit()
	RegisterForEvents()
EndEvent

; Mod event registrations are not saved: register again on every load
Event OnPlayerLoadGame()
	RegisterForEvents()
	If AnyHorseFleeing()
		RegisterForSingleUpdate(2.0)	; a save made mid-flee: restore the horse once the fight is over
	EndIf
EndEvent

Function RegisterForEvents()
	RegisterForModEvent("MKFFH_OpenInventory", "OnOpenInventory")
	RegisterForModEvent("MKFFH_GivePotion", "OnGivePotion")
	RegisterForModEvent("MKFFH_HorseCommand", "OnHorseCommand")
EndFunction

; ==== Inventory (followers and your horses, modifier key held) ====

Event OnOpenInventory(String asEventName, String asRuleId, Float afIsAlternate, Form akTarget)
	Actor target = akTarget As Actor
	If target && !target.IsDead()
		target.OpenInventory(True)
	EndIf
EndEvent

; ==== Command: Flee / Command: Fight (your horse in combat, modifier key held) ====

; A fleeing horse is Cowardly (Confidence 0) and Unaggressive (Aggression 0) until you order Fight
; or your combat ends. Its own values are kept here (saved with the game) and put back exactly.
Actor[] fleeingHorses
Float[] savedConfidence
Float[] savedAggression

Event OnHorseCommand(String asEventName, String asRuleId, Float afIsAlternate, Form akTarget)
	Actor horse = akTarget As Actor
	If !horse || horse.IsDead()
		Return
	EndIf
	Int slot = FindFleeingHorse(horse)
	If slot >= 0
		StopFleeing(slot)
		Debug.Notification(horse.GetDisplayName() + " is ready to fight.")
	Else
		StartFleeing(horse)
	EndIf
EndEvent

Function StartFleeing(Actor akHorse)
	If !fleeingHorses
		fleeingHorses = New Actor[5]
		savedConfidence = New Float[5]
		savedAggression = New Float[5]
	EndIf
	Int slot = FindFleeingHorse(None)
	If slot < 0
		Debug.Notification("Too many horses are already fleeing.")
		Return
	EndIf
	fleeingHorses[slot] = akHorse
	savedConfidence[slot] = akHorse.GetBaseActorValue("Confidence")
	savedAggression[slot] = akHorse.GetBaseActorValue("Aggression")
	akHorse.SetActorValue("Confidence", 0.0)
	akHorse.SetActorValue("Aggression", 0.0)
	akHorse.AddToFaction(FleeingFaction())
	akHorse.EvaluatePackage()
	Debug.Notification(akHorse.GetDisplayName() + " flees.")
	RegisterForSingleUpdate(2.0)
EndFunction

; Back to the horse's own values
Function StopFleeing(Int aiSlot)
	Actor horse = fleeingHorses[aiSlot]
	fleeingHorses[aiSlot] = None
	If horse
		horse.SetActorValue("Confidence", savedConfidence[aiSlot])
		horse.SetActorValue("Aggression", savedAggression[aiSlot])
		horse.RemoveFromFaction(FleeingFaction())
		horse.EvaluatePackage()
	EndIf
EndFunction

; Fleeing lasts while you're in combat
Event OnUpdate()
	If !Game.GetPlayer().IsInCombat()
		Int i = 0
		While fleeingHorses && i < fleeingHorses.Length
			If fleeingHorses[i]
				StopFleeing(i)
			EndIf
			i += 1
		EndWhile
	ElseIf AnyHorseFleeing()
		RegisterForSingleUpdate(2.0)
	EndIf
EndEvent

; The slot holding akHorse, or (akHorse None) a free slot; -1 if there is none
Int Function FindFleeingHorse(Actor akHorse)
	If !fleeingHorses
		Return -1
	EndIf
	Return fleeingHorses.Find(akHorse)
EndFunction

Bool Function AnyHorseFleeing()
	Int i = 0
	While fleeingHorses && i < fleeingHorses.Length
		If fleeingHorses[i]
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

Faction Function FleeingFaction()
	Return Game.GetFormFromFile(0x802, "MKF - Followers and Horses.esp") As Faction	; MKFFH_FleeingFaction
EndFunction

; ==== Give Potion / Give Restore Potion (a follower in combat) ====

; Primary: a healing potion. Alternate (modifier key): magicka or stamina, whichever they need most.
Event OnGivePotion(String asEventName, String asRuleId, Float afIsAlternate, Form akTarget)
	Actor target = akTarget As Actor
	If !target || target.IsDead()
		Return
	EndIf
	If afIsAlternate
		GiveRestorePotion(target)
	Else
		GiveHealingPotion(target)
	EndIf
EndEvent

Function GiveHealingPotion(Actor akTarget)
	If akTarget.GetActorValuePercentage("Health") >= 1.0
		Debug.Notification(akTarget.GetDisplayName() + " isn't hurt.")
		Return
	EndIf
	Potion p = FindCheapestPotion(Game.GetPlayer(), akTarget, Game.GetFormFromFile(0x42503, "Skyrim.esm") As Keyword)	; MagicAlchRestoreHealth
	If p == None
		Debug.Notification("You have no healing potions to give.")
		Return
	EndIf
	GivePotion(akTarget, p)
EndFunction

; Magicka or stamina, by the lower percentage; if you carry none of that type, the other one
; (when they're missing any of it)
Function GiveRestorePotion(Actor akTarget)
	Float magicka = akTarget.GetActorValuePercentage("Magicka")
	Float stamina = akTarget.GetActorValuePercentage("Stamina")
	If magicka >= 1.0 && stamina >= 1.0
		Debug.Notification(akTarget.GetDisplayName() + " doesn't need a restore potion.")
		Return
	EndIf
	Keyword restoreMagicka = Game.GetFormFromFile(0x42508, "Skyrim.esm") As Keyword	; MagicAlchRestoreMagicka
	Keyword restoreStamina = Game.GetFormFromFile(0x42504, "Skyrim.esm") As Keyword	; MagicAlchRestoreStamina
	Keyword first = restoreStamina
	Keyword second = restoreMagicka
	Float secondValue = magicka
	If magicka < stamina
		first = restoreMagicka
		second = restoreStamina
		secondValue = stamina
	EndIf

	Actor player = Game.GetPlayer()
	Potion p = FindCheapestPotion(player, akTarget, first)
	If p == None && secondValue < 1.0
		p = FindCheapestPotion(player, akTarget, second)
	EndIf
	If p == None
		Debug.Notification("You have no magicka or stamina potions to give.")
		Return
	EndIf
	GivePotion(akTarget, p)
EndFunction

; The follower gets the potion and drinks it at once (with the drinking animation)
Function GivePotion(Actor akTarget, Potion akPotion)
	Game.GetPlayer().RemoveItem(akPotion, 1, True, akTarget)
	akTarget.EquipItem(akPotion, False, True)
	Debug.Notification("You gave " + akPotion.GetName() + " to " + akTarget.GetDisplayName() + ".")
EndFunction

; The cheapest (gold value) potion in akSource's inventory with an effect carrying akEffectKeyword.
; Skips food and poisons, and potions with vampire-only effects (blood) unless the patient is a vampire.
Potion Function FindCheapestPotion(Actor akSource, Actor akPatient, Keyword akEffectKeyword)
	Keyword vampire = Game.GetFormFromFile(0xA82BB, "Skyrim.esm") As Keyword		; Vampire
	FormList vampireOnly = Game.GetFormFromFile(0x801, "MKF - Followers and Horses.esp") As FormList
	Bool patientIsVampire = akPatient.HasKeyword(vampire)

	Potion cheapest = None
	Int cheapestValue = 0
	Form[] items = PO3_SKSEFunctions.AddItemsOfTypeToArray(akSource, 46)	; 46 = potions, poisons, food
	Int i = items.Length
	While i
		i -= 1
		Potion p = items[i] As Potion
		Int value = p.GetGoldValue()
		; only look at the effects of a potion that would beat the current pick
		If (cheapest == None || value < cheapestValue) && !p.IsFood() && !p.IsPoison()
			Bool restores = False
			Bool usable = True
			Int n = p.GetNumEffects()
			While n && usable
				n -= 1
				MagicEffect effect = p.GetNthEffectMagicEffect(n)
				If !patientIsVampire && vampireOnly.HasForm(effect)
					usable = False
				ElseIf effect.HasKeyword(akEffectKeyword)
					restores = True
				EndIf
			EndWhile
			If restores && usable
				cheapest = p
				cheapestValue = value
			EndIf
		EndIf
	EndWhile
	Return cheapest
EndFunction
