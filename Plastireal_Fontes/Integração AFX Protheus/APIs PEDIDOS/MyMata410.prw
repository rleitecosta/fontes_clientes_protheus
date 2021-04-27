#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"
#Include 'parmtype.ch'        
#Include "TopConn.Ch"
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: MyMata410    Ultima Altera��o: Ricardo G. de Aguiar      Data: 13/02/2020  
//Descri��o: ExecAuto no Pedido de Venda - Consulta, Insere, Altera e Exclui Pedido
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function MyMata410(oPedidos,nOpc,cPar01)

Local aCabe                := {} 
Local aItem                := {}
Local aItemSC6             := {}
Local cRet                 := ''                              
Local wsNUM                := ''  
Local cErro                := ''
Local cJSON		            := ''
Local nReca                := 0
Local nReit                := 0
Local nResb                := 0
Local nErro                := 0
Local aArea 	            := GetArea()
Local aLinha               := {}
Local nItensP               := 0
Local nItensJ               := 0
Local cTesInt              := ""
Local nPosCli              := 0     //AsCan(_aCabPed,    {|x| AllTrim(x[01]) == "C5_CLIENTE"}) 
Local nPosLj               := 0     //AsCan(_aCabPed,    {|x| AllTrim(x[01]) == "C5_LOJACLI"}) 
Local nPosTes              := 0     //AsCan(_aItPed[01], {|x| AllTrim(x[01]) == "C6_TES"}) 
Local nPosPrd              := 0     //AsCan(_aItPed[01], {|x| AllTrim(x[01]) == "C6_PRODUTO"}) 
Local cCliente             := ""    //_aCabPed[_nPosCli][02]
Local cLjCli               := ""    //_aCabPed[_nPosLj][02]
Local cTpOper              := "01"  //SuperGetMV("MV_LJLPTIV",,"01")
Local cProd                := ""

Private lMsErroAuto 	      := .F.	                                                        // vari�vel de controle interno da rotina automatica que informa se houve erro durante o processamento
Private lMsHelpAuto		   := .T.                                                           // vari�vel que define que o help deve ser gravado no arquivo de log e que as informa��es est�o vindo � partir da rotina autom�tica. 
Private lAutoErrNoFile 	   := .T.	                                                        // for�a a grava��o das informa��es de erro em array para manipula��o da grava��o ao inv�s de gravar direto no arquivo tempor�rio
 
If nOpc == 3	 //--------------------------------------------------------------------------Inclus�o do Pedidos Via POST---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
   cCodSC5 := GetNewCod()                                                                    // Verificar na implanta��o a gera��o automatica do CODIGO DO Pedidos 
   wsNUM   := cCodSC5 
	
   //AAdd( aCabe, {"C5_NUM"    , cCodSC5        , Nil } )                                      // Habilitar para Gera��o automatica GETSX8NUM()
	For nReca := 1 to Len(oPedidos:Cabeca)
	        
        cTip5 := TamSX3(oPedidos:Cabeca[nReca]:campo)[3] 
        If cTip5 == "C" 
           cContecabe := Alltrim(oPedidos:Cabeca[nReca]:conteudo)
        ElseIf cTip5 == "N"
           cContecabe := Val(oPedidos:Cabeca[nReca]:conteudo)
        ElseIf cTip5 == "D"
           cContecabe := SToD(oPedidos:Cabeca[nReca]:conteudo)
        ElseIf cTip5 == "M" 
           cContecabe := Alltrim(oPedidos:Cabeca[nReca]:conteudo)
        Endif               
    
        aAdd( aCabe, { oPedidos:Cabeca[nReca]:campo, cContecabe, Nil } )
	
	Next				

