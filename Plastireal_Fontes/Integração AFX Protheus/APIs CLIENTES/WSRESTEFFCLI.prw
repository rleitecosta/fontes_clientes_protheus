#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTEFFCLI    Ultima Alteração: Ricardo G. de Aguiar      Data: 13/02/2020  
//Descrição: API Cliente - Ligação entre o Rest e o ExecAuto 
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSRESTFUL WSRESTEFFCLI DESCRIPTION "WEBSERVICE REST - CLIENTES" FORMAT APPLICATION_JSON

	WSDATA Emp  AS CHARACTER
	WSDATA Fil  AS CHARACTER
	WSDATA Cli  AS CHARACTER
	WSDATA Loj  AS CHARACTER

	WSMETHOD POST   DESCRIPTION "Cadastro de Clientes" WSSYNTAX "/"																				//"/WSRESTEFFCLI/POST"
	WSMETHOD PUT    DESCRIPTION "Alteração de Clientes" WSSYNTAX "/"																			//"/WSRESTEFFCLI/PUT"
	WSMETHOD DELETE DESCRIPTION "Exclusão de Clientes" WSSYNTAX "/{Empresa_Obrigatorio}/{Filial_Obrigatorio}/{CNPJ_Opcional}"					//"/WSRESTEFFCLI/DELETE"
	WSMETHOD GET GetCliente;
        DESCRIPTION 'Retorna Lista de Clientes';
        WSSYNTAX '/GetCliente';
        PATH 'GetCliente';
        PRODUCES APPLICATION_JSON
	//WSMETHOD GET    DESCRIPTION "Retorna Lista de Clientes" WSSYNTAX "/{Empresa_Obrigatorio}/{Filial_Obrigatorio}/{CNPJ_Opcional}"				//"/WSRESTEFFCLI/GET"
END WSRESTFUL

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

//WSMETHOD GET WSSERVICE WSRESTEFFCLI		// GET dados para consulta      Por Parametro Empresa, Filial, C.N.P.J
WSMETHOD GET GetCliente WSRECEIVE Emp, Fil, Cli, Loj WSREST WSRESTEFFCLI

Local cRet
Local aParam 	:= {}
Local cValEmp	:= Self:Emp 	
Local cValFil 	:= Self:Fil
Local cValCli	:= Self:Cli
Local cValLoj	:= Self:Loj
Local lRes 		:= .T.
Local oObj
Local oJSON 	:= JsonObject():New()

::SetContentType("application/json") 
aParam 	:= ::aURLParms

If !Empty(cValEmp) .And. !Empty(cValFil)

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cValEmp,cValFil) 

	DbSelectArea("SA1")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA1")+PADR(cValCli,TAMSX3("A1_COD")[1])+PADR(cValLoj,TAMSX3("A1_COD")[1]))
		cRet := '{"found":"true"}'
	Else
		cRet := '{"found":"false"}'
	endif
	cRet := EncodeUTF8(cRet, "cp1252")
	::SetResponse(cRet)

Else

	lRes := .F.
	SetRestFault(400,EncodeUTF8("Inserir os parâmetros: Empresa e Filial", "cp1252"))	
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Inserir os parâmetros: Empresa e Filial"}', "cp1252"))	
	Return lRes

endif

Return lRes

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD POST WSSERVICE WSRESTEFFCLI		// POST dados para inclusão.     Por Lista JSON

Local cRet
local cContent
local oObj
Local lRes  := .T.
Local oJSON := JsonObject():New()

::SetContentType("application/json")
cContent := ::GetContent()
cContent := DecodeUTF8(cContent, "cp1252")						//Problema de conflito de acentuação decodifica na entrada e cofifica na saída
//cContent := '{"empresa":"01","filial":"01","Object":[{"campo":"A1_LOJA","conteudo":"01"},{"campo":"A1_NOME","conteudo":"RODRIGO DE DEUS"},{"campo":"A1_PESSOA","conteudo":"F"},{"campo":"A1_END","conteudo":"RUA RODRIGO DE DEUS"},{"campo":"A1_NREDUZ","conteudo":"TOTVS"},{"campo":"A1_TIPO","conteudo":"F"},{"campo":"A1_EST","conteudo":"SP"},{"campo":"A1_MUN","conteudo":"SAO PAULO"},{"campo":"A1_CGC","conteudo":"44444444444"}]}'

