#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSRESTENVNF
    Método para envio da estrutura JSON contendo dados do documento de saida - NF
    @type class
    @author Carlos H. Fernandes
    @since 17/01/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - http://54.233.177.56:9608/fis/confirmaEmissao 
    @obs Uso Carlson
/*/

User Function WSRESTNF(cDoc,cSerie,lLote,lAPI)
    //------------------------------------------------------------------------------------------------
    //Estrutura modelo: Type JSON
    // {
    //     "id_service": "zD20190403H111753080R000000005",
    //     "environment": "HOMOLOGACAO",
    //     "numero": "000001",
    //     "documento": "01.293.164/0001-83",
    //     "chaveAcesso": "03591728972987289289347583758374993",
    //     "dtEmissao": "2019-10-23T09:38:21.001-03:00",
    //     "solicitacaoEmissao": "000234",
    //     "valorTotal": 10932.82,
    //     "itens": [
    //         {"seqNF": 1, "solicitacaoEmissao": "2012", "seqPed": 1, "valorTotal": 5004.21 },
    //         {"seqNF": 2, "solicitacaoEmissao": "2097", "seqPed": 3, "valorTotal": 313.12  },
    //         {"seqNF": 3, "solicitacaoEmissao": "1983", "seqPed": 1, "valorTotal": 4524.56 }
    //      ]
    // }
    //------------------------------------------------------------------------------------------------
    Local cServer   AS Character  // URL (IP) do servidor
    Local cPort     AS Character  // Porta do serviço REST
    Local cURI      AS Character  // URI do serviço REST
    Local cResource AS Character  // Recurso a ser consumido
    Local cID       AS Character  // Token de validação API
    Local cAmbiente AS Character  // Ambiente informado na execução
    Local cNumNF    AS Character  // Numero do documento e serie
    Local cQry      AS Character  // Query para busca dos dados da NF
    Local cAlias    AS Character  // Alias da Query
    Local oRest     AS J          // Cliente para consumo REST
    Local oBody     AS J          // Envio do corpo JSON
    Local oItens    AS J          // Objeto de itens da nota
    Local aHeader   AS Array      // Cabeçalho para requisição
    Local cRet      AS Character
    
    Default cEmpAnt := "Schedule"
    Default lAPI    := .F.
    
    lLimpa := .F.
    If cEmpAnt == "Schedule" .and. !lAPI// Se via schedule prepara o ambiente
        cFil			:= "0101"
        cEmp			:= "01"
        RpcSetType(3)	
        RpcSetEnv(cEmp,cFil,,,,,)
        lLote  :=.T.
        lLimpa := .T.
    EndIf
    
    //Parametros da API
    cServer   := SuperGetMv("MV_IPSRV",.F.,"54.233.177.56")
    cPort     := SuperGetMv("MV_PORTSRV",.F.,"9608")
    cAmbiente := SuperGetMv("MV_APIAMBI",.F.,"HOMOLOGACAO")
    cURI      := "http://" + cServer + ":" + cPort
    cResource := SuperGetMv("MV_RAPINFS",.F.,"/fis/confirmaEmissao")
    cID       := "zD20190403H111753080R000000005"
    aHeader   := {}
    cAlias    := GetNextAlias()
    cTextJson      := ""
    
    //Monta o Cabeçalho da requisição
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
    
    //Montagem do Objeto para retorno do JSON
    If lLote       

        //Query para seleção da NF
        cQry := " Select F2_FILIAL,    "+ CRLF
        cQry += "        F2_DOC,  "+ CRLF
        cQry += "        F2_SERIE,  "+ CRLF
        cQry += "        A1_CGC,    "+ CRLF
        cQry += "        F2_CHVNFE, "+ CRLF
        cQry += "        F2_EMISSAO,"+ CRLF
        cQry += "        F2_VALBRUT,"+ CRLF
        cQry += "        D2_ITEM,   "+ CRLF
        cQry += "        D2_PEDIDO, "+ CRLF
        cQry += "        D2_ITEMPV, "+ CRLF
        cQry += "        D2_TOTAL   "+ CRLF
        cQry += " From "+RetSqlName("SF2")+" SF2" + CRLF
        cQry += " Inner Join "+RetSqlName("SD2")+" SD2"+ CRLF
        cQry += "         On D2_FILIAL  = F2_FILIAL" + CRLF
        cQry += "        And D2_DOC     = F2_DOC   " + CRLF
        cQry += "        And D2_SERIE   = F2_SERIE " + CRLF
        cQry += "        And SD2.D_e_l_e_t_ = ' ' "+ CRLF
        cQry += " Inner Join "+RetSqlName("SA1")+" SA1"+ CRLF
        cQry += "         On A1_COD = F2_CLIENTE "+ CRLF
        cQry += "        And A1_LOJA = F2_LOJA   "+ CRLF
        cQry += "        And SA1.D_e_l_e_t_ = ' '"+ CRLF
        cQry += " Where SF2.D_e_l_e_t_ = ' ' " + CRLF
        cQry += "   And SF2.F2_FILIAL = '"+FwXFilial('SF2')+"'"+ CRLF
        cQry += "   And SF2.F2_XAFXSTA <> 'I' " + CRLF
        cQry += "   And F2_CHVNFE <> ' ' "
        cQry += "   And SF2.F2_TIPO = 'N' "
        cQry += "   And SF2.F2_EMISSAO >= '20210101' "
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())
        

        If (cAlias)->(!Eof())
         /*   //nHandle := FCREATE("\logs\LOG_NFS_"+DTOS(DATE())+"_"+TIME()+".txt") // crio Arquivo LOG
            nHandle := FCREATE("C:\LOG\LOG_NFS_"+DTOS(DATE())+"_"+SUBSTR(TIME(), 1, 2)+"_"+SUBSTR(TIME(), 4, 2)+"_"+SUBSTR(TIME(), 7, 2)+".txt") // crio Arquivo LOG

            if nHandle = -1
                ALERT("Erro ao criar arquivo - ferror " + Str(Ferror()))
                return
            endif
            FWrite(nHandle, "Inicio do Processamento: "+Time() + CRLF)*/

            While (cAlias)->(!Eof())

                 /*/ Alimento LOG
                
                FWrite(nHandle, "Nota Fiscal        : "+alltrim((cAlias)->F2_DOC)        + CRLF)
                FWrite(nHandle, "Emissao            : "+SubStr(Alltrim((cAlias)->F2_EMISSAO),1,4)+"-"+SubStr(Alltrim((cAlias)->F2_EMISSAO),5,2)+"-"+SubStr(Alltrim((cAlias)->F2_EMISSAO),7,2)+ CRLF)
                FWrite(nHandle, "Pedido de Vendas   : "+Alltrim((cAlias)->D2_PEDIDO)+ CRLF)
                FWrite(nHandle, "Chave NFE          : "+Alltrim((cAlias)->F2_CHVNFE)+ CRLF)*/
                

                //Prepara o Objeto para cada NF a ser enviada
                oBody     := JsonObject():New()
                //Montagem do cabeçalho da nota
                oBody['id_service']         := cID
                oBody['environment']        := cAmbiente          
                oBody['numero']             := AllTrim((cAlias)->F2_DOC)
                oBody['documento']          := Alltrim((cAlias)->A1_CGC)
                oBody['chaveAcesso']        := Alltrim((cAlias)->F2_CHVNFE)
                oBody['dtEmissao']          := SubStr(Alltrim((cAlias)->F2_EMISSAO),1,4)+"-"+SubStr(Alltrim((cAlias)->F2_EMISSAO),5,2)+"-"+SubStr(Alltrim((cAlias)->F2_EMISSAO),7,2)
                oBody['solicitacaoEmissao'] := Alltrim((cAlias)->D2_PEDIDO)          
                oBody['valorTotal']         := (cAlias)->F2_VALBRUT        
                oBody['itens']              := {}        
                //Motagem dos itens da nota
                cNumNF := (cAlias)->F2_DOC+(cAlias)->F2_SERIE
                While cNumNF == (cAlias)->F2_DOC+(cAlias)->F2_SERIE
                    oItens := JsonObject():New()
                    oItens['seqNF']              := Alltrim(Str(Val((cAlias)->D2_ITEM)))
                    oItens['solicitacaoEmissao'] := Alltrim((cAlias)->D2_PEDIDO)
                    oItens['seqPed']             := Alltrim((cAlias)->D2_ITEMPV)
                    oItens['valorTotal']         := (cAlias)->D2_TOTAL
                    aadd(oBody['itens'] , oItens)
                    (cAlias)->(DbSkip())
                    FreeObj(oItens)
                EndDo
                DBSelectArea("SF2")
                DBSetOrder(1)//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
                If DBSeek((cAlias)->F2_FILIAL+ (cAlias)->F2_DOC+ (cAlias)->F2_SERIE)
                    //Executa o método de envio POST e valida o retorno
                    oRest := FwRest():New(cURI)   
                    oRest:nTimeOut:= 60 //Segundos
                    oRest:SetPath(cResource)
                    oRest:SetPostParams(oBody:ToJson()) 
                    cTextJson      := ""
                    If (oRest:Post(aHeader))
                        ConOut("POST: " + oRest:GetResult())
                        cTextJson      := oRest:GetResult()
                        //FWrite(nHandle, "Integrado Sucesso " + CRLF)
                        if SF2->(FieldPos("F2_XAFXSTA")>0)
                            if SF2->(RecLock("SF2",.F.))
                                SF2->F2_XAFXSTA := "I"
                                If ValType(cTextJson) == "C"
                                    SF2->F2_XAFXMSG := cTextJson
                                EndIf
                                SF2->(MsUnLock())
                            endif
                        endif
                    Else
                        // FWrite(nHandle, "Erro na Integração" + CRLF)
                        ConOut("POST: " + oRest:GetLastError())
                        cTextJson      := oRest:GetResult()
                        if SF2->(FieldPos("F2_XAFXSTA")>0)
                            if SF2->(RecLock("SF2",.F.))
                                SF2->F2_XAFXSTA := "E"
                                If ValType(cTextJson) == "C"
                                    //FWrite(nHandle, cTextJson + CRLF)
                                    SF2->F2_XAFXMSG := cTextJson
                                EndIf                                
                                SF2->(MsUnLock())
                            endif
                        endif
                    EndIf
                    //FWrite(nHandle, "" + CRLF)
                Endif
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
            EndDo
            (cAlias)->(dbCloseArea())
        Endif
        //FWrite(nHandle,"Fim do Processamento: "+ Time() + CRLF)
        //FClose(nHandle) // fecho arquivo de log
    Else
        //Query para seleção da NF
        cQry := " Select F2_FILIAL,    "+ CRLF
        cQry += "        F2_DOC,  "+ CRLF
        cQry += "        F2_SERIE,  "+ CRLF
        cQry += "        A1_CGC,    "+ CRLF
        cQry += "        F2_CHVNFE, "+ CRLF
        cQry += "        F2_EMISSAO,"+ CRLF
        cQry += "        F2_VALBRUT,"+ CRLF
        cQry += "        D2_ITEM,   "+ CRLF
        cQry += "        D2_PEDIDO, "+ CRLF
        cQry += "        D2_ITEMPV, "+ CRLF
        cQry += "        D2_TOTAL   "+ CRLF
        cQry += " From "+RetSqlName("SF2")+" SF2" + CRLF
        cQry += " Inner Join "+RetSqlName("SD2")+" SD2"+ CRLF
        cQry += "         On D2_FILIAL  = F2_FILIAL" + CRLF
        cQry += "        And D2_DOC     = F2_DOC   " + CRLF
        cQry += "        And D2_SERIE   = F2_SERIE " + CRLF
        cQry += "        And SD2.D_e_l_e_t_ = ' ' "+ CRLF
        cQry += " Inner Join "+RetSqlName("SA1")+" SA1"+ CRLF
        cQry += "         On A1_COD = F2_CLIENTE "+ CRLF
        cQry += "        And A1_LOJA = F2_LOJA   "+ CRLF
        cQry += "        And SA1.D_e_l_e_t_ = ' '"+ CRLF
        cQry += " Where SF2.D_e_l_e_t_ = ' ' " + CRLF
        cQry += "   And SF2.F2_FILIAL = '"+FwXFilial('SF2')+"'"+ CRLF
        cQry += "   And SF2.F2_DOC    = '"+cDoc+"'"+ CRLF
        cQry += "   And SF2.F2_SERIE  = '"+cSerie+"'"+ CRLF
        cQry += "   And F2_CHVNFE <> ' ' "
        cQry += "   And SF2.F2_TIPO = 'N' "
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())

        If (cAlias)->(!Eof())
            While (cAlias)->(!Eof())
                //Prepara o Objeto para cada NF a ser enviada
                oBody     := JsonObject():New()
                //Montagem do cabeçalho da nota
                oBody['id_service']         := cID
                oBody['environment']        := cAmbiente          
                oBody['numero']             := AllTrim((cAlias)->F2_DOC)
                oBody['documento']          := Alltrim((cAlias)->A1_CGC)
                oBody['chaveAcesso']        := Alltrim((cAlias)->F2_CHVNFE)
                oBody['dtEmissao']          := SubStr(Alltrim((cAlias)->F2_EMISSAO),1,4)+"-"+SubStr(Alltrim((cAlias)->F2_EMISSAO),5,2)+"-"+SubStr(Alltrim((cAlias)->F2_EMISSAO),7,2)
                oBody['solicitacaoEmissao'] := Alltrim((cAlias)->D2_PEDIDO)          
                oBody['valorTotal']         := (cAlias)->F2_VALBRUT        
                oBody['itens']              := {}        
                //Motagem dos itens da nota
                cNumNF := (cAlias)->F2_DOC+(cAlias)->F2_SERIE
                While cNumNF == (cAlias)->F2_DOC+(cAlias)->F2_SERIE
                    oItens := JsonObject():New()
                    oItens['seqNF']              := Alltrim(Str(Val((cAlias)->D2_ITEM)))
                    oItens['solicitacaoEmissao'] := Alltrim((cAlias)->D2_PEDIDO)
                    oItens['seqPed']             := Alltrim((cAlias)->D2_ITEMPV)
                    oItens['valorTotal']         := (cAlias)->D2_TOTAL
                    aadd(oBody['itens'] , oItens)
                    (cAlias)->(DbSkip())
                    FreeObj(oItens)
                EndDo
                
                //Executa o método de envio POST e valida o retorno
                oRest := FwRest():New(cURI)   
                oRest:nTimeOut:= 60 //Segundos
                oRest:SetPath(cResource)
                oRest:SetPostParams(oBody:ToJson()) 
                cTextJson      := ""
                If (oRest:Post(aHeader))
                    ConOut("POST: " + oRest:GetResult())
                    cTextJson      := oRest:GetResult()
                    if SF2->(FieldPos("F2_XAFXSTA")>0)
                        if SF2->(RecLock("SF2",.F.))
                            SF2->F2_XAFXSTA := "I"
                            If ValType(cTextJson) == "C"
                                cRet := cTextJson
                                SF2->F2_XAFXMSG := cTextJson
                            EndIf
                            SF2->(MsUnLock())
                        endif
                    endif
                Else
                    ConOut("POST: " + oRest:GetLastError())
                    cTextJson      := oRest:GetResult()
                    if SF2->(FieldPos("F2_XAFXSTA")>0)
                        if SF2->(RecLock("SF2",.F.))
                            SF2->F2_XAFXSTA := "E"
                            If ValType(cTextJson) == "C"
                                cRet := cTextJson
                                SF2->F2_XAFXMSG := cTextJson
                            EndIf
                            SF2->(MsUnLock())
                        endif
                    endif
                EndIf
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
            EndDo
            (cAlias)->(dbCloseArea())
        Endif
    Endif
    If lLimpa  // Se via schedule limpa o ambiente
        RpcClearEnv()	
    EndIf

Return (cRet)
