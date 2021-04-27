
#Include "PROTHEUS.Ch"
#Include "topconn.ch"
#INCLUDE "TBICONN.CH"

User Function FSSERASA()
    Private cPerg		:= "FSSERASA"
	
	ValidPerg(cPerg)

	if pergunte(cPerg,.T.)
		Processa( { || FSPROCESS() }, 'Carregando...', 'Aguarde...')
    EndIf

Return

//------------------------------------------------------------------------------------------------

Static function FSPROCESS()
	local cFile 	:= mv_par01
	Local cNewFile 	:= mv_par02
	local cquery 	:= ""
	local cAliasTMP := GetNextAlias()
	Local nH 		:= 0
	Local nNumTit 	:= 0
	Local cValor 	:= ""
	Local cDtEmis	:= ""
	Local cDtVenc	:= ""
	Local cDetalhe	:= ""
	Local cDtPag	:= ""
	Local nLinhas 	:= 0

	if (right(alltrim(cFile),4) != ".txt") .or. (right(alltrim(cNewFile),4) != ".txt")	// verifica se o final do caminho temina com ".txt"
		msgInfo("O tamanho m�ximo do caminho do diret�rio � 99 caracteres! Verifique se seu caminho excedeu esse limite.")
		return
	endif

	nH := fCreate(cNewFile)				//Cria novo arquivo
	If nH == -1
   		MsgStop("Falha ao criar arquivo: "+cNewFile+" - erro "+str(ferror()))
   		Return
	Endif

	if FT_FUse(alltrim(cFile)) == -1	// Abre o arquivo
		msgInfo("N�o foi poss�vel abrir o arquivo: "+cFile,"Abertura do Arquivo")
		return
	endif

	nLinhas 	:= FT_FLastRec()		// Retorna o n�mero de linhas do arquivo
	FT_FGOTOP()							// Posiciona no in�cio da arquivo (1a linha)
	ProcRegua(nLinhas)					// Seta barra de processamento com n�mero de linhas

	While !FT_FEof() 
	
		IncProc()						// Incrementa barra de processamento
		cMemo := FT_FReadln()
		
		If SubStr(cMemo,0,2) == '00' 	//Cabe�alho
			//---------------------------------------------------------------------------------------------------------------------------------
			//                                          Detalhes Cabecalho
			//
			// posição 1 a 2        2 caracteres    Identificação do Registro (constante = 01)
			// posição 3 a 16      14 caracteres    CNPJ empresa cliente 
			// posição 17 a 18      2 caracteres    Tipo de dados (constante = 05)
			// posição 18 a 28     10 caracteres    Número do título
			// posição 29 a 36      8 caracteres    Data de Emissão AAAAMMDD
			// posição 37 a 49     13 caracteres    Valor do título zeros a esquerda e duas casas decimais 127,35 = 0000000012735. Formatar com 9999999999999 para excluir título
			// posição 50 a 57      8 caracteres    Data de vencimento do título AAAAMMDD
			// posição 58 a 65      8 caracteres    Data de pagamento do título AAAAMMDD ou brancos se não pago
			// posição 66 a 99     34 caracteres    Número do título com mais de 10 posições ou brancos
			//                     15 caracteres    Zeros
			//                      5 caracteres    Espaços
			//                      2 caracteres    "SC"
			//---------------------------------------------------------------------------------------------------------------------------------
	
			cCabec :=  cMemo
			// Escreve o texto mais a quebra de linha CRLF
			fWrite(nH,cCabec + chr(13)+chr(10) )
			FT_FSkip()
			loop
 		ElseIf SubStr(cMemo,0,2) == '01' // Detalhes
			
			nNumTit += 1
			cTitParce := SubStr(cMemo,19,10)
			cTitulo := STRZERO(VAL(SubStr(cMemo,19,8)),9,0)
			
			cParcela := SubStr(cMemo,28,1)
			cCGC := SubStr(cMemo,3,14)
			
			DBSELECTAREA("SA1")
			SA1->(DbSetOrder(3))
			iF SA1->(DBSEEK(xFilial()+cCGC))
				cCliente 	:= SA1->A1_COD
				cLoja 		:= SA1->A1_LOJA
			EndIF
			
			cQuery := " SELECT * "
			cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
			cQuery += " WHERE SE1.E1_NUM = '" + cTitulo + "' "
			cQuery += " AND SE1.E1_PARCELA = '" + cParcela + "'"
			cQuery += " AND SE1.E1_CLIENTE = '" + cCliente  + "'"
			cQuery += " AND SE1.E1_LOJA = '" + cLoja +"'"
			cQuery += " AND SE1.D_E_L_E_T_ = '' "
			cQuery += " ORDER BY E1_NUM "
			
			dbUseArea( .T. , 'TOPCONN' , TcGenQry(,,cQuery) , cAliasTMP , .T. , .F. )
			dbSelectArea(cAliasTMP)	
            
			If Empty((cAliasTMP)->E1_NUM) 
				(cAliasTMP)->(dbclosearea())
				
				cAliasTMP := GetNextAlias()

				cQuery := " SELECT * "
				cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
				cQuery += " WHERE SE1.E1_NUM = '" + cTitulo + "' "
				cQuery += " AND SE1.E1_CLIENTE = '" + cCliente  + "'"
				cQuery += " AND SE1.E1_LOJA = '" + cLoja +"'"
				cQuery += " AND SE1.D_E_L_E_T_ = '' "
				cQuery += " ORDER BY E1_NUM "

				dbUseArea( .T. , 'TOPCONN' , TcGenQry(,,cQuery) , cAliasTMP , .T. , .F. )
				dbSelectArea(cAliasTMP)	
			EndIF


			If Empty((cAliasTMP)->E1_NUM) 
				//---------------------------------------------------------------------------------------------------------------------------------
				//                                          Detalhes Titulo
				//
				// posição 1 a 2        2 caracteres    Identificação do Registro (constante = 01)
				// posição 3 a 16      14 caracteres    CNPJ empresa cliente 
				// posição 17 a 18      2 caracteres    Tipo de dados (constante = 05)
				// posição 18 a 28     10 caracteres    Número do título
				// posição 29 a 36      8 caracteres    Data de Emissão AAAAMMDD
				// posição 37 a 49     13 caracteres    Valor do título zeros a esquerda e duas casas decimais 127,35 = 0000000012735. Formatar com 9999999999999 para excluir título
				// posição 50 a 57      8 caracteres    Data de vencimento do título AAAAMMDD
				// posição 58 a 65      8 caracteres    Data de pagamento do título AAAAMMDD ou brancos se não pago
				// posição 66 a 99     34 caracteres    Número do título com mais de 10 posições ou brancos
				//                     15 caracteres    Zeros
				//                      5 caracteres    Espaços
				//                      2 caracteres    "SC"
				//---------------------------------------------------------------------------------------------------------------------------------

				cValor      := SubStr(cMemo,37,13)    //Transforna valor em char de tamanho 13 e zeros a esquerda
				cDtEmis     := SubStr(cMemo,29,8)       //Tranforma data em string formato AAAAMMDD                                 
				cDtVenc     := SubStr(cMemo,50,8)    //Tranforma data em string formato AAAAMMDD   

				cDtPag		   := space(8)                  // Se não existir pagamento espaços

				cDetalhe    := "01" +   cCGC   + "05" + cTitParce + cDtEmis + cValor + cDtVenc + cDtPag +       space(35)       + SubStr(cMemo,101,30) //+ CRLF
				fWrite(nH,cDetalhe + chr(13)+chr(10) )
				(cAliasTMP)->(dbclosearea())
			Else


				cValor      := SubStr(cMemo,37,13)   		//Transforna valor em char de tamanho 13 e zeros a esquerda
				cDtEmis     := SubStr(cMemo,29,8)         	//Tranforma data em string formato AAAAMMDD                                 
				cDtVenc     := SubStr(cMemo,50,8)         	//Tranforma data em string formato AAAAMMDD   

				if EMPTY((cAliasTMP)->E1_BAIXA)                                             
				    cDtPag		   := space(8)          	// Se n�o existir pagamento espa�os
				else
				    cDtPag 		   := Alltrim((cAliasTMP)->E1_BAIXA)     // Se existir pagamento converter para AAAAMMDD
				endif

				cDetalhe    := "01" +   cCGC   + "05" + cTitParce + cDtEmis + cValor + cDtVenc + cDtPag +       space(35)       + SubStr(cMemo,101,30) //+ CRLF
				fWrite(nH,cDetalhe + chr(13)+chr(10) )
				(cAliasTMP)->(dbclosearea())

			EndIF

		ElseIf SubStr(cMemo,0,2) == '99' // Detalhes
			//---------------------------------------------------------------------------------------------------------------------------------
			//                                          Trailer
			//
			// posi��o 1 a 2        2 caracteres    Identifica��o (constante = 99)
			// posi��o 3 a 13       11 caracteres   Para remessa de concilia��o formatar com zeros
			// posi��o 14 a 57      44 caracteres   No manual diz brancos, mas no arquivo que obtemos está com zeros. Coloquei zeros
			// posi��o 58 a 68      11 caracteres   Quantidade de registros com zeros a esquerda 
			// posi��o 69 a 79      11 caracteres   No manual reservado, mas no arquivo que obtemos está com zeros. Coloquei zeros
			// posi��o 80 a 90      11 caracteres   No manual reservado, mas no arquivo que obtemos está com zeros. Coloquei zeros
			// posi��o 91 a 100     10 caracteres   No manual reservado, mas no arquivo que obtemos não tem mais nada. Não coloquei nada
			// posi��o 101 a 130    30 caracteres   No manual está brancos. Não coloquei nada
			//---------------------------------------------------------------------------------------------------------------------------------

			cTrailer := "99"+strZero(0,11)+strZero(0,44)+strZero(nNumTit,11)+strZero(0,11)+strZero(0,11) 
			fWrite(nH,cTrailer )
			FCLOSE(nH)

		EndIF
		FT_FSkip()
		
	Enddo
	fClose(nH)
	Msginfo("Arquivo criado :" + cNewFile)
