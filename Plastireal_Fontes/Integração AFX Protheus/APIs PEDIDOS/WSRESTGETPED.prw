#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTGETPED    Ultima Alteração: Rodrigo Leite     Data: 05/04/2021  
//Descrição: API Pedido de venda - envia dados para o techprod se a nota existe
//Uso: Plastireal
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSRESTFUL WSRESTGETPED DESCRIPTION "WEBSETRVICE REST - PEDIDOS"

	//WSDATA CCODNUM  As String
	WSDATA cPedido  AS CHARACTER

	//WSMETHOD POST   DESCRIPTION "Inclusão de Pedidos" WSSYNTAX "/"																		//WSSYNTAX "/WSRESTEFFPED/POST"																	
	 WSMETHOD GET GetPedidoNF;
        DESCRIPTION 'Retorna se o Pedido de Vendas foi Processado';
        WSSYNTAX '/GetPedidoNF';
        PATH 'GetPedidoNF';
        PRODUCES APPLICATION_JSON
	//WSMETHOD PUT    DESCRIPTION "Alteração de Pedidos" WSSYNTAX "/"																		//WSSYNTAX "/WSRESTEFFPED/PUT"																		
	//WSMETHOD DELETE DESCRIPTION "Exclusão de Pedidos" WSSYNTAX "/{Empresa_Obrigatorio}/{Filial_Obrigatorio}/{CNPJ_Opcional}"			//WSSYNTAX "/WSRESTEFFPED/DELETE"

END WSRESTFUL    

WSMETHOD GET GetPedidoNF WSRECEIVE cPedido WSREST WSRESTGETPED
	
	Local cRet
	local aParam  := ::aURLParms
	Local cNumPed := Self:cPedido
	Local lRes := .T.
	Local oJSON

	//Prepara Ambiente
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01","0101") 


	::SetContentType("application/json") 

	if len(aParam) < 1
		//::SetResponse('{"Status":"400","Mensagem":""}')
		lRes := .F.
		SetRestFault(400,EncodeUTF8("Inserir os parâmetros: Pedido de Vendas", "cp1252"))
		Return lRes
	endif

	    cRet := GetPedEnvNF(cNumPed)
		oJSON := JsonObject():New()
		oJSON:FromJson(cRet)

		cRet := EncodeUTF8(cRet, "cp1252")
		
		if !empty(cRet)
			::SetResponse(cRet)
		else
			lRes := .F.
			SetRestFault(400,EncodeUTF8("Pedido não encontrado. Pedido: "+cNumPed, "cp1252"))
		endif
	
Return(lRes)  


//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTGETPED    Ultima Alteração: Rodrigo Leite     Data: 05/04/2021  
//Descrição: API Pedido de venda - Valida o Pedido de vendas.
//Uso: Plastireal
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Static Function GetPedEnvNF(cNumPed)

Local cRet := ""


dbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+PADR(ALLTRIM(cNumPed),6))

If !Empty(SC5->C5_NOTA)
	cRet := U_WSRESTNF(SC5->C5_NOTA,"001",.F.,.T.)
Else
	cRet := '{"Status":"ERRO","Mensagem":"Pedido Não possui Nota Fiscal" }'
Endif

Return cRet
