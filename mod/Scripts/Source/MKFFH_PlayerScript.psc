ScriptName MKFFH_PlayerScript Extends ReferenceAlias
{MKF - Followers and Horses: the actions behind the Modifier Key Framework rules in
SKSE/Plugins/ModifierKeyFramework/MKF - Followers and Horses.json.}

Event OnInit()
	RegisterForEvents()
EndEvent

; Mod event registrations are not saved: register again on every load
Event OnPlayerLoadGame()
	RegisterForEvents()
EndEvent

Function RegisterForEvents()
	RegisterForModEvent("MKFFH_OpenInventory", "OnOpenInventory")
	RegisterForModEvent("MKFFH_GivePotion", "OnGivePotion")
EndFunction

; ==== Inventory (followers and your horses, modifier key held) ====

Event OnOpenInventory(String asEventName, String asRuleId, Float afIsAlternate, Form akTarget)
	Actor target = akTarget As Actor
	If target && !target.IsDead()
		target.OpenInventory(True)
	EndIf
EndEvent

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
