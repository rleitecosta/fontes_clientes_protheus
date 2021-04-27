#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTEFFPED    Ultima Altera��o: Ricardo G. de Aguiar      Data: 13/02/2020  
//Descri��o: API Pedido de venda - Liga��o entre o Rest e o ExecAuto 
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSRESTFUL WSRESTEFFPED DESCRIPTION "WEBSETRVICE REST - PEDIDOS"

	//WSDATA CCODNUM  As String

	WSMETHOD POST   DESCRIPTION "Inclus�o de Pedidos" WSSYNTAX "/"																		//WSSYNTAX "/WSRESTEFFPED/POST"																	
	WSMETHOD GET    DESCRIPTION "Retorna Lista de Pedidos" WSSYNTAX "/{Empresa_Obrigatorio}/{Filial_Obrigatorio}/{CNPJ_Opcional}"		//"/WSRESTEFFPED/GET"
	WSMETHOD PUT    DESCRIPTION "Altera��o de Pedidos" WSSYNTAX "/"																		//WSSYNTAX "/WSRESTEFFPED/PUT"																		
	WSMETHOD DELETE DESCRIPTION "Exclus�o de Pedidos" WSSYNTAX "/{Empresa_Obrigatorio}/{Filial_Obrigatorio}/{CNPJ_Opcional}"			//WSSYNTAX "/WSRESTEFFPED/DELETE"

END WSRESTFUL     

WSMETHOD GET WSSERVICE WSRESTEFFPED		// GET dados para consulta      Por Parametro Numero do Pedido
	Local cRet
	local aParam := ::aURLParms
	Local cValEmp 	
	Local cValFil 	
	Local cNumPed
	Local lRes := .T.
	Local oJSON

	::SetContentType("application/json") 

	if len(aParam) < 2
		//::SetResponse('{"Status":"400","Mensagem":""}')
		lRes := .F.
		SetRestFault(400,EncodeUTF8("Inserir os par�metros: Empresa e Filial", "cp1252"))
		Return lRes
	endif

	if len(aParam) == 3
		cValEmp 	:= ::aURLParms[1]
		cValFil 	:= ::aURLParms[2]
		cNumPed 	:= ::aURLParms[3]
	else
		cValEmp 	:= ::aURLParms[1]
		cValFil 	:= ::aURLParms[2]
		cNumPed 	:= ""
	endif
	
	If !Vazio(cValEmp) .AND. !Vazio(cValFil)
	
		cRet := u_MyGetPed(cValEmp,cValFil,cNumPed)
		oJSON := JsonObject():New()
		oJSON:FromJson(cRet)

		cRet := EncodeUTF8(cRet, "cp1252")
		
		if !empty(oJSON["SC5"])
			::SetResponse(cRet)
		else
			lRes := .F.
			SetRestFault(400,EncodeUTF8("Pedido n�o encontrado. Pedido: "+cNumPed, "cp1252"))
		endif
			
	ElseIf Vazio(cValEmp) 

		lRes := .F.
		SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler o par�metro Empresa", "cp1252"))
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler o par�metro Empresa"}', "cp1252"))	

	ElseIf Vazio(cValFil)

		lRes := .F.
		SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler o par�metro Filial", "cp1252"))
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler o par�metro Filial"}', "cp1252"))	

	Endif

Return(lRes)  

WSMETHOD POST WSSERVICE WSRESTEFFPED		// POST dados para inclus�o.     Por Lista JSON

	Local cRet
	local cContent
	local oObjp
	Local lRes := .T.
	Local oJSON
		
	::SetContentType("application/json")
	cContent := ::GetContent()
	cContent := DecodeUTF8(cContent, "cp1252")										//Problema de conflito de acentua��o decodifica na entrada e cofifica na sa�da
	
	If FwJsonDeserialize(cContent,@oObjp)

		//Prepara Ambiente
		//If Type(oObjp:filial) != 'U' .AND. Type(oObjp:empresa) != 'U'
			RpcClearEnv()
			RpcSetType(3)
			//RpcSetEnv(oObjp:empresa,oObjp:filial) 
			RpcSetEnv("01","0101") 
		//Else	
			//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler a empresa e a filial do arquivo JSON."}', "cp1252"))
		//	lRes := .F.
		//	SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler a empresa e a filial do arquivo JSON.", "cp1252"))
		//	Return lRes	
		//Endif    
	
		cRet := u_MyMata410(oObjp,3,"")
		oJSON := JsonObject():New()
		oJSON:FromJson(cRet)
		cRet := EncodeUTF8(cRet, "cp1252")
		
		if oJSON["Status"] == "200"
			::SetResponse(cRet)
		else
			lRes := .F.
			SetRestFault(400,EncodeUTF8(oJSON["Mensagem"], "cp1252"))
		endif
	
	Else
	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel tratar o arquivo JSON."}', "cp1252"))	
		lRes := .F.
		SetRestFault(400,EncodeUTF8("N�o foi poss�vel tratar o arquivo JSON.", "cp1252"))

	Endif

