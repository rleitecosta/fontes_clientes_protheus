#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA010MNU
INCLUSAO DE NOVAS ROTINAS
Apos a criacao do aRotina, para adicionar novas rotinas ao programa.
Para adicionar mais rotinas, adicionar mais subarrays ao array. No
advanced este numero e limitado.
Deve se retornar um array onde cada subarray e uma linha a ser
adicionada ao aRotina padrao.
@author  Carlos H. Fernandes
@since   21/01/2021
@version 1.0
@return  array, rotinas a serem adicionadas.
@see     http://tdn.totvs.com/pages/releaseview.action?pageId=6784251
/*/
//-------------------------------------------------------------------
procedure u_MTA010MNU() 

	local aRotNew	as array

	local nD		as numeric
	local nJ		as numeric

    if (type("aRotina")=="A")
    	aRotNew := u_MT010BRW()
    	nJ := len(aRotNew)
    	//Adiciona botao de integracao
    	for nD := 1 to nJ
    		if (aSCan(aRotina,{|e|Compare(e,aRotNew[nD])})==0)
    			aAdd(aRotina,aRotNew[nD])
    		endif
    	next nD
    endif

return