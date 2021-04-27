
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSINTCCU
    Método para envio da estrutura JSON contendo dados de Centro de Custo
    @type function
    @author Leandro Schumann Thomaz
    @since 08/02/2021
    @version P12
    @param body json    @return objeto json
    @obs EndPoint - http://endereço:porta/cts/saveCentroDeCusto
    @obs Uso PlastReal
/*/
User Function WSINTCCU(cCodCcu,lLote,lDeleta)
    //------------------------------------------------------------------------------------------------
    // Estrutura modelo: Type JSON
    /*{
    "id_service": "zD20190403H111753080R000000005",   
    "environment": "HOMOLOGACAO", //HOMOLOGACAO | PRODUCAO | {vazio é produção}
    "cts_centrodecusto.codigo": "001",
    "cts_centrodecusto.descricao": " Teste CT"
    }*/

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
    Local aAreaCTT   AS Array      // Preserva area
    
    //Parametros da API
    cServer   := SuperGetMv("MV_IPSRV",.F.,"54.233.177.56")
    cPort     := SuperGetMv("MV_PORTSRV",.F.,"9608")
    cAmbiente := SuperGetMv("MV_APIAMBI",.F.,"HOMOLOGACAO")
    cURI      := "http://" + cServer + ":" + cPort
    cResource := SuperGetMv("MV_RAPIPRD",.F.,"/cts/saveCentroDeCusto")
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
    
        //Query para seleção dos Centros de Custo
        cQry := " SELECT CTT_CUSTO ,CTT_DESC01, CTT_BLOQ "          + CRLF
        cQry += " FROM "+RetSqlName("CTT")+" CTT "                  + CRLF
        cQry += " WHERE  "                                          + CRLF
        cQry += " CTT.CTT_FILIAL  = '"+XFilial('CTT')+"' "          + CRLF
        cQry += " AND  CTT.D_E_L_E_T_ = ' ' AND CTT_CLASSE = '2'"   + CRLF
        
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
                oBody['cts_centrodecusto.codigo']              := ALLTRIM((cAlias)->CTT_CUSTO)
                cJson +='"cts_centrodecusto.codigo": "'+ALLTRIM((cAlias)->CTT_CUSTO)+'",'+ CRLF 
                oBody['cts_centrodecusto.isInactive']                := Iif((cAlias)->CTT_BLOQ=='1',"true","false")
                cJson     +='"cts_centrodecusto.isInactive": '+iif((cAlias)->CTT_BLOQ=='1','"true"','"false"')+','+ CRLF
                If lDeleta
                    oBody['cts_centrodecusto.isDeleted']                := "true"
                    cJson     +='"cts_centrodecusto.isDeleted": "true",'+ CRLF
                Else
                    oBody['cts_centrodecusto.isDeleted']                := "false"
                    cJson     +='"cts_centrodecusto.isDeleted": "false",'+ CRLF
                Endif
                oBody['cts_centrodecusto.descricao']                        := ALLTRIM((cAlias)->CTT_DESC01)
                cJson     +='"cts_centrodecusto.descricao": "'+ALLTRIM((cAlias)->CTT_DESC01)+'"'+ CRLF
                
               
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
                DbSelectArea('CTT')
                aAreaCTT := CTT->(GetArea())
                DbSetOrder(1)// CTT_FILIAL+CTT_CUSTO
                CTT->(DbGotop())
                If DbSeek(FwXfilial('CTT')+(cAlias)->CTT_CUSTO)
                    if CTT->(FieldPos("CTT_XAFXST")>0)
                        if CTT->(RecLock("CTT",.F.))
                            If lIntegr 
                                CTT->CTT_XAFXST := "I"
                                If ValType(cTextJson) == "C"
                                    CTT->CTT_XAFXMS := CTT->CTT_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Else
                                CTT->CTT_XAFXST := "E"
                                If ValType(cTextJson) == "C"
                                    CTT->CTT_XAFXMS := CTT->CTT_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Endif
                            CTT->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaCTT)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Else
        //Query para seleção dos Centros de Custo
        cQry := " SELECT CTT_CUSTO ,CTT_DESC01, CTT_BLOQ "      + CRLF
        cQry += " FROM "+RetSqlName("CTT")+" CTT "              + CRLF
        cQry += " WHERE  "                                      + CRLF
        cQry += " CTT.CTT_FILIAL  = '"+XFilial('CTT')+"' "      + CRLF
        If !lDeleta
            cQry += "   AND  CTT.D_E_L_E_T_ = ' ' "             + CRLF
        Endif
        cQry += "   AND CTT.CTT_CUSTO     = '"+cCodCcu+"'"      + CRLF
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
                oBody['cts_centrodecusto.codigo']              := ALLTRIM((cAlias)->CTT_CUSTO)
                cJson +='"cts_centrodecusto.codigo": "'+ALLTRIM((cAlias)->CTT_CUSTO)+'",'+ CRLF 
                oBody['cts_centrodecusto.isInactive']                := Iif((cAlias)->CTT_BLOQ=='1',"true","false")
                cJson     +='"cts_centrodecusto.isInactive": '+iif((cAlias)->CTT_BLOQ=='1','"true"','"false"')+','+ CRLF
                If lDeleta
                    oBody['cts_centrodecusto.isDelete']                := "true"
                    cJson     +='"cts_centrodecusto.isDelete": "true",'+ CRLF
                Else
                    oBody['cts_centrodecusto.isDelete']                := "false"
                    cJson     +='"cts_centrodecusto.isDelete": "false",'+ CRLF
                Endif
                oBody['cts_centrodecusto.descricao']                        := ALLTRIM((cAlias)->CTT_DESC01)
                cJson     +='"cts_centrodecusto.descricao": "'+ALLTRIM((cAlias)->CTT_DESC01)+'"'+ CRLF
                
               
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
                DbSelectArea('CTT')
                aAreaCTT := CTT->(GetArea())
                DbSetOrder(1)// CTT_FILIAL+CTT_CUSTO
                CTT->(DbGotop())
                If DbSeek(FwXfilial('CTT')+cCodCcu)
                    if CTT->(FieldPos("CTT_XAFXST")>0)
                        if CTT->(RecLock("CTT",.F.))
                            If lIntegr 
                                CTT->CTT_XAFXST := "I"
                                If ValType(cTextJson) == "C"
                                    CTT->CTT_XAFXMS := CTT->CTT_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Else
                                CTT->CTT_XAFXST := "E"
                                If ValType(cTextJson) == "C"
                                    CTT->CTT_XAFXMS := CTT->CTT_XAFXMS + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Endif
                            CTT->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaCTT)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Endif
  
   (cAlias)->(DbCloseArea())

Return lIntegr
