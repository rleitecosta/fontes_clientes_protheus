#Include 'Protheus.ch'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT410BRW()
Rotina utilizada para colocar botão na rotina pedido de vendas. 
@author    Cláudio Macedo
@version   1.0
@since     12/10/2017
/*/
//------------------------------------------------------------------------------------------

User Function MT410BRW()

	AADD(aRotina,{"Imprimir Pedido.","U_RFAT0001(SC5->C5_NUM)",0,3})
	AADD(aRotina,{"Imprimir Ped.Int","U_RFAT0002(SC5->C5_NUM)",0,3})	

Return
