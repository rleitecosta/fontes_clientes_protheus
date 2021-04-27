#INCLUDE "TOTVS.CH"

/*
-------------------------------------------------------------------------------------------------
{Protheus.doc} SF1140I
Ponto de Entrada após a gravação da Pré Nota
Na integração com WEB, irá limpar alguns campos para força a classificação
@author  Mário A. Cavenaghi - EthosX
@since   06/10/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------
*/
User Function SF1140I()

	Local nRecSD1 := SD1->(Recno())
	Local cDocSF1 := SF1->(xFilial() + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

	If IsInCallStack("MT140AUTO")
		SF1->(RecLock("SF1"))
		SF1->F1_STATUS := " "
		SF1->(msUnLock())
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial() + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
		While ! SD1->(Eof()) .And. SD1->(xFilial() + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == cDocSF1
			SD1->(RecLock("SD1"))
			SD1->D1_TESACLA := " "
			SD1->D1_TES     := " "
			SD1->D1_CF      := " "
			SD1->(msUnLock())
			SD1->(dbSkip())
		EndDo
		SD1->(dbGoto(nRecSD1))
	Endif

Return
