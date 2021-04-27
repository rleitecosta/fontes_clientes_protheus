#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: MyMata010    Ultima Alteração: Carlos H Fernandes      Data: 07/01/2021  
//Descrição: ExecAuto no Pedido - Consulta, Insere, Altera e Exclui Pedido 
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function MyMata010(oProduto,nOpc,cPar01)

Local aVetor        := {}
Local aCab	        := {}
Local cRet          := ''                              
Local wsCOD         := ''  
Local nRege         := 0
Local nErro         := 0
Local lRet          := .T.

Private lMsErroAuto 	:= .F.	       // variável de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsHelpAuto		:= .T.         // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática. 
Private lAutoErrNoFile 	:= .T.	       // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
 
If nOpc == 3	 // Inclusão do Produto Via POST
	
	For nRege := 1 to Len(oProduto:SB1)
		iF TamSX3(Alltrim(oProduto:SB1[nRege]:campo))[3] == "N"
			aAdd( aVetor, {Alltrim(oProduto:SB1[nRege]:campo), Val(oProduto:SB1[nRege]:conteudo), Nil } )
		ElseiF TamSX3(Alltrim(oProduto:SB1[nRege]:campo))[3] == "D"
			aAdd( aVetor, {Alltrim(oProduto:SB1[nRege]:campo), CtoD(oProduto:SB1[nRege]:conteudo), Nil } )
		Else
			aAdd( aVetor, {Alltrim(oProduto:SB1[nRege]:campo), Alltrim(oProduto:SB1[nRege]:conteudo), Nil } )
		Endif
	    
	    If Alltrim(oProduto:SB1[nRege]:campo) == "B1_COD"   	// Guarda CNPJ para Pesquisa futura
	       wsCOD := Alltrim(oProduto:SB1[nRege]:conteudo)
	    Endif    
	Next				
	
	SB1->( DbSetOrder(1) )
    If !(SB1->( DbSeek( xFilial("SB1") + wsCOD ) ))
		aVetor := FWVetByDic( aVetor, "SB1" )   
		MSExecAuto({|x,y| Mata010(x,y)},aVetor,3) 				//3- Inclusão, 4- Alteração, 5- Exclusão  
		
		If lMsErroAuto	
	   		RollBackSX8()      
	   	  //cErro := MostraErro()
	   	  //cErro := TrataErro(cErro)
          //SetRestFault(400, cErro)

			aErrPCAuto	:= GETAUTOGRLOG()	
			cMsgErro	:= ""												

			For nErro := 1 To Len(aErrPCAuto)
				if At("Invalido", aErrPCAuto[nErro]) <> 0  .OR. At("AJUDA", aErrPCAuto[nErro]) <> 0 
				cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nErro]),.T.) + " "
				endif
			Next

			cRet  := FWCutOff('{"Status":"ERRO","Mensagem":"'+ cMsgErro+'"}')

		Else	
			ConfirmSX8()

			//Realiza inclusão do complemento	
			dbSelectArea("SB1")
			dbSetOrder(1)
			SB1->(DbGotop())
			If DbSeek( xFilial("SB1") + wsCOD )

				For nRege := 1 to Len(oProduto:SB5)
					IF Alltrim(oProduto:SB5[nRege]:campo) == "B5_COD"
						aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), wsCOD, Nil } )
					Else
						iF TamSX3(Alltrim(oProduto:SB5[nRege]:campo))[3] == "N"
							aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), Val(oProduto:SB5[nRege]:conteudo), Nil } )
						ElseiF TamSX3(Alltrim(oProduto:SB5[nRege]:campo))[3] == "D"
							aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), CtoD(oProduto:SB5[nRege]:conteudo), Nil } )
						Else
							aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), Alltrim(oProduto:SB5[nRege]:conteudo), Nil } )
						Endif
					Endif
				Next			
				
				//aCab := {   {"B5_COD"  ,wsCOD  ,Nil},;            		// Código identificador do produto            
				//			{"B5_CEME"  ,"Nome cientifico"  ,Nil}}    	// Nome científico do produto
				
				aCab := FWVetByDic( aCab, "SB5" )   
				MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusão 
				
				//-- Retorno de erro na execução da rotina
				If lMsErroAuto    
					aErrPCAuto	:= GETAUTOGRLOG()	
					cMsgErro	:= ""												

					For nErro := 1 To Len(aErrPCAuto)
						if At("Invalido", aErrPCAuto[nErro]) <> 0  .OR. At("AJUDA", aErrPCAuto[nErro]) <> 0 
						cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nErro]),.T.) + " "
						endif
					Next

					cRet  := FWCutOff('{"Status":"ERRO","Mensagem":"'+ cMsgErro+'"}')
					conout("erro ao incluir o complemento do produto")
				Else
					conout("Incluído com sucesso")
				Endif
			
			Else
				lRet := .F.
				cRet := '{"Status":"400","Mensagem":"Não foi localizado produto para inclusão do complemento","Produto":"'+wsCOD+'"}'	
			EndIf
			
			If lRet 
				cRet := '{"Status":"200","Mensagem":"Inclusão de Produto e Complemento efetuado com sucesso!","Produto":"'+Alltrim(SB1->B1_COD)+'"}'
			Endif

		Endif
	Else
   	   RollBackSX8()
       cRet := '{"Status":"400","Mensagem":"Inclusão do produto não efetuada. Produto: '+Alltrim(wsCOD)+ ' já cadastrado!"}'
	Endif
	   
