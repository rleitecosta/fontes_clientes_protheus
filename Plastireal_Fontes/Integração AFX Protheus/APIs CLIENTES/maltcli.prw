#include "totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MALTCLI
APÓS ALTERAcaO DO CLIENTE
Este Ponto de Entrada e chamado após a alteracao dos dados do cliente
no Arquivo.
@author  CONNECTI
@since   11/04/2019
@version 1.0
@return  nil
/*/
//-------------------------------------------------------------------
function u_MALTCLI() as logical
	local lMALTCLI	as logical
    if (IsInCallStack("A030Altera"))
    	if !(type("lA1ItAfx")=="L")
    		_setNamedPrvt("lA1ItAfx",.F.,"A030Altera")
    	endif
    endif
	lMALTCLI:=MALTCLI()
	return(lMALTCLI)

static function MALTCLI() as logical

    local aArea			as array
    local aAreaSA1		as array

    local bMsgRun		as block

    local cTitle		as character
    local cMsgRun		as character
    local cMsgYesNo		as character

    local lAfxA1It		as logical
    local lMALTCLI		as logical
    local lAFXEnable	as logical

    aArea:=getArea()
    aAreaSA1:=SA1->(getArea())
    lAfxA1It:=if((type("lA1ItAfx")=="L"),(!&("lA1ItAfx")),.T.)
    lAFXEnable := getNewPar("API_INTCLI",.T.)
    lAFXEnable:=(lAFXEnable.and.lAfxA1It)

    //----------------------------------------------------
    //Chamada do ponto de entrada de inclusao do cliente
    //para realizar a integracao AFX.
    //----------------------------------------------------
    if (lAFXEnable)
    	cTitle  := "API CLIENTES"
        cMsgRun := "Realizando a integracao com a API de Clientes..."
        bMsgRun:={||lMALTCLI:=U_WSINTCLI(SA1->A1_COD,SA1->A1_LOJA,.F.)}
        MsgRun(cMsgRun,cTitle,bMsgRun)
        if (!IsBlind())
            cMsgYesNo:="Deseja tentar nova integracao?"
            while !(lMALTCLI)
                lMALTCLI:=ApMsgNoYes(cMsgYesNo,cTitle)
                if !(lMALTCLI)
                    exit
                endif
                MsgRun(cMsgRun,cTitle,bMsgRun)
            end while
        endif
    	if ((!lMALTCLI).and.!(SA1->A1_XAFXSTA=="E"))
    		if SA1->(RecLock("SA1",.F.))
    			SA1->A1_XAFXSTA:="N"
    			SA1->(MsUnLock())
    		endif
    	endif
        lMALTCLI:=.T.
	    if (IsInCallStack("A030Altera"))
	    	_setNamedPrvt("lA1ItAfx",.T.,"A030Altera")
	    endif
    elseif ((lAfxA1It).and.SA1->(FieldPos("A1_XAFXSTA")>0))
    	if SA1->(RecLock("SA1",.F.))
    		SA1->A1_XAFXSTA:="N"
    		SA1->(MsUnLock())
    	endif
    endif

    restArea(aAreaSA1)
    restArea(aArea)

    DEFAULT lMALTCLI:=.T.

    return(lMALTCLI)