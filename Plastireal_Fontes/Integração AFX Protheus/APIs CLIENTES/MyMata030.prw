#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: MyMata030    Ultima Alteração: Ricardo G. de Aguiar      Data: 13/02/2020  
//Descrição: ExecAuto no Cliente - Consulta, Insere, Altera e Exclui cliente 
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function MyMata030(oCliente,nOpc,cValCNPJ)

Local aVetor        := {}
Local cRet          := ''                              
Local wsCGC         := ''  
//Local cErro         := ''
//Local cJSON		    := ''
Local nRege         := 0
Local nErro         := 0
//Local aArea 	    := GetArea()
//Local cNextAlias    := GetNextAlias()	

//local oObj //teste

Private lMsErroAuto 	:= .F.	       // variável de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsHelpAuto		:= .T.         // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática. 
Private lAutoErrNoFile 	:= .T.	       // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
 
If nOpc == 3	 // Inclusão do Cliente Via POST
	
	//cCodSA1 := GetNewCod()                             		// Verificar na implantação a geração automatica do CODIGO DO CLIENTE 
	//AAdd( aVetor, {"A1_COD"    , cCodSA1        , Nil } )   	// Habilitar de codigo for gerado automaticamento GetSX8Num
    //AAdd( aVetor, {"A1_LOJA"   , '01'           , Nil } )
	
	For nRege := 1 to Len(oCliente:Cabeca)
		//If !Alltrim(oCliente:Object[nRege]:campo) $ ("A1_COD/A1_LOJA")
           iF TamSX3(Alltrim(oCliente:Cabeca[nRege]:campo))[3] == "N"
		   		aAdd( aVetor, {Alltrim(oCliente:Cabeca[nRege]:campo), Val(oCliente:Cabeca[nRege]:conteudo), Nil } )
		   ElseiF TamSX3(Alltrim(oCliente:Cabeca[nRege]:campo))[3] == "D"
		   		aAdd( aVetor, {Alltrim(oCliente:Cabeca[nRege]:campo), CtoD(oCliente:Cabeca[nRege]:conteudo), Nil } )
			Else
		   		aAdd( aVetor, {Alltrim(oCliente:Cabeca[nRege]:campo), Alltrim(oCliente:Cabeca[nRege]:conteudo), Nil } )
			Endif
	    //Endif
	    If Alltrim(oCliente:Cabeca[nRege]:campo) == "A1_CGC"   	// Guarda CNPJ para Pesquisa futura
	       wsCGC := Alltrim(oCliente:Cabeca[nRege]:conteudo)
	    Endif    
	Next				
	
	SA1->( DbSetOrder(3) )
    If !(SA1->( DbSeek( xFilial("SA1") + wsCGC ) ))
		aVetor := FWVetByDic( aVetor, "SA1" )   
		MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) 				//3- Inclusão, 4- Alteração, 5- Exclusão  
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
			cRet := '{"Status":"200","Mensagem":"Inclusão do cliente efetuada com sucesso!","CNPJ/CGC":"'+SA1->A1_CGC+'"}'
		Endif
	Else
   	   RollBackSX8()
       cRet := '{"Status":"400","Mensagem":"Inclusão do cliente não efetuada. CNPJ: '+wsCGC+ ' já cadastrado!"}'
	Endif
	   
ElseIf nOpc == 4	// Alteração do Cliente Via PUT 

	For nRege := 1 to Len(oCliente:Cabeca)
		If !Alltrim(oCliente:Cabeca[nRege]:campo) $ ("A1_COD/A1_LOJA")
		   aAdd( aVetor,{ oCliente:Cabeca[nRege]:campo, oCliente:Cabeca[nRege]:conteudo, Nil } )
	    Endif
	    If Alltrim(oCliente:Cabeca[nRege]:campo) == "A1_CGC"    // Guarda CNPJ para pesquisa futura
	       wsCGC := Alltrim(oCliente:Cabeca[nRege]:conteudo)
	    Endif    
	Next				
	
    SA1->( DbSetOrder(3) )
    If (SA1->( DbSeek( xFilial("SA1") + wsCGC ) ))
	    aAdd( aVetor,{ "A1_COD", SA1->A1_COD, Nil } )
		aAdd( aVetor,{ "A1_LOJA", SA1->A1_LOJA, Nil } )
		MSExecAuto({|x,y| Mata030(x,y)},aVetor,4) //3- Inclusão, 4- Alteração, 5- Exclusão  
	
	    If lMsErroAuto	
	   	   //cErro := MostraErro()
	   	   //cErro := TrataErro(cErro)
           //SetRestFault(400, cErro)
           //cRet  := cErro
		   aErrPCAuto	:= GETAUTOGRLOG()	
		    cMsgErro	:= ""												

            For nErro := 1 To Len(aErrPCAuto)
				if At("Invalido", aErrPCAuto[nErro]) <> 0  .OR. At("AJUDA", aErrPCAuto[nErro]) <> 0 
				cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nErro]),.T.) + " "
				endif
			Next

			cRet  := FWCutOff('{"Status":"ERRO","Mensagem":"'+ cMsgErro+'"}')
	    Else	
	       cRet := '{"Status":"200","Mensagem":"Alteração efetuada com sucesso! CNPJ/CGC numero: '+ SA1->A1_CGC +'"}' 
	    Endif
    Else
        cRet := '{"Status":"400","Mensagem":"Alteração não efetuada. CNPJ/CGC: ' +wsCGC+ ' não cadastrado !!!"}'
	Endif
 
