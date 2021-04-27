#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTEFFNFE    Ultima Altera��o: Carlos H. Fernandes      Data: 07/01/2020  
//Descri��o: API Documento de Entrada - Liga��o entre o Rest e o ExecAuto 
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSRESTFUL WSRESTEFFNFE DESCRIPTION "WEBSERVICE REST - DOCUMENTO DE ENTRADA" FORMAT APPLICATION_JSON
	//WSMETHOD POST DESCRIPTION "Documento de Entrada" WSSYNTAX "/"		
	WSMETHOD POST DESCRIPTION 'Documento de Entrada - Pr� Nota';
        WSSYNTAX '/';
        PATH 'WSRESTEFFNFE';
        PRODUCES APPLICATION_JSON																	//"/WSRESTEFFCLI/POST"

END WSRESTFUL

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD POST WSSERVICE WSRESTEFFNFE		// POST dados para inclus�o.     Por Lista JSON

Local cRet
Local cContent
Local cRetSF1
Local cRetSD1
Local oObj
Local lRes  := .T.
Local oJSON := JsonObject():New()

::SetContentType("application/json")
cContent := ::GetContent()
cContent := DecodeUTF8(cContent, "cp1252")						//Problema de conflito de acentua��o decodifica na entrada e cofifica na sa�da

if FwJsonDeserialize(cContent,@oObj)

	//Prepara Ambiente
	//If Type(oObj:filial) != 'U' .AND. Type(oObj:empresa) != 'U'
		RpcClearEnv()
		RpcSetType(3)
		//RpcSetEnv(oObj:empresa,oObj:filial) 
		RpcSetEnv("01","0101")
	//Else	
	//	lRes := .F.
	//	SetRestFault(400,EncodeUTF8("N�o foi poss�vel ler a Empresa e a Filial do Arquivo JSON.", "cp1252"))	
		//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel ler a Empresa e a Filial do Arquivo JSON."}', "cp1252"))
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
	SetRestFault(400,EncodeUTF8("N�o foi poss�vel tratar o Arquivo JSON", "cp1252"))	
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"N�o foi poss�vel tratar o Arquivo JSON."}', "cp1252"))	

Endif

Return lRes