If FwJsonDeserialize(cContent,@oObj)
	
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
	
	cRet := u_MyMata030(oObj,3,"")
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

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD PUT WSSERVICE WSRESTEFFCLI		// PUT das para Alteração.     Por Lista JSON

Local cRet
local cContent
local oObj
Local lRes := .T.
Local oJSON := JsonObject():New()

::SetContentType("application/json")
cContent := ::GetContent() 
cContent := DecodeUTF8(cContent, "cp1252")

If FwJsonDeserialize(cContent,@oObj)

	//Prepara Ambiente
	//If Type(oObj:filial) != 'U' .AND. Type(oObj:empresa) != 'U'
		RpcClearEnv()
		RpcSetType(3)
	//	RpcSetEnv(oObj:empresa,oObj:filial) 
		RpcSetEnv("01","0101")
	//Else	
	//	lRes := .F.
	//	SetRestFault(400,EncodeUTF8("Não foi possível ler a Empresa e a Filial do Arquivo JSON", "cp1252"))
	//	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível ler a Empresa e a Filial do Arquivo JSON."}', "cp1252"))
	//		Return lRes	
	//	Endif    

	cRet := u_MyMata030(oObj,4,"")
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
	SetRestFault(400,EncodeUTF8("Não foi possível tratar o Arquivo JSON.", "cp1252"))
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível tratar o Arquivo JSON."}', "cp1252"))	

Endif

Return lRes

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD DELETE WSSERVICE WSRESTEFFCLI		// DELETE dados para exclusão      Por Parametro Empresa, Filial, C.N.P.J

local oObj
Local cRet
local aParam := ::aURLParms
Local cValEmp 	
Local cValFil 	
Local cValCli
Local lRes := .T.
Local oJSON := JsonObject():New()

::SetContentType("application/json") 

if len(aParam) < 2
	lRes := .F.
	SetRestFault(400,EncodeUTF8("Inserir os parâmetros: Empresa e Filial", "cp1252"))
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Inserir os parâmetros: Empresa e Filial"}', "cp1252"))	
	Return lRes
endif

if len(aParam) == 3
	cValEmp 	:= ::aURLParms[1]
	cValFil 	:= ::aURLParms[2]
	cValCli 	:= ::aURLParms[3]
else
	cValEmp 	:= ::aURLParms[1]
	cValFil 	:= ::aURLParms[2]
	cValCli 	:= ""
endif

If !Vazio(cValEmp) .AND. !Vazio(cValFil)

	//Prepara Ambiente
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cValEmp,cValFil) 
		
ElseIf Vazio(cValEmp) 

	lRes := .F.
	SetRestFault(400,EncodeUTF8("Não foi possível ler o parâmetro Empresa", "cp1252"))
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível ler o parâmetro Empresa"}', "cp1252"))	
	Return lRes

ElseIf Vazio(cValFil)

	lRes := .F.
	SetRestFault(400,EncodeUTF8("Não foi possível ler o parâmetro Filial", "cp1252"))
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível ler o parâmetro Filial"}', "cp1252"))	
	Return lRes

Endif

If !Empty(cValCli)   

	cRet := u_MyMata030(oObj,5,cValCli)
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
	SetRestFault(400,EncodeUTF8("Não foi possível executar a exclusão. Parâmetro em Branco.", "cp1252"))
	//::SetResponse(EncodeUTF8('{"Status":"400","Mensagem":"Não foi possível executar a exclusão. Parâmetro em Branco."}', "cp1252"))	

Endif	

Return lRes      // SrvWizard  