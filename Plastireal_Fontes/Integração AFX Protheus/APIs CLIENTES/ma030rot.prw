#include "totvs.ch"
#include "fwmvcdef.ch"

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MA030ROT
Utilizado para adicionar novas opcoes ao Menu aRotina no Cadastro de Clientes
@author  Carlos H. Fernandes
@since   03/02/2021
@version 1.0
@return  nil
/*/
//-----------------------------------------------------------------------------
function u_MA030ROT() as array

    local aRotina		as array

    local lAFXEnable	as logical

    aRotina:=array(0)
	lAFXEnable := getNewPar("API_INTCLI",.T.)

	if (lAFXEnable)
	    //Adiciona botao de integracao AFX
	    ADD OPTION aRotina TITLE "Integ. Lote" ACTION "U_WSINTCLI('','',.T.)" 	OPERATION MODEL_OPERATION_VIEW ACCESS 0
	endif

    return(aRotina)