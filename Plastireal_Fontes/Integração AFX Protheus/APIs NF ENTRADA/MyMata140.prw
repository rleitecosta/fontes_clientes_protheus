#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"
#Include 'parmtype.ch'        
#Include "TopConn.Ch"
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: MyMata140    Ultima Alteração: Carlos H Fernandes      Data: 13/02/2020  
//Descrição: ExecAuto no Documento de Entrada Pré Nota - Insere
//Uso: Carlson
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function MyMata140(oNF,nOpc,cPar01)

   Local lRet              As Logical     // retorno do método
   Local lSimula           As Logical     // permite simular a operação

   Local aArea             As Array       // área em uso
   Local aHeader           As Array       // cabeçalho do documento
   Local aItens            As Array       // items do documento
   Local aLinha            As Array       // items do documento (auxiliar)
   Local aLogAuto          As Array       // log de retorno

   Local cErro             As Character   // conteudo do erro
   Local cArqLog           As Character   // arquivo de log
   Local cDir              As Character   // diretorio do log
   Local cContecpo         As Character   // conteudo do campo
   Local cTipo             As Character   // tipo do campo
   Local wsDOC             As Character   // numero do documento NF
   Local wsSerie           As Character   // numero de serie da NF
   Local cError            As Character   // parser

   Local nX                As Numeric     // contador do cabeçalho
   Local nY                As Numeric     // contador do array de itens
   Local nZ                As Numeric     // contador dos itens
   Local nTelaAuto         As Numeric     // controle de tela
   
   Private lMsErroAuto     As Logical 
   Private lMsHelpAuto     As Logical
   Private lAutoErrNoFile  As Logical

   lRet           := .T.
   
   aArea          := GetArea()
   aHeader        := {}
   aItens         := {}
   aLinha         := {}
   aLogAuto       := {}

   cErro          := ''
   cArqLog        := ''
   cDir           := ''
   cContecpo      := ''
   cTipo          := ''
   wsDOC          := ''
   wsSerie        := ''
   cError         := ''

   nX             := 0
   nY             := 0
   nOpcao         := 3
   nTelaAuto      := 0
   
   lMsErroAuto    := .F.
   lMsHelpAuto    := .T.
   lAutoErrNoFile := .T.
   lSimula        := .F.

//--------------------------------------------------------------------------Inclusão do Documento Via POST--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
If nOpc == 3	
   /*
    header do documento de entrada / pre nota
   */
	For nX := 1 to Len(oNF:SF1)
	        
      cTipo := TamSX3(oNF:SF1[nX]:campo)[3] 
      If cTipo == "C" 
         cContecpo := Alltrim(oNF:SF1[nX]:conteudo)
      ElseIf cTipo == "N"
         cContecpo := Val(oNF:SF1[nX]:conteudo)
      ElseIf cTipo == "D"
         cContecpo := SToD(oNF:SF1[nX]:conteudo)
      ElseIf cTipo == "M" 
         cContecpo := Alltrim(oNF:SF1[nX]:conteudo)
      Endif               

      If Alltrim(oNF:SF1[nX]:campo) == "F1_DOC"   	// Guarda numero do documento
	       wsDOC   := Alltrim(oNF:SF1[nX]:conteudo)
	   Endif
      
      If Alltrim(oNF:SF1[nX]:campo) == "F1_SERIE"   	// Guarda serie do documento
	       wsSerie := Alltrim(oNF:SF1[nX]:conteudo)
	   Endif

      aAdd( aHeader, { oNF:SF1[nX]:campo, cContecpo, Nil } )
	
	Next				
    
   /*
    Itens do documento de entrada / pre nota
   */
   For nY := 1 to Len(oNF:SD1) 
	   aLinha  := {}
	   For nZ := 1 To Len(oNF:SD1[nY])
         cTipo := TamSX3(oNF:SD1[nY,nZ]:campo)[3] 
         If cTipo == "C"  
            cContecpo := Alltrim(oNF:SD1[nY,nZ]:conteudo)
         ElseIf cTipo == "N"
            cContecpo := Val(oNF:SD1[nY,nZ]:conteudo)
         ElseIf cTipo == "D"
            cContecpo := SToD(oNF:SD1[nY,nZ]:conteudo)
         Endif  
                     
         aAdd( aLinha, { oNF:SD1[nY,nZ]:campo , cContecpo , Nil } )
      
	   Next
	      aLinha := FWVetByDic( aLinha, "SD1" )
         Aadd(aItens,aLinha) 
	Next				

   DbSelectArea("SF1")
   SF1->( DbSetOrder(1) )
   //If !(SF1->( DbSeek( xFilial("SF1") +PADR(wsDoc,TAMSX3("F1_DOC")[1]) + wsSerie ) ))				        
      aHeader := FWVetByDic( aHeader, "SF1" )        
      MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)},aHeader,aItens,nOpc,lSimula,nTelaAuto)
         
      If lMsErroAuto	
         RollBackSX8()      
         //cErro := MostraErro()
         //cErro := TrataErro(cErro)
         //SetRestFault(400, cErro)
         
         aErrPCAuto	:= GETAUTOGRLOG()	
         cMsgErro	:= ""												

         For nX := 1 To Len(aErrPCAuto)
            if At("Invalido", aErrPCAuto[nX]) <> 0  .OR. At("AJUDA", aErrPCAuto[nX]) <> 0 
               cMsgErro += FWCutOff(MiddleTrim(aErrPCAuto[nX]),.T.) + " "
            endif
         Next

         cRet  := FWCutOff('{"Status":"400","Mensagem":"'+ cMsgErro+'"}')

      Else	
         ConfirmSX8()
         cRet := '{"Status":"200","Mensagem":"Inclusão da pré-nota efetuada com sucesso. Doc-Serie numero: '+ alltrim(SF1->F1_DOC) +'-'+ alltrim(SF1->F1_SERIE) +'"}'
      Endif
   //Else	
    //  cRet := '{"Status":"400","Mensagem":"Pré-nota já existe no sistema. Doc-Serie numero: '+ alltrim(SF1->F1_DOC) +'-'+ alltrim(SF1->F1_SERIE) +'"}'
   //Endif     
Else
   cRet := '{"Status":"400","Mensagem":"Para esta API só esta habilitada a inclusão de documento de entrada - Pré Nota."}'
Endif
   RestArea(aArea)
Return(cRet)    

//-----------------------------------------------------------------------------------------------------------------------------------------------

Static Function MiddleTrim(cText)                              //Função que elimina excesso de espaços em branco em uma string
    While "  " $ cText .OR. "xx" $ cText
        cText = StrTran(cText, "  ", " ")
        cText = StrTran(cText, "xx", " ")
    End
Return AllTrim(cText)
