#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} xvalstes
@description Retorna tes sugerida no cadastro de cliente. 
@type function

@author Leandro Procopio	
@since 29 04 2019
@version 1.0
/*/
user function xvalstes()

Local _nItem
Local cCLi  := M->C5_CLIENTE
Local cTes  := Posicione("SA1",1,xFilial("SA1") + cCLi,"A1_TESSNAC")
Local cSnac := Posicione("SA1",1,xFilial("SA1") + cCLi,"A1_SIMPNAC")

If cSnac == "1" .AND. cTes <> ''
	cTes := cTes
Else
	cTes := ''

Endif 

/*
//nPosTes := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_TES"})
For _nItem := 1 to Len(aCols)                    
    If ! aCols[_nItem,Len(aHeader)+1]
		
		If cSnac == "1" .AND. cTes <> ''
			M->C6_TES := cTes
		Endif  
 
     EndIf
Next
GetDRefresh()
*/ 
 
return cTes