#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} M030DEL
Este Ponto de Entrada e chamado para validar a Delecao de Clientes
@author  Carlos H. Fernandes
@since   03/02/2021
@version 1.0
@return  nil
/*/
//-------------------------------------------------------------------
function u_M030DEL() as logical
	local lM030DEL	as logical
	lM030DEL := M030DEL()
	return(lM030DEL)

static function M030DEL() as logical

    local aArea			as array
    local aAreaSA1		as array

    local bMsgRun		as block

    local cTitle		as character
    local cMsgRun		as character

    local lM030DEL		as logical
    local lAFXEnable	as logical

    aArea      := getArea()
    aAreaSA1   := SA1->(getArea())
    lAFXEnable := getNewPar("API_INTCLI",.T.)

    if (lAFXEnable)
        cTitle  := "API CLIENTES"
        cMsgRun := "Realizando a integracao com a API de Clientes..."
        bMsgRun:={||lM030DEL:=U_WSINTCLI(SA1->A1_COD,SA1->A1_LOJA,.F.)}
        MsgRun(cMsgRun,cTitle,bMsgRun)
    endif

    restArea(aAreaSA1)
    restArea(aArea)

    DEFAULT lM030DEL:=.T.

    return(lM030DEL)