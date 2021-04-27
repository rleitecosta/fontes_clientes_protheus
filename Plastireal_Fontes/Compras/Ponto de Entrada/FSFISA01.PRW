#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

/*-----------------------------------------------------------------------------------------------
{Protheus.doc} FSFISA01
Rotina de digitação da DI que será salva para todos os itens da Nota de Entrada
@author  Mário A. Cavenaghi - EthosX
@since   15/10/2020
@release P12.1.25
-------------------------------------------------------------------------------------------------
*/
User Function FSFISA01

	Local nOpcao  := 0
	Local nPosCD5 := 0
	Local aCampos := {}
	Local lGrvCD5 := .T.
	Local lInclui := .T.
	Local nRecSD1 := SD1->(Recno())
	Local cDocSD1 := SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)

	Private cCadAnterior := cCadastro

	SF1->(dbSetOrder())
	SF1->(dbSeek(xFilial() + cDocSD1))
	If SF1->F1_EST <> "EX"
		MsgBox("Este tipo de documento fiscal não possui complemento de operações de importação", "Importação", "STOP")
	Else
		CD5->(dbSetOrder(1))
		If CD5->(dbSeek(xFilial() + cDocSD1))
			lInclui := .F.
			//lGrvCD5 := MsgBox("Deseja alterar todos os Itens ?", "Já existe D.I. para essa nota", "YESNO")	//	A rotina AXALTERA só visualiza, não edita o registro
		EndIf
		If lGrvCD5
			SX3->(dbSetOrder(1))
			SX3->(dbSeek("CD5"))
			While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "CD5"
				If SX3->X3_VISUAL <> "V" .And. SX3->X3_CONTEXT <> "V" .And. SX3->X3_NIVEL <= cNivel .And. X3Uso(SX3->X3_USADO)
					aAdd(aCampos, SX3->X3_CAMPO)
				EndIf
				SX3->(dbSkip())
			EndDo
			cCadastro := "Digitação da D.I. da Nota " + SD1->D1_DOC + "-" + SD1->D1_SERIE
			If lInclui
				nOpcao := AxInclui("CD5",, 3, aCampos)
				If nOpcao == 1
					CD5->(RecLock("CD5"))
					CD5->CD5_FILIAL := SD1->D1_FILIAL
					CD5->CD5_DOC    := SD1->D1_DOC
					CD5->CD5_SERIE  := SD1->D1_SERIE
					CD5->CD5_FORNEC := SD1->D1_FORNECE
					CD5->CD5_LOJA   := SD1->D1_LOJA
					CD5->CD5_SDOC   := SD1->D1_SERIE
					CD5->CD5_ITEM   := SD1->D1_ITEM
					CD5->CD5_ESPEC  := SF1->F1_ESPECIE
					CD5->(msUnLock())
				EndIf
			Else
				//	nOpcao := AxAltera("CD5",, 4, aCampos)	//	Essa opção não está editando !!!
				AxAltera("CD5",, 4, aCampos)
			EndIf
			If nOpcao == 1	//	Confirmado
				cCadastro := cCadAnterior
				ChkFile("CD5",, "xCD5")
				xCD5->(dbSetOrder(4))
				SD1->(dbSetOrder(1))
				SD1->(dbSeek(xFilial() + cDocSD1))
				While ! SD1->(Eof()) .And. SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == cDocSD1
					If xCD5->(dbSeek(xFilial("CD5") + cDocSD1 + SD1->D1_ITEM))
						xCD5->(RecLock("xCD5", .F.))
					Else
						xCD5->(RecLock("xCD5", .T.))
					EndIf
					For nPosCD5 := 1 To CD5->(fCount())
						xCD5->(FieldPut(nPosCD5, CD5->(FieldGet(nPosCD5))))
					Next
					xCD5->CD5_ITEM := SD1->D1_ITEM
					xCD5->(msUnLock())
					SD1->(dbSkip())
				EndDo
				xCD5->(dbCloseArea())
			EndIf
			SD1->(dbGoto(nRecSD1))
		EndIf
	EndIf

Return(.T.)
