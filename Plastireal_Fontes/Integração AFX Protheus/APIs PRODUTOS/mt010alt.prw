#include "totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} MT010ALT
APOS ALTERACAO DO PRODUTO
Este Ponto de Entrada e chamado apos a alteracao dos dados do PRODUTO
no Arquivo.
@author  Carlos H. Fernandes
@since   21/01/2021
@version 1.0
@return  nil
/*/
//-------------------------------------------------------------------
function u_MT010ALT() as logical
	local lMT010ALT	as logical
	begin sequence
		if (type("_lMT010ALT")=="L")
			lMT010ALT := &("_lMT010ALT")
			if (lMT010ALT)
				&("_lMT010ALT") := .F.
				break
			endif
		endif
		lMT010ALT := MT010ALT()
	end sequence
	DEFAULT lMT010ALT := .T.
return(lMT010ALT)

//****************************************
// P.E Utilizado na alteração do Produto
//****************************************
Static function MT010ALT()

    local aArea			as array
    local aAreaSB1		as array

    local bMsgRun		as block

    local cTitle		as character
    local cMsgRun		as character
    local cMsgYesNo		as character

    local lMT010ALT		as logical
    local lAPIEnable	as logical
    local aDadosSB5     as array

    aArea       := getArea()
    aAreaSB1    := SB1->(getArea())
    lAPIEnable  := getNewPar("API_INTPRD",.T.)

    //----------------------------------------------------
    //Chamada do ponto de entrada de inclusao do PRODUTO
    //para realizar a integracao.
    //----------------------------------------------------
    if (lAPIEnable)
        nOpc      := 4 //Alteração
        cTitle    := "API PRODUTOS"
        cMsgRun   := "Realizando a integracao com a API de Produtos..."
        aDadosSB5 := {{M->B5_LARG,M->B5_COMPR,M->B5_ESPESS,M->B5_XCOR,M->B5_DIAINT,M->B5_DIAEXT}}
        bMsgRun := {||lMT010ALT := U_WSINTPRD(SB1->B1_COD,.F.,aDadosSB5)}
        MsgRun(cMsgRun,cTitle,bMsgRun)
        if (!IsBlind())
        	cMsgYesNo := "Deseja tentar nova integracao?"
            while !(lMT010ALT)
                lMT010ALT := ApMsgNoYes(cMsgYesNo,cTitle)
                if !(lMT010ALT)
                    exit
                endif
                MsgRun(cMsgRun,cTitle,bMsgRun)
            end while
        endif
    	if ((!lMT010ALT).and.!(SB1->B1_XAFXSTA=="E"))
	    	if SB1->(RecLock("SB1",.F.))
	    		SB1->B1_XAFXSTA := "N"
	    		SB1->(MsUnLock())
	    	endif
        endif
        lMT010ALT := .T.
        if (IsInCallStack("A010ALTERA"))
        	_SetNamedPrvt("_lMT010ALT",lMT010ALT,"A010ALTERA")
        endif
    elseif SB1->(FieldPos("B1_XAFXSTA")>0)
    	if SB1->(RecLock("SB1",.F.))
    		SB1->B1_XAFXSTA := "N"
    		SB1->(MsUnLock())
    	endif
    endif

    restArea(aAreaSB1)
    restArea(aArea)

    DEFAULT lMT010ALT := .T.

return(lMT010ALT)
