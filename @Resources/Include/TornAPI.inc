[Variables]
; ============================================================
;  TornStatus — Torn API & State Logic (TornAPI.inc)
;  Wspolne miary WebParser, skrypt Lua oraz zarzadzanie stanem API.
; ============================================================

StatusTitleText=Okay // TORN CITY
StatusTitleTextSmall=Okay // TORN CITY
StatusRightText=
StatusTitleColor=#TextDim#
StatusTitleWeight=400
StatusFontSize=9
StatusY=26
TravelColor=#ColorHappy#
BlinkTravel=0
HideTravel=1
HideTravelIcon=1
BarBaseColor=#ColorHappy#
HideNormal=0
TravelPct=0
TravelIsReturning=0
SyncAgoText=0s
SyncIconColor=#TextMuted#
SyncTooltip=Click to force sync API
CashOnHand=0
RwText=
RwEnemyScore=
RwVsText=
RwOurScore=
EnergyStatusColor=180,180,180,100
NerveStatusColor=180,180,180,100
DrugStatusColor=180,180,180,100
MedStatusColor=180,180,180,100
BoostStatusColor=180,180,180,100
EventsCircleColor=100,116,139,90
EventsExclColor=180,180,180,180
EventsCountText=
EventsCountColor=150,180,62,255
EventsTooltip=Events: None
MessagesCountText=
MessagesColor=180,180,180,100
MessagesTooltip=Messages: None
EnergyTooltip=
NerveTooltip=
DrugTooltip=
MedTooltip=
BoostTooltip=
DrugLink=https://www.torn.com/item.php

; ============================================================
;  MEASURES
; ============================================================

[MeasureTornAPI]
Measure=Plugin
Plugin=WebParser
Url=https://api.torn.com/user/?selections=bars,travel,cooldowns,profile,money,notifications&key=#APIKey#
RegExp=(?siU)^(.*)$
UpdateRate=60
DynamicVariables=1

[MeasureFactionAPI]
Measure=Plugin
Plugin=WebParser
Url=https://api.torn.com/faction/?selections=basic&key=#APIKey#
RegExp=(?siU)^(.*)$
UpdateRate=120
DynamicVariables=1

[MeasureTornAPI_Child]
Measure=Plugin
Plugin=WebParser
Url=[MeasureTornAPI]
StringIndex=1
DynamicVariables=1

[MeasureFactionAPI_Child]
Measure=Plugin
Plugin=WebParser
Url=[MeasureFactionAPI]
StringIndex=1
DynamicVariables=1

[MeasureLuaParser]
Measure=Script
ScriptFile=#@#Lua\TornParser.lua
DynamicVariables=1

[MeasureBlink]
Measure=Calc
Formula=(MeasureBlink % 2) + 1
IfCondition=(#BlinkTravel# = 1) && (MeasureBlink = 1)
IfTrueAction=[!SetVariable TravelColor "255,255,255,255"][!UpdateMeter MeterTravelBarFill][!UpdateMeter MeterTravelIcon][!Redraw]
IfCondition2=(#BlinkTravel# = 1) && (MeasureBlink = 2)
IfTrueAction2=[!SetVariable TravelColor "#BarBaseColor#"][!UpdateMeter MeterTravelBarFill][!UpdateMeter MeterTravelIcon][!Redraw]
IfCondition3=(#BlinkTravel# = 0)
IfTrueAction3=[!SetVariable TravelColor "#BarBaseColor#"][!UpdateMeter MeterTravelBarFill][!UpdateMeter MeterTravelIcon][!Redraw]
DynamicVariables=1
