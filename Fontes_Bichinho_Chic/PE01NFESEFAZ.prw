#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PE01NFESEFAZ ³ Autor ³ Lucas Souza        ³ Data ³13.09.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada responsavel pela customizacoes do XML/DANFE³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION PE01NFESEFAZ()

	Local aProd       := PARAMIXB[1]
	Local cMensCli    := PARAMIXB[2]
	Local cMensFis    := PARAMIXB[3]
	Local aDest       := PARAMIXB[4] 
	Local aNota       := PARAMIXB[5]
	Local aInfoItem   := PARAMIXB[6]
	Local aDupl       := PARAMIXB[7]
	Local aTransp     := PARAMIXB[8]
	Local aEntrega    := PARAMIXB[9]
	Local aRetirada   := PARAMIXB[10]
	Local aVeiculo    := PARAMIXB[11]
	Local aReboque    := PARAMIXB[12]
	Local aNfVincRur  := PARAMIXB[13]
	Local aEspVol     := PARAMIXB[14]
	Local aNfVinc     := PARAMIXB[15] 
	Local aRetorno    := {}

	AlterInfo( @aProd, @cMensCli ,  @aNota, @aInfoItem)

	aadd(aRetorno,aProd) 
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol)
	aadd(aRetorno,aNfVinc)

RETURN aRetorno




Static Function AlterInfo(aProd,cMensCli, aNota , aInfoItem)

	Local nCont 	:= 1
	Local cDoc 		:= aNota[02]
	Local cSerie 	:= aNota[01]
	Local cTipo 	:= aNota[04]
	Local cCliFor 	:= IIF (cTipo == "0" , SF1->F1_FORNECE	, SF2->F2_CLIENTE)
	Local cLoja 	:= IIF (cTipo == "0" , SF1->F1_LOJA		, SF2->F2_LOJA)


	If cTipo == "1"  //Nota de Saida


		//-------------Alteração do Produto InfADprod------------------------------------------

		For nCont := 1 to Len (aProd)

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial('SB1')+aProd[nCont,02]))

			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial('SA1') + cCliFor + cLoja))

			SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(DbSeek(xFilial('SD2') +  cDoc + cSerie + cCliFor + cLoja + aProd[nCont,02] + strzero(aProd[nCont,01],TAMSX3("D2_ITEM")[1]))) 

			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial('SC5') + aInfoItem[nCont,01]))

			SC6->(DbSetOrder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SC6->(DbSeek(xFilial('SC6') + aInfoItem[nCont,01] + aInfoItem[nCont,02] + aProd[nCont,02] ))
			/*
			IF !Empty(aProd[nCont,46])
				 aProd[nCont,46] := ""
			Endif
			*/
			If SC6->C6_XUNMED == '2' .AND. !Empty(SC6->C6_SEGUM)

				aProd[nCont,08] := SD2->D2_SEGUM
				aProd[nCont,11] := SD2->D2_SEGUM

				aProd[nCont,09]	:= SD2->D2_QTSEGUM
				aProd[nCont,12]	:= SD2->D2_QTSEGUM

				aProd[nCont,16]	:= SD2->D2_TOTAL / SD2->D2_QTSEGUM

			EndIf
															
			
		Next nCont

		//-----------------------------Alteração Dados Adicionais-------------------------------

	Else //Nota fiscal de entrada

		For nCont := 1 to Len (aProd)

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial('SB1')+aProd[nCont,02]))

			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xFilial('SD1') +  cDoc + cSerie + cCliFor + cLoja + aProd[nCont,02] + strzero(aProd[nCont,01],TAMSX3("D1_ITEM")[1])) )

			If SD1->D1_XUNMED == '2'  .AND. !EMPTY(SD1->D1_SEGUM)

				aProd[nCont,08] := SD1->D1_SEGUM
				aProd[nCont,11] := SD1->D1_SEGUM
				aProd[nCont,09]	:= SD1->D1_QTSEGUM
				aProd[nCont,12]	:= SD1->D1_QTSEGUM
				aProd[nCont,16]	:= SD1->D1_TOTAL / SD1->D1_QTSEGUM

			EndIf
		Next nCont

	Endif

Return
