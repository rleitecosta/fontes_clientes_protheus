#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

/*-----------------------------------------------------------------------------------------------
{Protheus.doc} FSFATM01
Transmite para o AFX (CODIT), as manutenções ocorridas na tabela selecionada
@author  Mário A. Cavenaghi - EthosX
@since   07/10/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------
*/
Static _aTabelaEnvio := { ;
	{"SA4", "A4_XCODIT" , "/tms/saveTransportadora"}, ;
	{"SE4", "E4_XCODIT" , "/bas/saveCondPgto"}, ;
	{"AK5", "AK5_XCODIT", ""}, ;
	{"CTT", "CTT_XCODIT", ""} }

//-----------------------------------------------------------------------------------------------
User Function FSFATM01(cTabela, nExclui)

	Local cQuery      := ""
	Local cCampoEnvio := ""
	Local cAliasTmp   := cTabela + "T"

	Local nRecno      := 0
	Local nPosArray   := aScan(_aTabelaEnvio, {|x| x[1] == cTabela})

	Private _lEnd     := .T.

	Default nExclui   := 0

	If nPosArray > 0
		SX2->(dbSetOrder(1))
		SX2->(dbSeek(cTabela))
		cCampoEnvio := _aTabelaEnvio[nPosArray, 2]
		cQuery := "SELECT RECNO = COUNT(*)" + CRLF
		cQuery += "  FROM " + RetSqlName(cTabela) + CRLF
		cQuery += " WHERE " + cCampoEnvio + " = ' ' "
		dbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cAliasTmp, .F., .T.)
		nRecno := (cAliasTmp)->RECNO
		(cAliasTmp)->(dbCloseArea())
		If     nRecno > 1
			StartJob("U_FTM01JOB", GetEnvServer(), .F. , {cEmpAnt, cFilAnt, cTabela, nExclui, nPosArray})
			MsgBox("ENVIO DE REGISTROS EM 2o. PLANO, INTEGRAÇÃO AFX :: " + AllTrim(Upper(SX2->X2_NOME)), "Integrando tabela via JOB", "STOP")
		ElseIf nRecno > 0	//	(= 1 e <> 0)
			Processa({| _lEnd| U_FTM01JOB({cEmpAnt, cFilAnt, cTabela, nExclui, nPosArray})}, "Enviando registros da Tabela " + cTabela + ", para integração com ATX", "Aguarde...", .T.)
			MsgBox("SUCESSO INTEGRAÇÃO AFX :: " + AllTrim(Upper(SX2->X2_NOME)), "Registro integrado com Sucesso", "STOP")
		EndIf
	EndIf

Return

//-----------------------------------------------------------------------------------------------
//	Seleciona registros para disparar Envio de pacotes JSON em JOB ou CLIENT
User Function FTM01JOB(aParms)

	Local cJSon       := ""
	Local cQuery      := ""
	Local cCondicao   := ""
	Local cCampoEnvio := ""
	Local cTabela     := aParms[3]
	Local cAliasTmp   := cTabela + "T"
	Local cServer     := "54.233.177.56"                   //	URL (IP) DO SERVIDOR
	Local cPort       := "9608"                            //	PORTA DO SERVIÇO REST
	Local cURI        := "http://" + cServer + ":" + cPort //	URI DO SERVIÇO REST
	Local cResource   := ""                                //	RECURSO A SER CONSUMIDO

	Local nCampoEnvio := 0
	Local nExclui     := aParms[4]
	Local nPosArray   := aParms[5]

	Local oJSon       := JsonObject():New()
	Local oRest       := Nil 	//	CLIENTE PARA CONSUMO REST

	Local lHomologa   := .F.
	Local lJob        := IsBlind()

	Local aHeader     := { ;
		"Content-Type: application/json; charset=UTF-8", ;
		"Accept: application/json", ;
		"User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")" }	//	CABEÇALHO DA REQUISIÇÃO

	If lJob
		RpcSetType(3)
		RPCSetEnv(aParms[1], aParms[2])	//	Empresa, Filial
	EndIf
	cServer     := GetPvProfString(GetEnvServer(),"helpserver","ERROR",GetAdv97())
	lHomologa   := "105325" $ cServer
	cCampoEnvio := _aTabelaEnvio[nPosArray, 2]
	cResource   := _aTabelaEnvio[nPosArray, 3]
	If Empty(cResource)
		If lJob
			ConOut(ProcName() + " -> Não existe URI definido para a tabela " + cTabela)
		Else
			MsgBox("Não existe URI definido para a tabela " + cTabela, "Atenção", "STOP")
		EndIf
	Else
		If (nCampoEnvio := (cTabela)->(FieldPos(cCampoEnvio))) > 0
			cQuery := "SELECT RECNO = R_E_C_N_O_" + CRLF
			cQuery += "  FROM " + RetSqlName(cTabela) + CRLF
			cQuery += " WHERE " + cCampoEnvio + " = ' ' "
			dbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cAliasTmp, .F., .T.)
			oRest := FwRest():New(cURI)
			oRest:SetPath(cResource)
			oJSon["id_service"] := "zD20190403H111753080R000000005"
			If lHomologa
				oJSon["environment"] := "HOMOLOGACAO"
			EndIf
			While !(cAliasTmp)->(Eof())
				(cTabela)->(dbGoto((cAliasTmp)->RECNO))
				If     cTabela == "SA4"	//	Transportadora
					oJSon["tms_transportadora.codigo"]    := SA4->A4_COD
					oJSon["tms_transportadora.descricao"] := NoAcento(AllTrim(SA4->A4_NOME))
				ElseIf cTabela == "SE4"	//	Condição de Pagamento
					cCondicao := AllTrim(SE4->E4_COND)
					If cCondicao == "00"	//	A Vista
						cCondicao := "0 - Pagamento a vista"
					Elseif "00" $ cCondicao	//	Entrada + Parcelas
						cCondicao := "2 - Outros"
					Else	//	Parcelado Sem Entrada
						cCondicao := "1 - Pagamento a prazo"
					EndIf
					oJSon["bas_condpgto.codigo"   ] := SE4->E4_CODIGO
					oJSon["bas_condpgto.descricao"] := NoAcento(AllTrim(SE4->E4_DESCRI))
					oJSon["bas_condpgto.IndPag"   ] := cCondicao
					oJSon["ISINACTIVE"            ] := Iif(SE4->E4_MSBLQL == "2", "true", "false")
				ElseIf cTabela == "AK5"	//	Plano de Contas Orçamentário

				ElseIf cTabela == "CTT"	//	Centro de Custo

				EndIf
				If nExclui == (cTabela)->(Recno())	//	Registro que será excluído
					oJSon["ISDELETED"] := "true"
				Else
					oJSon["ISDELETED"] := Iif((cTabela)->(Deleted()), "true", "false")
				EndIf
				cJSon := oJson:ToJson()
				oRest:SetPostParams(cJSon)
				If oRest:Post(aHeader)	// REALIZA O MÉTODO POST E VALIDA O RETORNO
					cJSon := "POST: " + oRest:GetResult()
					(cTabela)->(RecLock(cTabela, .F.,,, lJob))
					(cTabela)->(FieldPut(nCampoEnvio, "X"))	//	Marca como já transmitido
					(cTabela)->(msUnLock())
				Else
					cJSon := "POST: " + oRest:GetLastError()
				EndIf
				(cAliasTmp)->(dbSkip())
			EndDo
			(cAliasTmp)->(dbCloseArea())
		EndIf
	EndIf

Return