Return

//------------------------------------------------------------------------------------------------

Static Function ValidPerg(cPerg)

	DbSelectArea("SX1")
	DbSetOrder(1)

	_aRegs :={}

	//Aadd(aRegs,{cPerg,"06","Usuario:              ",""                     ,                     "","mv_ch6","C",15,0,0,"G","","mv_par06",""         ,""          ,""          ,""          ,""     ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(_aRegs,{cPerg,'01',"Arq. Retorno" ,"" ,"" ,'mv_ch1','C',99,0,0,'G','','mv_par01',''         ,''          ,''          ,''          ,""     ,"","","","","","","","","","","","","","","","","","","","DIR" ,"","","","",""})
	aAdd(_aRegs,{cPerg,'02',"Novo Arq."    ,"" ,"" ,'mv_ch2','C',99,0,0,'G','','mv_par02',''         ,''          ,''          ,''          ,""     ,"","","","","","","","","","","","","","","","","","","","DIR2","","","","",""})
	AjuSx1(cPerg,_aRegs)

Return()

//------------------------------------------------------------------------------------------------

static Function AjuSx1(cPerg,aRegs)

	Local _nTamX1, _nTamPe, _nTamDf := 0
	Local i, j
	
	DbSelectArea("SX1")
	DbSetOrder(1)

	// Indo ao Primeiro Registro do SX1, apenas para descobrir o tamanho do campo com o nome da PERGUNTA
	// Campo chamado X1_GRUPO
	DbGoTop()
	_nTamX1	:= Len(SX1->X1_GRUPO)
	_nTamPe	:= Len(Alltrim(cPerg))
	_nTamDf	:= _nTamX1 - _nTamPe

	// Adequando o Tamanho para Efetuar a Pesquisa no SX1
	If _nTamDf > 0
		cPerg := cPerg + Space(_nTamDf)
	ElseIf _nTamDf == 0
		cPerg := cPerg
	Else
		Return()
	EndIf

	// Criando Perguntas caso NAO existam no SX1
	For i:=1 to Len(aRegs)

		If !DbSeek(cPerg+aRegs[i,2])

			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])

			Next
			MsUnlock()

				FWOpenXB4()
				RecLock("XB4",.T.)
				IF i == 1
					XB4->XB4_CODIGO := "P.FSSERASA01."
					XB4->XB4_HELP := "Informe o arquivo de entrada enviado pela Serasa."
				Else
					XB4->XB4_CODIGO := "P.FSSERASA02."	
					XB4->XB4_HELP := "Informe o caminho e o nome do arquivo do arquivo a ser gerado."
				EndIF
				XB4->XB4_TIPO := "P"
				XB4_HLP40 := "S"
				XB4->XB4_IDIOMA := "pt-br"
				XB4->(MsUnlock())

			DbCommit()
		Endif
	Next

Return()