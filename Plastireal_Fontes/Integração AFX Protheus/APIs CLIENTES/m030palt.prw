#include "totvs.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} M030PALT
Este Ponto de Entrada e chamado apos a alteracao no cadastro de Clientes
@author  Carlos H. Fernandes
@since   03/02/2021
@version 1.0
@return  nil
/*/
//------------------------------------------------------------------------
function u_M030PALT() as logical
	local lM030PALT	as logical
    if (IsInCallStack("A030Altera"))
    	if !(type("lA1ItAfx")=="L")
    		_setNamedPrvt("lA1ItAfx",.F.,"A030Altera")
    	endif
    endif
	lM030PALT:=M030PALT()
	DEFAULT lM030PALT:=.T.
return(lM030PALT)

static function M030PALT() as logical
    local lM030PALT		as logical
    lM030PALT:=u_MALTCLI()
return(lM030PALT)