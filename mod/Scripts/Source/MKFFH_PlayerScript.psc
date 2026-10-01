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

; ==== Give Potion (a follower in combat) ====

Event OnGivePotion(String asEventName, String asRuleId, Float afIsAlternate, Form akTarget)
	Actor target = akTarget As Actor
	If target && !target.IsDead()
		GivePotion(target)
	EndIf
EndEvent

; The follower gets your cheapest healing potion and drinks it at once
Function GivePotion(Actor akTarget)
	If akTarget.GetActorValuePercentage("Health") >= 1.0
		Debug.Notification(akTarget.GetDisplayName() + " isn't hurt.")
		Return
	EndIf
	Actor player = Game.GetPlayer()
	Potion healthPotion = FindCheapestHealingPotion(player, akTarget)
	If healthPotion == None
		Debug.Notification("You have no healing potions to give.")
		Return
	EndIf
	player.RemoveItem(healthPotion, 1, True, akTarget)
	akTarget.EquipItem(healthPotion, False, True)
	Debug.Notification("You gave " + healthPotion.GetName() + " to " + akTarget.GetDisplayName() + ".")
EndFunction

; The cheapest (gold value) healing potion in akSource's inventory. Skips food and poisons, and
; potions with vampire-only healing (blood) unless the patient is a vampire.
Potion Function FindCheapestHealingPotion(Actor akSource, Actor akPatient)
	Keyword restoreHealth = Game.GetFormFromFile(0x42503, "Skyrim.esm") As Keyword	; MagicAlchRestoreHealth
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
			Bool heals = False
			Bool usable = True
			Int n = p.GetNumEffects()
			While n && usable
				n -= 1
				MagicEffect effect = p.GetNthEffectMagicEffect(n)
				If !patientIsVampire && vampireOnly.HasForm(effect)
					usable = False
				ElseIf effect.HasKeyword(restoreHealth)
					heals = True
				EndIf
			EndWhile
			If heals && usable
				cheapest = p
				cheapestValue = value
			EndIf
		EndIf
	EndWhile
	Return cheapest
EndFunction
