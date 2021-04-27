#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

/*-----------------------------------------------------------------------------------------------
{Protheus.doc} FSCTBM01
Rotina para remover mascaras e zeros a diretas dos campos de Conta e C.Custo
@author  Mário A. Cavenaghi - EthosX
@since   20/10/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------
*/
User Function FSCTBM01()

	If MsgNoYes("Deseja corrigir os códigos das Contas e dos Centros de Custo, em todas as tabelas ?", "Atenção")
		oProcess := MsNewProcess():New({| lEnd| PROCTROCA(@lEnd)}, "Atualizando", "Aguarde, atualizando ...", .F.)
		oProcess:Activate()
	EndIf

Return

//-----------------------------------------------------------------------------------------------
Static Function PROCTROCA(lEnd)

	Local nTab := 0
	Local nItem := 0

	Local cQuery := ""
	Local cCpoOrigem := ""
	Local cTabOrigem := ""
	Local cTabDestino := ""
	Local cCodigoOrig := ""
	Local cCodigoNovo := ""

	Local lClose := .F.

	Local aMascara := {}
	Local aTabDestino := {}
	Local aTabOrigem := { ;
		{"CT1", "CT1_CONTA" }, ;
		{"AK5", "AK5_CODIGO"}, ;
		{"CTT", "CTT_CUSTO" } }

	oProcess:SetRegua1(Len(aTabOrigem))
	SX2->(dbSetOrder(1))
	For nTab := 1 To Len(aTabOrigem)
		cTabOrigem := aTabOrigem[nTab, 1]
		cCpoOrigem := aTabOrigem[nTab, 2]
		SX2->(cTabOrigem)
		oProcess:IncRegua1("Tabela " + cTabOrigem + " -> " + AllTrim(SX2->X2_NOME))
		cQuery := "SELECT X9_CDOM, X9_EXPCDOM " + CRLF
		cQuery += "  FROM SX9" + cEmpAnt + "0" + CRLF
		cQuery += " WHERE X9_EXPDOM  = '" + aTabOrigem[nTab, 2] + "' " + CRLF
		cQuery += "   AND D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " ORDER BY X9_CDOM, X9_EXPCDOM "
		dbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), "xSX9", .F., .T.)
		aTabDestino := {}
		While ! xSX9->(Eof())
			aAdd(aTabDestino, {xSX9->X9_CDOM, AllTrim(xSX9->X9_EXPCDOM)})
			xSX9->(dbSkip())
		EndDo
		xSX9->(dbCloseArea())
		(cTabOrigem)->(dbSetOrder(0))
		(cTabOrigem)->(dbGoTop())
		oProcess:SetRegua2((cTabOrigem)->(LastRec()))
		While ! (cTabOrigem)->(Eof())
			cCodigoOrig := AllTrim((cTabOrigem)->(FieldGet(FieldPos(cCpoOrigem))))
			aMascara := StrTokArr2(cCodigoOrig, ".")
			cCodigoNovo := ""
			For nItem := 1 To Len(aMascara)
				If Val(aMascara[nItem]) > 0
					cCodigoNovo += aMascara[nItem]
				Else
					Exit
				Endif
			Next
			oProcess:IncRegua2( "Trocando: '" + cCodigoOrig + "' por: '" + cCodigoNovo + "'")
			If cCodigoNovo <> cCodigoOrig
				Begin Transaction
					RecLock(cTabOrigem)
					(cTabOrigem)->(FieldPut(FieldPos(cCpoOrigem), cCodigoNovo))
					For nItem := 1 To Len(aTabDestino)
						cTabDestino := aTabDestino[nItem, 1]
						lClose := ! (Select(cTabDestino) > 0)
						If (cTabDestino)->(LastRec()) > 0
							cQuery := "UPDATE " + RetSqlName(cTabDestino) + CRLF
							cQuery += "   SET " + aTabDestino[nItem, 2] + " = '" + cCodigoNovo + "'" + CRLF
							cQuery += " WHERE " + aTabDestino[nItem, 2] + " = '" + cCodigoOrig + "'" + CRLF
							cQuery += "   AND D_E_L_E_T_ = ' ' "
							TCSQLExec(cQuery)
						Endif
						If lClose
							(cTabDestino)->(dbCloseArea())
						EndIf
					Next
					msUnLock()
				End Transaction
			EndIf
			(cTabOrigem)->(dbSkip())
		EndDo
	Next

Return
