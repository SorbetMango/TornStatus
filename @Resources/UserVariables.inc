[Variables]
; ============================================================
;  TornStatus — User Variables (UserVariables.inc)
;  Ten plik zawiera wylacznie ustawienia konfigurowane przez uzytkownika.
;  Jest chroniony przed nadpisaniem podczas aktualizacji pakietu .rmskin.
; ============================================================

; Klucz Torn API (wymagane uprawnienia: Public/Minimal)
APIKey=

; Przezroczystosc tla (0 = calkowicie przezroczyste, 255 = pelny kolor)
BgAlpha=0

; Kolory tla i tekstu (konfigurowane dynamicznie z poziomu okna Settings)
BgColor=9,10,12,#BgAlpha#
SurfaceCard=19,20,24,#BgAlpha#
SurfaceElevated=24,26,31,#BgAlpha#
SurfaceBorder=255,255,255,(#BgAlpha#*20/255)
Hairline=255,255,255,(#BgAlpha#*10/255)
TextWhite=240,245,255,255
TextDim=100,116,139,255
TextMuted=71,85,105,255
