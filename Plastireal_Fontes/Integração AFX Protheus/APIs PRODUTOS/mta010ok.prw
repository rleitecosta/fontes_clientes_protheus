#include "totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MTA010OK
APÓS INCLUSaO DO CLIENTE
Este Ponto de Entrada e chamado para validar a Delecao de Produto
no Arquivo.
@author  CONNECTI
@since   22/09/2019
@version 1.0
@return  nil
/*/
//-------------------------------------------------------------------
function u_MTA010OK() as logical
	
    local lMTA010OK	as logical
	lMTA010OK := MTA010OK()

return(lMTA010OK)

static function MTA010OK() as logical

    local aArea			as array
    local aAreaSB1		as array

    local bMsgRun		as block

    local cTitle		as character
    local cMsgRun		as character

    local lMTA010OK		as logical
    local lAFXEnable	as logical

    aArea := getArea()
    aAreaSB1 := SB1->(getArea())
    lAFXEnable := getNewPar("API_INTPRD",.T.)

    if (lAFXEnable)
        cTitle  := "API PRODUTOS"
        cMsgRun := "Realizando a integracao com a API de Produtos..."
        bMsgRun := {||lMTA010OK := U_WSINTPRD(SB1->B1_COD,.F.)}
        MsgRun(cMsgRun,cTitle,bMsgRun)
    	if ((!lMTA010OK).and.!(SB1->B1_XAFXSTA=="E"))
	    	if SB1->(RecLock("SB1",.F.))
	    		SB1->B1_XAFXSTA := "N"
	    		SB1->(MsUnLock())
	    	endif
	    endif
    elseif SB1->(FieldPos("B1_XAFXSTA")>0)
    	if SB1->(RecLock("SB1",.F.))
    		SB1->B1_XAFXSTA := "N"
    		SB1->(MsUnLock())
    	endif
    endif

    restArea(aAreaSB1)
    restArea(aArea)

    DEFAULT lMTA010OK:=.T.

return(lMTA010OK)
