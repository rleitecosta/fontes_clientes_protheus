#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT010INC
LOCALIZACAO : Function FAvalSB1 - Funcao de Gravacoes adicionais do
PRODUTO, apos sua inclusao.
EM QUE PONTO: Apos incluir o PRODUTO, deve ser utilizado para
gravar arquivos/campos do usuario, complementando a inclusao.
Ponto de Entrada para complementar a inclusao no cadastro do PRODUTO.
@author  Carlos H. Fernandes
@since   21/01/2021
@version 1.0
@return  nil
/*/
//-------------------------------------------------------------------
function u_MT010INC() as logical

	local lMT010INC	as logical
	lMT010INC := MT010INC()

return(lMT010INC)

static function MT010INC() as logical

    local aArea			as array
    local aAreaSB1		as array

    local bMsgRun		as block

    local cTitle		as character
    local cMsgRun		as character
    local cMsgYesNo		as character

    local lMT010INC		as logical
    local lAFXEnable	as logical

    aArea     := getArea()
    aAreaSB1  := SB1->(getArea())
    lAPIEnable:= getNewPar("API_INTPRD",.T.)

    //----------------------------------------------------
    //Chamada do ponto de entrada de inclusao do PRODUTO
    //para realizar a integracao.
    //----------------------------------------------------
    if (lAFXEnable)
        cTitle  := "API PRODUTOS"
        cMsgRun := "Realizando a integracao com a API de Produtos..."
        bMsgRun := {||lMT010INC := U_WSINTPRD(SB1->B1_COD,.F.)}
        MsgRun(cMsgRun,cTitle,bMsgRun)
        if (!IsBlind())
            cMsgYesNo := "Deseja tentar nova integracao?"
            while !(lMT010INC)
                lMT010INC := ApMsgNoYes(cMsgYesNo,cTitle)
                if !(lMT010INC)
                    exit
                endif
                MsgRun(cMsgRun,cTitle,bMsgRun)
            end while
        endif
    	if ((!lMT010INC).and.!(SB1->B1_XAFXSTA=="E"))
	    	if SB1->(RecLock("SB1",.F.))
	    		SB1->B1_XAFXSTA := "N"
	    		SB1->(MsUnLock())
	    	endif
        endif
        lMT010INC := .T.
    elseif SB1->(FieldPos("B1_XAFXSTA")>0)
    	if SB1->(RecLock("SB1",.F.))
    		SB1->B1_XAFXSTA := "N"
    		SB1->(MsUnLock())
    	endif
    endif

    restArea(aAreaSB1)
    restArea(aArea)

return(lMT010INC)
