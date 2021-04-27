#include "rwmake.ch"  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³TOTPAG2   ºAutor  ³JN     º Data ³  21/11/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte para calculo do Valor Total Arrecadado do Tributo no º±±
±±º          ³ Trailer do Lote do Segmento "N". Posição (066 a 079)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TC				                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FSHINP06() 

Local _area   := GetArea()
Local _Soma   := SOMAVALOR()
local _Soma1  := 0
Local _Desc   := 0

_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
_Juros:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_XJURDAR")
_Multa:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_XMULDAR")
//_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")
_DESC := VAL(STR(_Desc*100))
_Soma1:= (((_Soma+(_Juros+_Multa)*100) - _Desc))  
//_Soma1:= ((_Soma+(_Juros+_Multa)*100)-(_Acres+_Desc))
_SOMA1:= STR(_SOMA1)
_SOMA1:= STRZERO(VAL(_SOMA1),14)
      
RestArea(_area)

Return(_Soma1) 