For nReit := 1 to Len(oPedidos:Itens) 
		aItemSC6 := {}
	    For nResb := 1 To Len(oPedidos:Itens[nReit])

          cTip6 := TamSX3(oPedidos:Itens[nReit,nResb]:campo)[3] 
          If Alltrim(oPedidos:Itens[nReit,nResb]:campo) <> ("C6_NUM") 
            IF Alltrim(oPedidos:Itens[nReit,nResb]:campo) == ("C6_TES")
             
              nPosCli  := AsCan(aCabe,        {|x| AllTrim(x[01]) == "C5_CLIENTE"}) 
              nPosLj   := AsCan(aCabe,        {|x| AllTrim(x[01]) == "C5_LOJACLI"}) 
              nPosPrd  := AsCan(aItemSC6, {|x| AllTrim(x[01]) == "C6_PRODUTO"}) 
              cCliente := aCabe[nPosCli][02]
              cLjCli   := aCabe[nPosLj][02]
              cProd    := aItemSC6[nPosPrd][02]  
                          
              cTesInt := MaTESInt( 2, cTpOper, cCliente, cLjCli,"C", cProd)
             
              If !Empty(cTesInt)               
                aAdd( aItemSC6, { oPedidos:Itens[nReit,nResb]:campo , cTesInt, Nil } )
              Else
                cConteudo := Alltrim(oPedidos:Itens[nReit,nResb]:conteudo)
                aAdd( aItemSC6, { oPedidos:Itens[nReit,nResb]:campo , cConteudo , Nil } )
              Endif
               
            Else
               If cTip6 == "C"  
                  cConteudo := Alltrim(oPedidos:Itens[nReit,nResb]:conteudo)
               ElseIf cTip6 == "N"
                  cConteudo := Val(oPedidos:Itens[nReit,nResb]:conteudo)
               ElseIf cTip6 == "D"
                  cConteudo := cTod(oPedidos:Itens[nReit,nResb]:conteudo)
               ElseIf cTip6 == "M" 
                  cConteudo := Alltrim(oPedidos:Itens[nReit,nResb]:conteudo)
               Endif  
                           
               aAdd( aItemSC6, { oPedidos:Itens[nReit,nResb]:campo , cConteudo , Nil } )
            EndIf
         Endif
	      
	    Next
	     Aadd(aItem,aItemSC6) 
	Next				
					
	
	SC5->( DbSetOrder(1) )

   If !(SC5->( DbSeek( xFilial("SC5") + cCodSC5 ) )) 
        
	   //   aAdd(aItem, aItemSC6)
	   MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabe,aItem,3)                                            //3- Inclus�o
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

         cRet  := FWCutOff('{"Status":"400","Mensagem":"'+ cMsgErro+'"}')

	   Else	
		  ConfirmSX8()
	      cRet := '{"Status":"200","Mensagem":"Inclus�o do pedido efetuada com sucesso! Pedido numero: '+ SC5->C5_NUM +'"}'
	   Endif
	
	Else
   	
   	   RollBackSX8()
       cRet := '{"Status":"400","Mensagem":"Inclus�o do pedido n�o efetuada. Pedido ' +cCodSC5+ ' j� cadastrado!"}'
	
	Endif
	   
ElseIf nOpc == 4	//--------------------------------------------------------------------------Altera��o do Pedidos Via PUT---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
   For nReca := 1 to Len(oPedidos:Cabeca)
		//If !Alltrim(oPedidos:Cabeca[nReca]:campo) $ ("C5_NUM")

         cTip5 := TamSX3(oPedidos:Cabeca[nReca]:campo)[3] 
         If cTip5 == "C" 
            cContecabe := Alltrim(oPedidos:Cabeca[nReca]:conteudo)
         ElseIf cTip5 == "N"
            cContecabe := Val(oPedidos:Cabeca[nReca]:conteudo)
         ElseIf cTip5 == "D"
            cContecabe := cTod(oPedidos:Cabeca[nReca]:conteudo)
         Endif               

         aAdd( aCabe, {Alltrim(oPedidos:Cabeca[nReca]:campo), cContecabe, Nil } )

	   //Endif
      
      If Alltrim(oPedidos:Cabeca[nReca]:campo) == "C5_NUM"
         wsNUM := Alltrim(oPedidos:Cabeca[nReca]:conteudo)
      Endif  

	Next				
    
   cQuery := " SELECT MAX(C6_ITEM) MAIOR FROM "+ retsqlname("SC6") +" SC6 "+CRLF
	cQuery += " Where SC6.D_E_L_E_T_ = ' ' AND C6_NUM = '"+ wsNUM +"'"
	
	TcQuery cQuery New Alias "TSC6" 
	dbSelectArea("TSC6")
   ("TSC6")->(dbGoTop())
   
   nItensP := Val(("TSC6")->(MAIOR))
   nItensJ := Len(oPedidos:Itens)  

   For nReit := 1 to Len(oPedidos:Itens) 
      aLinha := {} 
      For nResb := 1 To Len(oPedidos:Itens[nReit])
         cTip6 := TamSX3(oPedidos:Itens[nReit,nResb]:campo)[3] 
         If Alltrim(oPedidos:Itens[nReit,nResb]:campo) <> ("C6_NUM") .Or. Alltrim(oPedidos:Itens[nReit,nResb]:campo) <> ("C6_ITEM")  
            
            If cTip6 == "C"  
               cConteudo := Alltrim(oPedidos:Itens[nReit,nResb]:conteudo)
            ElseIf cTip6 == "N"
               cConteudo := Val(oPedidos:Itens[nReit,nResb]:conteudo)
            ElseIf cTip6 == "D"
               cConteudo := cTod(oPedidos:Itens[nReit,nResb]:conteudo)
            Endif  
            
            If Alltrim(oPedidos:Itens[nReit,nResb]:campo) == ("C6_ITEM")
               
               aAdd( aLinha, { "LINPOS"    , "C6_ITEM"      , oPedidos:Itens[nReit,nResb]:conteudo } )
               aAdd( aLinha, { "AUTODELETA", "N"            , Nil } )
               
            Else
               aAdd( aLinha, {Alltrim(oPedidos:Itens[nReit,nResb]:campo), cConteudo , Nil } )      //aItemSC6
            EndIf

         Endif
      Next
      aAdd( aItemSC6, aLinha )
   Next

   dbSelectArea("SC5")
   SC5->( DbSetOrder(1) )
   If (SC5->( DbSeek( xFilial("SC5") + wsNUM ) )) .AND. nItensP == nItensJ                         // pedido encontrado e quantidade de itens da tabela igual do JSON
      aItem := aClone(aItemSC6)  
      MSExecAuto({|x,y,z,w|Mata410(x,y,z,w)},aCabe,aItem,4,.F.)                                    //4- Altera��o
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
         cRet := '{"Status":"200","Mensagem":"Alterac�o efetuada com sucesso! Pedido n�mero: '+ SC5->C5_NUM +'"}'
      Endif
   Else
      
      If !(SC5->( DbSeek( xFilial("SC5") + wsNUM ) ))
         cRet := '{"Status":"400","Mensagem":"Alterac�o n�o efetuada. Pedido n�mero: ' +wsNUM+ ' n�o cadastrado!"}' 
      Else
         cRet := '{"Status":"400","Mensagem":"A quantidade de itens do JSON � diferente da quantidade de itens do pedido. Esta API s� permite altera��o nos itens existentes no pedido. Para inclus�o ou exclus�o de itens do pedido, acesse o protheus!"}'
      EndIf

   Endif
   
