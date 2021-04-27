#include "totvs.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} M030INC
Este Ponto de Entrada e chamado apos a inclusao no cadastro de Clientes
@author  Carlos H. Fernandes
@since   03/02/2021
@version 1.0
@return  nil
/*/
//------------------------------------------------------------------------
function u_M030INC() as logical
	local lM030INC	as logical
	lM030INC := M030INC()
	return(lM030INC)

static function M030INC() as logical

    local aArea			as array
    local aAreaSA1		as array

    local bMsgRun		as block

    local cTitle		as character
    local cMsgRun		as character
    local cMsgYesNo		as character

    local lM030INC		as logical
    local lAFXEnable	as logical

    aArea      := getArea()
    aAreaSA1   := SA1->(getArea())
    lAFXEnable := getNewPar("API_INTCLI",.T.)

    if (lAFXEnable)
        cTitle  := "API CLIENTES"
        cMsgRun := "Realizando a integracao com a API de Clientes..."
        bMsgRun:={||lM030INC := U_WSINTCLI(SA1->A1_COD,SA1->A1_LOJA,.F.)}
        MsgRun(cMsgRun,cTitle,bMsgRun)
        if (!IsBlind())
            cMsgYesNo:="Deseja tentar nova integracao?"
            while !(lM030INC)
                lM030INC:=ApMsgNoYes(cMsgYesNo,cTitle)
                if !(lM030INC)
                    exit
                endif
                MsgRun(cMsgRun,cTitle,bMsgRun)
            end while
        endif
    	if ((!lM030INC).and.!(SA1->A1_XAFXSTA=="E"))
	    	if SA1->(RecLock("SA1",.F.))
	    		SA1->A1_XAFXSTA:="N"
	    		SA1->(MsUnLock())
	    	endif
        endif
        lM030INC:=.T.
    elseif SA1->(FieldPos("A1_XAFXSTA")>0)
    	if SA1->(RecLock("SA1",.F.))
    		SA1->A1_XAFXSTA:="N"
    		SA1->(MsUnLock())
    	endif
    endif

    restArea(aAreaSA1)
    restArea(aArea)

    DEFAULT lM030INC:=.T.

    return(lM030INC)
