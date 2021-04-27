#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*-------------------------------------------------------------------------------------------------
{Protheus.doc} GERDANFE
Rotina responsavel em transmitir e imprimir as notas no Sefaz direto do pedido de Vendas. 
Esse fonte � chamado pelo PE - M460FIM()
@author  M�rio A. Cavenaghi - EthosX
@since   14/09/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------*/
Static _cPasta := ""
Static _nOpcao := 0	//	0-Pergunta, 1-Sim, 2-N�o
Static _cIdent := RetIdEnti()


/*-----------------------------------------------------------------------------------------------*/
User Function GERDANFE()


	Local nItem      := 0
	Local cNomeDanfe := ""
	Local lEnd       := .F.
	Local oDanfe     := Nil

   //Vari�veis obrigat�rias na DANFE (pode colocar outras abaixo)
   Private oRetNF   := Nil
   Private nConsNeg := 0.4
   Private nConsTex := 0.5
   Private PixelX   := 0
   Private PixelY   := 0
   Private nColAux  := 0
   Private nMaxItem := 49	//	 M�ximo de produtos para a pagina 2 em diante, se necess�rio usar um par�metro 


	
	If _nOpcao == 0
		If MsgYesNo("Deseja imprimir a(s) DANFE(s) ap�s a transmiss�o?")
			_cPasta := cGetFile("*.PDF", "Onde salvar DANFE(s)", 1, "", .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),, .T.)
			If Empty(_cPasta)
				_cPasta := GetTempPath()
			Endif
			Alert('Todas as DANFEs ser�o salvas em "' + _cPasta + '"')
			_nOpcao := 1
		Else
			_nOpcao := 2
		Endif
	EndIF
	AutoNfeEnv(cEmpAnt, SF2->F2_FILIAL, "0", "1", SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_DOC)	//	Transmite a DANFE
	If _nOpcao == 1
		For nItem := 1 To 3
			Inkey(1)
			If !Empty(SF3->F3_CHVNFE)
				lEnd := .T.
				Exit
			Endif
		Next
		If lEnd
			lEnd := .F.
			cNomeDanfe := "DANFE_" + Alltrim(SF2->F2_DOC) + "_" + Alltrim(SF2->F2_SERIE) + "_" + Dtos(MSDate()) + "_" + StrTran(Time(), ":", "")

			//Define as perguntas da DANFE
			Pergunte("NFSIGW", .F.)
			MV_PAR01 := SF2->F2_DOC     //	Nota Inicial
			MV_PAR02 := SF2->F2_DOC     //	Nota Final
			MV_PAR03 := SF2->F2_SERIE   //	S�rie da Nota
			MV_PAR04 := 2               //	NF de Saida
			MV_PAR05 := 2               //	Frente e Verso = N�o
			MV_PAR06 := 2               //	DANFE simplificado = N�o
			MV_PAR07 := dDataBase	    //	Data de 
			MV_PAR08 := dDataBase	    //	Data at� 

			//Cria a Danfe
			oDanfe := FWMSPrinter():New(cNomeDanfe, IMP_PDF, .F.,, .T.)

			//Propriedades da DANFE
			oDanfe:SetResolution(78)
			oDanfe:SetPortrait()
			oDanfe:SetPaperSize(DMPAPER_A4)
			oDanfe:SetMargin(60, 60, 60, 60)

			//For�a a impress�o em PDF
			oDanfe:cPathPDF := _cPasta                
			oDanfe:nDevice  := 6
			oDanfe:lServer  := .F.
			oDanfe:lViewPDF := .F.

			//Chamando a impress�o da danfe no RDMAKE
			PixelX := oDanfe:nLogPixelX()
			PixelY := oDanfe:nLogPixelY()
			RptStatus({| lEnd| StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, _cIdent,,, .F.)}, "Imprimindo Danfe...")
			oDanfe:Print()
			

            
		Else
			Alert("O SEFAZ ainda n�o autorizou a nota " + SF2->F2_DOC + "." + SF2->F2_SERIE + Chr(13) + "Favor verificar e imprimir mais tarde!")
		Endif
	Endif
	
Return