#INCLUDE "totvs.ch"

USER FUNCTION INIBRWSF1()
Local _Cfornome
_Cfornome:=IIF(SF1->F1_TIPO$'BD',Posicione("SA1",1, xFilial("SA1")+SF1->(F1_FORNECE + F1_LOJA), "A1_NOME"),Posicione("SA2",1, xFilial("SA2") + SF1->(F1_FORNECE + F1_LOJA), "A2_NOME"))
Return(_Cfornome)