ElseIf nOpc == 5     // Exclusão de Cliente Via DELETE

    SA1->( DbSetOrder(3) )
    If (SA1->( DbSeek( xFilial("SA1") + cValCNPJ ) ))
        AAdd( aVetor, { "A1_COD"    , SA1->A1_COD    , Nil } )
        AAdd( aVetor, { "A1_LOJA"   , SA1->A1_LOJA   , Nil } )
        AAdd( aVetor, { "A1_NOME"   , SA1->A1_NOME   , Nil } )
        AAdd( aVetor, { "A1_CGC"    , SA1->A1_CGC    , Nil } )
        AAdd( aVetor, { "A1_END"    , SA1->A1_END    , Nil } )
        AAdd( aVetor, { "A1_BAIRRO" , SA1->A1_BAIRRO , Nil } )
        AAdd( aVetor, { "A1_MUN"    , SA1->A1_MUN    , Nil } )
        AAdd( aVetor, { "A1_NATUREZ", SA1->A1_NATUREZ, Nil } )
        AAdd( aVetor, { "A1_COMPLEM", SA1->A1_COMPLEM, Nil } )
        AAdd( aVetor, { "A1_TIPO"   , SA1->A1_TIPO   , Nil } )
                
	    MSExecAuto({|x,y| Mata030(x,y)},aVetor,5) //3- Inclusão, 4- Alteração, 5- Exclusão  

	    If lMsErroAuto	
	   	   //cErro := MostraErro()
	   	   //cErro := TrataErro(cErro)
           //SetRestFault(400, cErro)
           //cRet  := cErro
		   aErrPCAuto	:= GETAUTOGRLOG()	
		    cMsgErro	:= ""												

            For nErro := 1 To Len(aErrPCAuto)
				if At("Invalido", aErrPCAuto[nErro]) <> 0  .OR. At("AJUDA", aErrPCAuto[nErro]) <> 0 
				cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nErro]),.T.) + " "
				endif
			Next

			cRet  := FWCutOff('{"Status":"400","Mensagem":"'+ cMsgErro+'"}')

	    Else	
           cRet := '{"Status":"200","Mensagem":"Exclusão do CNPJ/CGC: ' +cValCNPJ+ ' efetuada com sucesso! "}'
	    Endif     
    Else
        cRet := '{"Status":"400","Mensagem":"Exclusão não efetuada. CNPJ/CGC: ' +cValCNPJ+ ' não cadastrado!"}'
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



/*/{Protheus.doc} GetNewCod
Retorna o próximo código livre do SA1
@author 
@since 
@type function
/*/
Static Function GetNewCod()

  Local cCod  := GetSX8Num("SA1", "A1_COD")
  Local aArea := GetArea()

  SA1->( DbSetOrder(1) )
  Do While SA1->( DbSeek( xFilial("SA1") + cCod ) )
	 cCod := GetSX8Num("SA1", "A1_COD")
  EndDo
  RestArea(aArea)

Return(cCod)  

//-----------------------------------------------------------------------------------------------------------------------------------------------

Static Function MiddleTrim(cText)                              //Função que elimina excesso de espaços em branco em uma string
    While "  " $ cText .OR. "xx" $ cText
        cText = StrTran(cText, "  ", " ")
        cText = StrTran(cText, "xx", " ")
    End
Return AllTrim(cText)