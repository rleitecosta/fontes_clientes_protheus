#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTEFFPRD    Ultima Alteração: Carlos H. Fernandes      Data: 07/01/2020  
//Descrição: API Produtos - Ligação entre o Rest e o ExecAuto 
//Uso: PlastReal
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSRESTFUL WSRESTEFFPRD DESCRIPTION "WEBSERVICE REST - PRODUTOS" FORMAT APPLICATION_JSON

	WSDATA Emp  AS CHARACTER
	WSDATA Fil  AS CHARACTER
	WSDATA Cod  AS CHARACTER

	WSMETHOD POST   DESCRIPTION "Cadastro de Produto" WSSYNTAX "/"																			//"/WSRESTEFFCLI/POST"
	WSMETHOD PUT    DESCRIPTION "Alteração de Produto" WSSYNTAX "/"																			//"/WSRESTEFFCLI/PUT"
	//WSMETHOD DELETE DESCRIPTION "Exclusão de Produto" WSSYNTAX "/{Empresa_Obrigatorio}/{Filial_Obrigatorio}/{Codigo_Obrigatorio}"			//"/WSRESTEFFCLI/DELETE"
	WSMETHOD GET GetProduto;
        DESCRIPTION 'Retorna Lista de Produto';
        WSSYNTAX '/GetProduto';
        PATH 'GetProduto';
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD GET GetProduto WSRECEIVE Emp, Fil, Cod WSREST WSRESTEFFPRD

Local cRet
Local aParam 	:= {}
Local cValEmp	:= Self:Emp 	
Local cValFil 	:= Self:Fil
Local cValPRD	:= Self:Cod
Local lRes 		:= .T.
Local oObj
Local oJSON 	:= JsonObject():New()

::SetContentType("application/json") 
aParam 	:= ::aURLParms

