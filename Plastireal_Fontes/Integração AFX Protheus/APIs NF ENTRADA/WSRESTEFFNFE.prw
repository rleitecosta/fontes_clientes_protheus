#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTEFFNFE    Ultima Alteração: Carlos H. Fernandes      Data: 07/01/2020  
//Descrição: API Documento de Entrada - Ligação entre o Rest e o ExecAuto 
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSRESTFUL WSRESTEFFNFE DESCRIPTION "WEBSERVICE REST - DOCUMENTO DE ENTRADA" FORMAT APPLICATION_JSON
	//WSMETHOD POST DESCRIPTION "Documento de Entrada" WSSYNTAX "/"		
	WSMETHOD POST DESCRIPTION 'Documento de Entrada - Pré Nota';
        WSSYNTAX '/';
        PATH 'WSRESTEFFNFE';
        PRODUCES APPLICATION_JSON																	//"/WSRESTEFFCLI/POST"

END WSRESTFUL

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD POST WSSERVICE WSRESTEFFNFE		// POST dados para inclusão.     Por Lista JSON

Local cRet
Local cContent
Local cRetSF1
Local cRetSD1
Local oObj
Local lRes  := .T.
Local oJSON := JsonObject():New()

::SetContentType("application/json")
cContent := ::GetContent()
cContent := DecodeUTF8(cContent, "cp1252")						//Problema de conflito de acentuação decodifica na entrada e cofifica na saída

if FwJsonDeserialize(cContent,@oObj)

	//Prepara Ambiente
	//If Type(oObj:filial) != 'U' .AND. Type(oObj:empresa) != 'U'
		RpcClearEnv()
		RpcSetType(3)
		//RpcSetEnv(oObj:empresa,oObj:filial) 
		RpcSetEnv("01","0101")
	//Else	
	//	lRes := .F.
	//	SetRestFault(400,EncodeUTF8("Não foi possível ler a Empresa e a Filial do Arquivo JSON.", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível ler a Empresa e a Filial do Arquivo JSON."}', "cp1252"))
	//	Return lRes	
	//Endif    
	
	//Chamada para execauto
	cRet := u_MyMata140(oObj,3,"")
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
	SetRestFault(400,EncodeUTF8("Não foi possível tratar o Arquivo JSON", "cp1252"))	
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível tratar o Arquivo JSON."}', "cp1252"))	

Endif

Return lRes