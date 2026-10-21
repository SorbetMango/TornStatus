; ============================================================
;  TornStatus — Modul Aktualizacji (Updater.inc)
;  Sprawdza zdalna wersje skina i porownuje z #SkinVersion#.
; ============================================================

[Variables]
NewVersionAvailable=0
RemoteVersion=
UpdateDivider=14400

[MeasureCheckUpdate]
Measure=Plugin
Plugin=WebParser
Url=#UpdateURL#
RegExp=(?siU)^(.*)$
StringIndex=1
UpdateRate=#UpdateDivider#
FinishAction=[!EnableMeasure MeasureCompareVersion][!UpdateMeasure MeasureCompareVersion]

[MeasureCompareVersion]
Measure=String
String=[MeasureCheckUpdate]
DynamicVariables=1
Disabled=1
IfMatch=^#SkinVersion#$|^$|404: Not Found|400|Error
IfMatchAction=[!SetVariable NewVersionAvailable "0"]
IfNotMatchAction=[!SetVariable NewVersionAvailable "1"][!SetVariable RemoteVersion "[MeasureCheckUpdate]"][!Log "TornStatus: Wykryto nowa wersje skina: [MeasureCheckUpdate] (zainstalowana: #SkinVersion#)"]
