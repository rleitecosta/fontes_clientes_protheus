#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSINTCCO
    Método para envio da estrutura JSON contendo dados de Plano de Contas
    @type function
    @author Leandro Schumann Thomaz
    @since 08/02/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - 
    @obs Uso PlastReal
/*/
User Function WSINTCCO(cCodCco,lLote,lDeleta)
    //------------------------------------------------------------------------------------------------
    // Estrutura modelo: Type JSON
    /*{
    "id_service": "zD20190403H111753080R000000005",   
    "environment": "HOMOLOGACAO", //HOMOLOGACAO | PRODUCAO | {vazio é produção}
    "fin_contacontabil.codigo": "0001",
    "fin_contacontabil.descricao": " Teste Conta"
    }
    */

    //------------------------------------------------------------------------------------------------
    Local cServer   AS Character  // URL (IP) do servidor
    Local cPort     AS Character  // Porta do serviço REST
    Local cURI      AS Character  // URI do serviço REST
    Local cResource AS Character  // Recurso a ser consumido
    Local cID       AS Character  // Token de validação API
    Local cAmbiente AS Character  // Ambiente informado na execução
    Local cQry      AS Character  // Query para busca dos dados da NF
    Local cAlias    AS Character  // Alias da Query
    Local lIntegr   AS Logical    // Boleano de integração
    Local oRest     AS J          // Cliente para consumo REST
    Local oBody     AS J          // Envio do corpo JSON
    Local aHeader   AS Array      // Cabeçalho para requisição
    Local aAreaCT1   AS Array      // Preserva area
    
    //Parametros da API
    cServer   := SuperGetMv("MV_IPSRV",.F.,"54.233.177.56")
    cPort     := SuperGetMv("MV_PORTSRV",.F.,"9608")
    cAmbiente := SuperGetMv("MV_APIAMBI",.F.,"HOMOLOGACAO")
    cURI      := "http://" + cServer + ":" + cPort
    cResource := SuperGetMv("MV_RAPIPRD",.F.,"/fin/saveContaContabil")  
    cID       := "zD20190403H111753080R000000005"
    aHeader   := {}
    cAlias    := GetNextAlias()
    lIntegr   := .F.
    cJson     :=""
    
    Default lDeleta :=.F.
    
    
    //Monta o Cabeçalho da requisição
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    //Montagem do Objeto para retorno do JSON
    If lLote

      //Query para seleção do Fornecedor
        cQry := " SELECT CT1_CONTA ,CT1_DESC01, CT1_BLOQ "         + CRLF
        cQry += " FROM "+RetSqlName("CT1")+" CT1 "                 + CRLF
        cQry += " WHERE  "                                         + CRLF
        cQry += " CT1.CT1_FILIAL  = '"+XFilial('CT1')+"' "         + CRLF
        cQry += " AND  CT1.D_E_L_E_T_ = ' ' AND CT1_CLASSE = '2'"  + CRLF
        
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())

        If (cAlias)->(!Eof())
            While (cAlias)->(!Eof())
                //Prepara o Objeto para cada Fornecedor a ser enviado
                oBody := JsonObject():New()
                cJson     :=cURI+"/"+cResource + CRLF
                cJson     +="{ "+ CRLF
                
                oBody['id_service']                            := cID
                cJson                                          +='"id_service": "'+cID+'",'       + CRLF
                oBody['environment']                           := cAmbiente          
                cJson                                          +='"environment": "'+cAmbiente+'",'+ CRLF
                oBody['fin_contacontabil.codigo']              := ALLTRIM((cAlias)->CT1_CONTA)
                cJson +='"fin_contacontabil.codigo": "'+ALLTRIM((cAlias)->CT1_CONTA)+'",'+ CRLF 
                oBody['fin_contacontabil.isInactive']                := Iif((cAlias)->CT1_BLOQ=='1',"true","false")
                cJson     +='"fin_contacontabil.isInactive": '+iif((cAlias)->CT1_BLOQ=='1','"true"','"false"')+','+ CRLF
                If lDeleta
                    oBody['fin_contacontabil.isDeleted']                := "true"
                    cJson     +='"fin_contacontabil.isDeleted": "true",'+ CRLF
                Else
                    oBody['fin_contacontabil.isDeleted']                := "false"
                    cJson     +='"fin_contacontabil.isDeleted": "false",'+ CRLF
                Endif
                oBody['fin_contacontabil.descricao']                        := ALLTRIM((cAlias)->CT1_DESC01)
                cJson     +='"fin_contacontabil.descricao": "'+ALLTRIM((cAlias)->CT1_DESC01)+'"'+ CRLF
                
               
                cJson     +="}"+ CRLF+ CRLF
                //Executa o método de envio POST e valida o retorno
                cTextJson      := ""
                oRest := FwRest():New(cURI)   
                oRest:nTimeOut:= 60 //Segundos
                oRest:SetPath(cResource)
                oRest:SetPostParams(oBody:ToJson()) 
                If (oRest:Post(aHeader))
                    ConOut("POST: " + oRest:GetResult())
                    cTextJson      := oRest:GetResult()
                    lIntegr := .T.
                Else
                    ConOut("POST: " + oRest:GetLastError())
                    cTextJson      := oRest:GetResult()
                    lIntegr := .F.
                EndIf
                
                //Posiciona no registro novamente para garantir a gravação no registro correto
                DbSelectArea('CT1')
                aAreaCT1 := CT1->(GetArea())
                DbSetOrder(1)// CT1_FILIAL+CT1_CONTA
                CT1->(DbGotop())
                If DbSeek(FwXfilial('CT1')+(cAlias)->CT1_CONTA)
                    if CT1->(FieldPos("CT1_XAFXST")>0)
                        if CT1->(RecLock("CT1",.F.))
                            If lIntegr 
                                    CT1->CT1_XAFXST := "I"
                                If ValType(cTextJson) == "C"
                                    CT1->CT1_XAFXMS := CT1->CT1_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Else
                                CT1->CT1_XAFXST := "E"
                                If ValType(cTextJson) == "C"
                                    CT1->CT1_XAFXMS := CT1->CT1_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Endif
                            CT1->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaCT1)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    
    Else
        //Query para seleção do Fornecedor
        cQry := " SELECT CT1_CONTA ,CT1_DESC01, CT1_BLOQ "      + CRLF
        cQry += " FROM "+RetSqlName("CT1")+" CT1 "              + CRLF
        cQry += " WHERE  "                                      + CRLF
        cQry += " CT1.CT1_FILIAL  = '"+XFilial('CT1')+"' "      + CRLF
        If !lDeleta
            cQry += "   AND  CT1.D_E_L_E_T_ = ' ' "             + CRLF
        Endif
        cQry += "   AND CT1.CT1_CONTA     = '"+cCodCco+"'"      + CRLF
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())

        If (cAlias)->(!Eof())
            While (cAlias)->(!Eof())
                //Prepara o Objeto para cada Fornecedor a ser enviado
                oBody := JsonObject():New()
                cJson     :=cURI+"/"+cResource + CRLF
                cJson     +="{ "+ CRLF
                
                oBody['id_service']                            := cID
                cJson                                          +='"id_service": "'+cID+'",'       + CRLF
                oBody['environment']                           := cAmbiente          
                cJson                                          +='"environment": "'+cAmbiente+'",'+ CRLF
                oBody['fin_contacontabil.codigo']              := ALLTRIM((cAlias)->CT1_CONTA)
                cJson +='"fin_contacontabil.codigo": "'+ALLTRIM((cAlias)->CT1_CONTA)+'",'+ CRLF 
                oBody['fin_contacontabil.isInactive']                := Iif((cAlias)->CT1_BLOQ=='1',"true","false")
                cJson     +='"fin_contacontabil.isInactive": '+iif((cAlias)->CT1_BLOQ=='1','"true"','"false"')+','+ CRLF
                If lDeleta
                    oBody['fin_contacontabil.isDeleted']                := "true"
                    cJson     +='"fin_contacontabil.isDeleted": "true",'+ CRLF
                Else
                    oBody['fin_contacontabil.isDeleted']                := "false"
                    cJson     +='"fin_contacontabil.isDeleted": "false",'+ CRLF
                Endif
                oBody['fin_contacontabil.descricao']                        := ALLTRIM((cAlias)->CT1_DESC01)
                cJson     +='"fin_contacontabil.descricao": "'+ALLTRIM((cAlias)->CT1_DESC01)+'"'+ CRLF
                
               
                cJson     +="}"+ CRLF+ CRLF
                //Executa o método de envio POST e valida o retorno
                cTextJson      := ""
                oRest := FwRest():New(cURI)   
                oRest:nTimeOut:= 60 //Segundos
                oRest:SetPath(cResource)
                oRest:SetPostParams(oBody:ToJson()) 
                If (oRest:Post(aHeader))
                    ConOut("POST: " + oRest:GetResult())
                    cTextJson      := oRest:GetResult()
                    lIntegr := .T.
                Else
                    ConOut("POST: " + oRest:GetLastError())
                    cTextJson      := oRest:GetResult()
                    lIntegr := .F.
                EndIf
                
                //Posiciona no registro novamente para garantir a gravação no registro correto
                DbSelectArea('CT1')
                aAreaCT1 := CT1->(GetArea())
                DbSetOrder(1)// CT1_FILIAL+CT1_CONTA
                CT1->(DbGotop())
                If DbSeek(FwXfilial('CT1')+cCodCco)
                    if CT1->(FieldPos("CT1_XAFXST")>0)
                        if CT1->(RecLock("CT1",.F.))
                            If lIntegr 
                                CT1->CT1_XAFXST := "I"
                                If ValType(cTextJson) == "C"
                                    CT1->CT1_XAFXMS := CT1->CT1_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Else
                                CT1->CT1_XAFXST := "E"
                                If ValType(cTextJson) == "C"
                                    CT1->CT1_XAFXMS := CT1->CT1_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Endif
                            CT1->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaCT1)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Endif
    (cAlias)->(DbCloseArea())

Return lIntegr