ElseIf nOpc == 4	// Alteração do Produto Via PUT 

	For nRege := 1 to Len(oProduto:SB1)
		iF TamSX3(Alltrim(oProduto:SB1[nRege]:campo))[3] == "N"
			aAdd( aVetor, {Alltrim(oProduto:SB1[nRege]:campo), Val(oProduto:SB1[nRege]:conteudo), Nil } )
		ElseiF TamSX3(Alltrim(oProduto:SB1[nRege]:campo))[3] == "D"
			aAdd( aVetor, {Alltrim(oProduto:SB1[nRege]:campo), CtoD(oProduto:SB1[nRege]:conteudo), Nil } )
		Else
			aAdd( aVetor, {Alltrim(oProduto:SB1[nRege]:campo), Alltrim(oProduto:SB1[nRege]:conteudo), Nil } )
		Endif
	    
	    If Alltrim(oProduto:SB1[nRege]:campo) == "B1_COD"   	// Guarda CNPJ para Pesquisa futura
	       wsCOD := Alltrim(oProduto:SB1[nRege]:conteudo)
	    Endif    
	Next				
	
    SB1->( DbSetOrder(1) )
	SB1->( DbGotop() )
    If SB1->( DbSeek( xFilial("SB1") + PADR(wsCOD,TAMSX3("B1_COD")[1]) ))
		aVetor := FWVetByDic( aVetor, "SB1" )   
		MSExecAuto({|x,y| Mata010(x,y)},aVetor,4) //Alteração
		
		If lMsErroAuto	
			aErrPCAuto	:= GETAUTOGRLOG()	
			cMsgErro	:= ""											
			For nErro := 1 To Len(aErrPCAuto)
				if At("Invalido", aErrPCAuto[nErro]) <> 0  .OR. At("AJUDA", aErrPCAuto[nErro]) <> 0 
				cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nErro]),.T.) + " "
				endif
			Next
			cRet  := FWCutOff('{"Status":"ERRO","Mensagem":"'+ cMsgErro+'"}')
		Else	
			//Realiza alteração do complemento	
			dbSelectArea("SB5")
			dbSetOrder(1)
			SB5->(DbGotop())
			If DbSeek(xFilial("SB5")+PADR(wsCOD,TAMSX3("B5_COD")[1]))

				For nRege := 1 to Len(oProduto:SB5)
					IF Alltrim(oProduto:SB5[nRege]:campo) == "B5_COD"
						aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), wsCOD, Nil } )
					Else
						iF TamSX3(Alltrim(oProduto:SB5[nRege]:campo))[3] == "N"
							aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), Val(oProduto:SB5[nRege]:conteudo), Nil } )
						ElseiF TamSX3(Alltrim(oProduto:SB5[nRege]:campo))[3] == "D"
							aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), CtoD(oProduto:SB5[nRege]:conteudo), Nil } )
						Else
							aAdd( aCab, {Alltrim(oProduto:SB5[nRege]:campo), Alltrim(oProduto:SB5[nRege]:conteudo), Nil } )
						Endif
					Endif
				Next			

				aCab := FWVetByDic( aCab, "SB5" )   
				MSExecAuto({|x,y| Mata180(x,y)},aCab,4) //Alteração 
				
				//-- Retorno de erro na execução da rotina
				If lMsErroAuto    
					aErrPCAuto	:= GETAUTOGRLOG()	
					cMsgErro	:= ""												
					For nErro := 1 To Len(aErrPCAuto)
						if At("Invalido", aErrPCAuto[nErro]) <> 0  .OR. At("AJUDA", aErrPCAuto[nErro]) <> 0 
						cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nErro]),.T.) + " "
						endif
					Next
					cRet  := FWCutOff('{"Status":"ERRO","Mensagem":"'+ cMsgErro+'"}')
					conout("erro ao alterar o complemento do produto")
				Else
					conout("Alterado com sucesso")
				Endif
			
			Else
				lRet := .F.
				cRet := '{"Status":"400","Mensagem":"Não foi localizado produto para alteração do complemento","Produto":"'+wsCOD+'"}'	
			EndIf

			If lRet 
				cRet := '{"Status":"200","Mensagem":"Alteração de Produto e Complemento efetuado com sucesso!","Produto":"'+Alltrim(SB1->B1_COD)+'"}'
			Endif

		Endif	
	Else
       cRet := '{"Status":"400","Mensagem":"Alteração do produto não efetuada. Produto: '+Alltrim(wsCOD)+ ' não cadastrado!"}'
	Endif
	
Endif
	
Return(cRet)    


/*/{Protheus.doc} TrataErro
Trata o erro para devolver no JSON
@author 
@since 
@type function
/*/
Static Function TrataErro(cErroAuto)

  Local nLines   := MLCount(cErroAuto)
  Local cNewErro := ""
  Local nErr	   := 0

  For nErr := 1 To nLines
	  cNewErro += AllTrim( MemoLine( cErroAuto, , nErr ) ) + " - "
  Next nErr

Return(cNewErro)

//-----------------------------------------------------------------------------------------------------------------------------------------------

Static Function MiddleTrim(cText)                              //Função que elimina excesso de espaços em branco em uma string
    While "  " $ cText .OR. "xx" $ cText
        cText = StrTran(cText, "  ", " ")
        cText = StrTran(cText, "xx", " ")
    End
Return AllTrim(cText)