ElseIf nOpc == 5     //-------------------------------------------------------------------------- Exclus�o de Pedidos Via DELETE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     

   SC5->( DbSetOrder(1) )
   If (SC5->( DbSeek( xFilial("SC5") + cPar01 )))

      aCabe := {	{"C5_NUM" 		, SC5->C5_NUM	   ,Nil},;                                      // Numero do pedido
                  {"C5_TIPO"   	, "N"             ,Nil},;                                      // Tipo de pedido
                  {"C5_CLIENTE"	, SC5->C5_CLIENTE ,Nil},;                                      // Codigo do cliente
                  {"C5_LOJAENT"	, SC5->C5_LOJAENT	,Nil},;                                      // Loja do cliente
                  {"C5_LOJACLI"	, SC5->C5_LOJACLI	,Nil},;                                      // Loja do cliente
                  {"C5_TIPOCLI"	, SC5->C5_TIPOCLI ,Nil},;                                      // Codigo da condicao de pagamanto - SE4
                  {"C5_CONDPAG"	, SC5->C5_CONDPAG ,Nil},;                                      // Codigo da condicao de pagamanto - SE4
                  {"C5_EMISSAO"	, SC5->C5_EMISSAO ,Nil},;                                      // Data de emissao
                  {"C5_NATUREZ"	, SC5->C5_NATUREZ ,Nil}}                                       // Data de emissao

      dbSelectArea("SC6")
      DbSeek( xFilial("SC5") + cPar01 )
      
      Do While !Eof() .Or. SC6->C6_NUM == cPar01
         aItemSC6 := { {"C6_ITEM"    , SC6->C6_ITEM     , Nil},;
                     {"C6_NUM" 	  , SC6->C6_NUM 	   , Nil},;
                     {"C6_CLI"     , SC6->C6_CLI      , Nil},; 	                              // Cliente
                     {"C6_LOJA"    , SC6->C6_LOJA	   , Nil},; 	                              // Loja do Cliente
                     {"C6_PRODUTO" , SC6->C6_PRODUTO  , Nil},; 
                     {"C6_DESCRI"  , SB1->B1_DESC     , Nil},; 
                     {"C6_UM"      , SB1->B1_UM       , Nil},; 
                     {"C6_QTDVEN"  , SC6->C6_QTDVEN   , Nil},;
                     {"C6_PRCVEN"  , SC6->C6_PRCVEN   , Nil}}
         DbSkip()
      Enddo  
      
      Aadd(aItem,aClone(aItemSC6))
	   MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabe,aItem,5)                                            // 5- Exclus�o	

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
	      cRet := '{"Status":"200","Mensagem":"Exclus�o efetuada com sucesso! Pedido n�mero: '+ SC5->C5_NUM +'"}'
	   Endif

   Else
      cRet := '{"Status":"400","Mensagem":"Exclus�o n�o efetuada. Pedido de n�mero: ' +cPar01+ ' n�o cadastrado!"}'
	Endif
Endif
	
Return(cRet)    

//-------------------------------------------------------------------------------------------------------------------------------------------------

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

/*/{Protheus.doc} GetNewCod                                    Fun��o que retorna o pr�ximo c�digo de SC5
Retorna o pr�ximo c�digo livre do SC5
@author 
@since 
@type function
/*/
Static Function GetNewCod()

  Local cCod  := GetSX8Num("SC5", "C5_NUM")
  Local aArea := GetArea()

  SC5->( DbSetOrder(1) )
  Do While SC5->( DbSeek( xFilial("SC5") + cCod ) )
	 cCod := GetSX8Num("SC5", "C5_NUM")
  EndDo
  RestArea(aArea)

Return(cCod)  

//-----------------------------------------------------------------------------------------------------------------------------------------------

Static Function MiddleTrim(cText)                              //Fun��o que elimina excesso de espa�os em branco em uma string
    While "  " $ cText .OR. "xx" $ cText
        cText = StrTran(cText, "  ", " ")
        cText = StrTran(cText, "xx", " ")
    End
Return AllTrim(cText)