If !Empty(cValEmp) .And. !Empty(cValFil)

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cValEmp,cValFil) 

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+cValPRD)
		cRet := '{ "SB1": [	{"campo":"B1_FILIAL"	,"conteudo":"'+SB1->B1_FILIAL+'"			  },'
		cRet +=			'	{"campo":"B1_ATIVO" 	,"conteudo":"'+SB1->B1_ATIVO+'" 			  },'
		cRet +=			'	{"campo":"B1_COD"   	,"conteudo":"'+Alltrim(SB1->B1_COD)+'"		  },'
		cRet +=			'	{"campo":"B1_DESC"		,"conteudo":"'+Alltrim(SB1->B1_DESC)+'"		  },'
		cRet +=			'	{"campo":"B1_UM"		,"conteudo":"'+SB1->B1_UM+'"				  },'
		cRet +=			'	{"campo":"B1_DESBSE3"	,"conteudo":"'+Alltrim(SB1->B1_DESBSE3)+'"	  },'
		cRet +=			'	{"campo":"B1_BASE3"		,"conteudo":"'+Alltrim(SB1->B1_BASE3)+'"	  },'
		cRet +=			'	{"campo":"B1_IPI"		,"conteudo":"'+Alltrim(Str(SB1->B1_IPI))+'"	  },'
		cRet +=			'	{"campo":"B1_POSIPI"	,"conteudo":"'+Alltrim(SB1->B1_POSIPI)+'"	  },'
		cRet +=			'	{"campo":"B1_ORIGEM"	,"conteudo":"'+SB1->B1_ORIGEM+'"			  },'
		cRet +=			'	{"campo":"B1_GRTRIB"	,"conteudo":"'+SB1->B1_GRTRIB+'"			  },'
		cRet +=			'	{"campo":"B1_PICM"		,"conteudo":"'+Alltrim(Str(SB1->B1_PICM))+'"  },'
		cRet +=			'	{"campo":"B1_CONTRAT"	,"conteudo":"'+SB1->B1_CONTRAT+'"			  },'
		cRet +=			'	{"campo":"B1_LOCALIZ"	,"conteudo":"'+SB1->B1_LOCALIZ+'"			  },'
		cRet +=			'	{"campo":"B1_CUSTD"		,"conteudo":"'+Alltrim(Str(SB1->B1_CUSTD))+'" },'
		cRet +=			'	{"campo":"B1_TIPO"		,"conteudo":"'+SB1->B1_TIPO+'"				  },'
		cRet +=			'	{"campo":"B1_CODBAR"	,"conteudo":"'+SB1->B1_CODBAR+'"			  },'
		cRet +=			'	{"campo":"B1_PESO"		,"conteudo":"'+Alltrim(Str(SB1->B1_PESO))+'  "},'
		cRet +=			'	{"campo":"B1_ESTSEG"	,"conteudo":"'+Alltrim(Str(SB1->B1_ESTSEG))+'"},'
		cRet +=			'	{"campo":"B1_EMIN"		,"conteudo":"'+Alltrim(Str(SB1->B1_EMIN))+'  "},'
		cRet +=			'	{"campo":"B1_LOCPAD"	,"conteudo":"'+SB1->B1_LOCPAD+'"			  },'
		cRet +=			'	{"campo":"B1_GRUPO" 	,"conteudo":"'+SB1->B1_GRUPO+'"				  },'
		cRet +=			'	{"campo":"B1_GARANT"	,"conteudo":"'+SB1->B1_GARANT+'"			} ],'
		
		DbSelectArea("SB5")
		DbSetOrder(1)
		If DbSeek(xFilial("SB5")+PADR(cValPRD,TAMSX3("B5_COD")[1]))
			
			cRet += '"SB5": [ {"campo":"B5_FILIAL"	,"conteudo":"'+SB5->B5_FILIAL+'"},'
			cRet +=			' {"campo":"B5_COD"		,"conteudo":"'+Alltrim(SB5->B5_COD)+'"   },'
			cRet +=			' {"campo":"B5_CEME"	,"conteudo":"'+Alltrim(SB5->B5_CEME)+'"  },'
			cRet +=			' {"campo":"B5_LARG"	,"conteudo":"'+Alltrim(Str(SB5->B5_LARG))+'"  },'
			cRet +=			' {"campo":"B5_COMPR"	,"conteudo":"'+Alltrim(Str(SB5->B5_COMPR))+'" },'
			cRet +=			' {"campo":"B5_ESPESS"	,"conteudo":"'+Alltrim(Str(SB5->B5_ESPESS))+'"},'
			cRet +=			' {"campo":"B5_XCOR"	,"conteudo":"'+Alltrim(SB5->B5_XCOR)+'"	},'
			cRet +=			' {"campo":"B5_DIAINT"	,"conteudo":"'+Alltrim(Str(SB5->B5_DIAINT))+'"},'
			cRet +=			' {"campo":"B5_DIAEXT"	,"conteudo":"'+Alltrim(Str(SB5->B5_DIAEXT))+'"} ]}'

		Else
	
			cRet += '"SB5": [ {"campo":"B5_FILIAL"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_COD"		,"conteudo":" "},'
			cRet +=			' {"campo":"B5_CEME"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_LARG"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_COMPR"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_ESPESS"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_XCOR"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_DIAINT"	,"conteudo":" "},'
			cRet +=			' {"campo":"B5_DIAEXT"	,"conteudo":" "}]}'

		Endif
	
	Else
	
		cRet := '{"found":"false"}'
	
	Endif
	
	cRet := EncodeUTF8(cRet, "cp1252")
	::SetResponse(cRet)

Else

	lRes := .F.
	SetRestFault(400,EncodeUTF8("Inserir os parâmetros: Empresa e Filial", "cp1252"))	
	Return lRes

endif

Return lRes

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD POST WSSERVICE WSRESTEFFPRD		// POST dados para inclusão.     Por Lista JSON

Local cRet
Local cContent
Local cRetSB1
Local cRetSB5
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
	cRet := u_MyMata010(oObj,3,"")
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

WSMETHOD PUT WSSERVICE WSRESTEFFPRD		// PUT das para Alteração.     Por Lista JSON

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

	//Chamada para execauto
	cRet := u_MyMata010(oObj,4,"")
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

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD DELETE WSSERVICE WSRESTEFFPRD		// DELETE dados para exclusão      Por Parametro Empresa, Filial, C.N.P.J

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