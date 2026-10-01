ScriptName MKFFH_PlayerScript Extends ReferenceAlias
{MKF - Followers and Horses: opens a follower's or your horse's inventory when the Modifier Key
Framework rule (SKSE/Plugins/ModifierKeyFramework/MKF - Followers and Horses.json) fires.}

Event OnInit()
	RegisterForEvents()
EndEvent

; Mod event registrations are not saved: register again on every load
Event OnPlayerLoadGame()
	RegisterForEvents()
EndEvent

Function RegisterForEvents()
	RegisterForModEvent("MKFFH_OpenInventory", "OnOpenInventory")
EndFunction

Event OnOpenInventory(String asEventName, String asRuleId, Float afIsAlternate, Form akTarget)
	Actor target = akTarget As Actor
	If target && !target.IsDead()
		target.OpenInventory(True)
	EndIf
EndEvent
