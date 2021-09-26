local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[CLOWN.name] = "Clown"
L[CLOWN.defaultTeam] = "Team Clown"
L["hilite_win_" .. CLOWN.defaultTeam] = "KILLER CLOWN WON"
L["win_" .. CLOWN.defaultTeam] = "The Killer Clowns won! Mwahahaha"
L["info_popup_" .. CLOWN.name] = [[You are the clown, stay alive till the end and Kill them all!]]
L["ev_win_" .. CLOWN.defaultTeam] = "The evil Clowns won the round!"
L["body_found_" .. CLOWN.abbr] = "They were a clown "
L["search_role_" .. CLOWN.abbr] = "This person was a clown"
L["target_" .. CLOWN.name] = "Clown"
L["ttt2_desc_" .. CLOWN.name] = [[The clown is a Jester role that becomes a Killer clown if theyre alive when the round would normally end however they can also be killed without consequence before their transformation]]

-- Killer clown
L[KILLERCLOWN.name] = "Killer Clown"
L["info_popup_" .. KILLERCLOWN.name] = [[YOU'RE THE KILLER CLOWN - GO KILL THEM ALL!]]
L["search_role_" .. KILLERCLOWN.abbr] = "This person was a killer clown"
L["body_found_" .. KILLERCLOWN.abbr] = "They were a Killer clown"
L["target_" .. KILLERCLOWN.name] = "Killer Clown"
L["ttt2_desc_" .. KILLERCLOWN.name] = [[The killer clown is the transformed version of the clown that appears when a clown survives to the end of the round, they have one purpose once transformed and thats to kill everyone else.]]