Return(lRes)

WSMETHOD PUT WSSERVICE WSRESTEFFPED		// PUT das para Altera��o.     Por Lista JSON

	Local cRet
	local cContent
	local oObjp
	Local lRes := .T.
	Local oJSON
	
	::SetContentType("application/json")
	cContent := ::GetContent()
	cContent := DecodeUTF8(cContent, "cp1252")										//Problema de conflito de acentua��o decodifica na entrada e cofifica na sa�da
	
	If FwJsonDeserialize(cContent,@oObjp)

		//Prepara Ambiente
		If Type(oObjp:filial) != 'U' .AND. Type(oObjp:empresa) != 'U'
			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv(oObjp:empresa,oObjp:filial) 
		Else
			lRes := .F.
			SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler a empresa e a filial do Arquivo JSON.", "cp1252"))	
			//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler a empresa e a filial do Arquivo JSON."}', "cp1252"))
			Return lRes	
		Endif    
	
		cRet := u_MyMata410(oObjp,4,"")
		//cRet := EncodeUTF8(cRet, "cp1252")
		//::SetResponse(cRet)	
		oJSON := JsonObject():New()
		oJSON:FromJson(cRet)

		cRet := EncodeUTF8(cRet, "cp1252")
		
		if oJSON["Status"] == "200"
			::SetResponse(cRet)
		else
			lRes := .F.
			SetRestFault(400,EncodeUTF8(oJSON["Mensagem"], "cp1252"))
		endif

	Else

		lRes := .F.
		SetRestFault(400,EncodeUTF8("N�o foi poss�vel tratar o arquivo JSON.", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel tratar o arquivo JSON."}', "cp1252"))	
	
	Endif

Return(lRes)


WSMETHOD DELETE WSSERVICE WSRESTEFFPED		// DELETE dados para exclus�o      Por Parametro Numero do Pedido

	local oObjp
	Local cRet
	local aParam := ::aURLParms
	Local cValEmp 	
	Local cValFil 	
	Local cNumPed
	Local lRes := .T.
	Local oJSON

	::SetContentType("application/json") 
	
	if len(aParam) < 2
		lRes := .F.
		SetRestFault(400,EncodeUTF8("Inserir os par�metros: Empresa e Filial", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Inserir os par�metros: Empresa e Filial"}', "cp1252"))	
		Return lRes
	endif

	if len(aParam) == 3
		cValEmp 	:= ::aURLParms[1]
		cValFil 	:= ::aURLParms[2]
		cNumPed 	:= ::aURLParms[3]
	else
		cValEmp 	:= ::aURLParms[1]
		cValFil 	:= ::aURLParms[2]
		cNumPed 	:= ""
	endif

	If !Vazio(cValEmp) .AND. !Vazio(cValFil)

		//Prepara Ambiente
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv(cValEmp,cValFil) 
			
	ElseIf Vazio(cValEmp) 

		lRes := .F.
		SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler o par�metro Empresa", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler o par�metro Empresa"}', "cp1252"))	
		Return lRes

	ElseIf Vazio(cValFil)

		lRes := .F.
		SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler o par�metro Filial", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler o par�metro Filial"}', "cp1252"))	
		Return lRes

	Endif
	
	If !Empty(cNumPed)
	
		cRet := u_MyMata410(oObjp,5,cNumPed)
		oJSON := JsonObject():New()
		oJSON:FromJson(cRet)

		cRet := EncodeUTF8(cRet, "cp1252")
		
		if oJSON["Status"] == "200"
			::SetResponse(cRet)
		else
			lRes := .F.
			SetRestFault(400,EncodeUTF8(oJSON["Mensagem"], "cp1252"))
		endif
	
	Else

		lRes := .F.
		SetRestFault(400,EncodeUTF8("Exclus�o n�o efetuada. Par�metro em Branco.", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Exclus�o n�o efetuada. Par�metro em Branco."}', "cp1252"))	
	
	Endif	

Return(lRes)    
