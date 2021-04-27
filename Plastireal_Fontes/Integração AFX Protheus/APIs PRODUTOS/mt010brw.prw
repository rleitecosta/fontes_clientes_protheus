#include "totvs.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA010MNU
Responsavel por inserir novas opcoes no menu do Cadastro de Produtos
(MATA010) atraves da variavel do tipo array aRotina.
Na abertura da tela de browser da rotina de Cadastro de Produtos(MATA010)
@author  Carlos H. Fernandes
@since   21/01/2021
@version 1.0
@return  array, rotinas a serem adicionadas.
/*/
//-------------------------------------------------------------------
function u_MT010BRW()   as array
    local aRotina	    as array
    local lAFXEnable    as logical
    aRotina := array(0)
    lAPIEnable := getNewPar("API_INTPRD",.T.)
	if (lAFXEnable)
	    ADD OPTION aRotina TITLE "Integ. Lote" ACTION "U_WSINTPRD('',.T.)" OPERATION MODEL_OPERATION_VIEW ACCESS 0
    endif
return(aRotina)
