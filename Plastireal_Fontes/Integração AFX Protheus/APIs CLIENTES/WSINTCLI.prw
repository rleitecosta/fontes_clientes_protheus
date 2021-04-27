
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSINTCLI
    Método para envio da estrutura JSON contendo dados do cliente
    @type class
    @author Carlos H. Fernandes
    @since 03/02/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - http://54.233.177.56:9608/crm/saveConta
    @obs Uso PlastReal
/*/
User Function WSINTCLI(cCodCli,cLjCli,lLote)
    //------------------------------------------------------------------------------------------------
    // Estrutura modelo: Type JSON
    // {
    //   "id_service": "zD20190403H111753080R000000005",
    //   "environment": "HOMOLOGACAO", //HOMOLOGACAO | PRODUCAO | {vazio é produção}
    //   "tipo": "cliente",
    //    "crm_conta.codigo": "000011",
    //    "crm_conta.nome": "CODIT",
    //    "crm_conta.razaosocial": "CODIT Tecnologia da LTDA",
    //    "crm_conta.Documento_tipo": "CNPJ"
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
    Local lIntegr   AS Logical    // Boleano de integração
    Local oRest     AS J          // Cliente para consumo REST
    Local oJson     AS J          // Cliente para consumo REST
    Local oBody     AS J          // Envio do corpo JSON
    Local oItens    AS J          // Objeto de itens da nota
    Local aHeader   AS Array      // Cabeçalho para requisição
    Local aAreaA1   AS Array      // Preserva area
    Local cDtNasc   AS Date       // Data nascimento 
    Local cDtLimC   AS Date       // Data limite de credito
    
    //Parametros da API
    cServer   := SuperGetMv("MV_IPSRV",.F.,"54.233.177.56")
    cPort     := SuperGetMv("MV_PORTSRV",.F.,"9608")
    cAmbiente := SuperGetMv("MV_APIAMBI",.F.,"HOMOLOGACAO")
    cURI      := "http://" + cServer + ":" + cPort
    cResource := SuperGetMv("MV_RAPIPRD",.F.,"/crm/saveConta")
    cID       := "zD20190403H111753080R000000005"
    aHeader   := {}
    cAlias    := GetNextAlias()
    lIntegr   := .F.

    //Monta o Cabeçalho da requisição
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    //Montagem do Objeto para retorno do JSON
    If lLote
    
    Else
        //Query para seleção da NF
        cQry := " Select * " + CRLF
        cQry += " From "+RetSqlName("SA1")+" SA1" + CRLF
        cQry += " Where SA1.D_e_l_e_t_ = ' ' " + CRLF
        cQry += "   And SA1.A1_FILIAL  = '"+FwXFilial('SA1')+"'"+ CRLF
        cQry += "   And SA1.A1_COD  = '"+cCodCli+"'"
        cQry += "   And SA1.A1_LOJA    = '"+cLjCli+"'"
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())

        If (cAlias)->(!Eof())
            While (cAlias)->(!Eof())
                cDtNasc := Iif(!Empty((cAlias)->A1_DTNASC),SubStr((cAlias)->A1_DTNASC,1,4)+"-"+SubStr((cAlias)->A1_DTNASC,5,2)+"-"+SubStr((cAlias)->A1_DTNASC,7,2),"")
                cDtLimC := Iif(!Empty((cAlias)->A1_VENCLC),SubStr((cAlias)->A1_VENCLC,1,4)+"-"+SubStr((cAlias)->A1_VENCLC,5,2)+"-"+SubStr((cAlias)->A1_VENCLC,7,2),"")
                //Prepara o Objeto para cada NF a ser enviada
                oBody := JsonObject():New()
                
                //Montagem do cabeçalho da nota
                oBody['id_service']                             := cID
                oBody['environment']                            := cAmbiente          
                oBody['tipo']                                   := 'Cliente'
                oBody['crm_conta.isInactive']                   := Iif((cAlias)->A1_MSBLQL=='1',.T.,.F.)
                oBody['crm_conta.Documento_tipo']               := Iif((cAlias)->A1_PESSOA=='F','CPF','CNPJ')
                oBody['crm_conta.nome']                         := Alltrim((cAlias)->A1_NREDUZ)
                oBody['crm_conta.razaosocial']                  := Alltrim((cAlias)->A1_NOME)
                oBody['crm_conta_cliente.validalimitecredito']  := GetMv("MV_BLOQUEI")
                oBody['crm_conta_cliente.PermiteRemeter']       := .T.
                oBody['crm_conta_cliente.PermiteFaturar']       := Iif((cAlias)->A1_MSBLQL=='2',.T.,.F.)
                oBody['crm_conta_protheus.tipoCliente']         := Alltrim((cAlias)->A1_TIPO)
                oBody['crm_endereco.id_conta']                  := Alltrim((cAlias)->A1_END)
                oBody['crm_conta.codigo']                       := Alltrim((cAlias)->A1_COD)
                oBody['crm_conta.Documento']                    := Alltrim((cAlias)->A1_CGC)
                oBody['crm_conta.FoneFax']                      := Alltrim((cAlias)->A1_DDD)+Alltrim((cAlias)->A1_FAX)
                oBody['crm_conta.FoneOffice']                   := Alltrim((cAlias)->A1_DDD)+Alltrim((cAlias)->A1_TEL)
                oBody['crm_conta.WebSite']                      := Alltrim((cAlias)->A1_HPAGE)
                oBody['crm_conta.datafundacao']                 := cDtNasc
                oBody['crm_conta_cliente.datavencimentocredito']:= cDtLimC
                oBody['crm_conta_cliente.valorlimitecredito']   := (cAlias)->A1_LC
                oBody['crm_endereco.Bairro']                    := Alltrim((cAlias)->A1_BAIRRO)
                oBody['crm_endereco.CEP']                       := Alltrim((cAlias)->A1_CEP)
                oBody['crm_endereco.Complemento']               := Alltrim((cAlias)->A1_COMPLEM)
                oBody['crm_endereco.Logradouro']                := Alltrim((cAlias)->A1_END)
                oBody['crm_endereco.numero']                    := Alltrim(Str(Val((cAlias)->A1_END)))
                oBody['crm_conta_cliente.codVendedor']          := Alltrim((cAlias)->A1_VEND)
                If IsInCallStack("A030Deleta")
                    oBody['crm_conta.isDeleted'] := .T.
                Else
                    oBody['crm_conta.isDeleted'] := .F.
                Endif
                
                //Executa o método de envio POST e valida o retorno
                oRest := FwRest():New(cURI)   
                oRest:nTimeOut:= 60 //Segundos
                oRest:SetPath(cResource)
                oRest:SetPostParams(oBody:ToJson()) 
                If (oRest:Post(aHeader))
                    ConOut("POST: " + oRest:GetResult())
                    lIntegr := .T.
                Else
                    ConOut("POST: " + oRest:GetLastError())
                    lIntegr := .F.
                EndIf
                
                //Posiciona no registro novamente para garantir a gravação no registro correto
                DbSelectArea('SA1')
                aAreaA1 := SA1->(GetArea())
                DbSetOrder(1)
                SA1->(DbGotop())
                If DbSeek(FwXfilial('SA1')+Padr(cCodCli,TamSx3("A1_COD")[1])+cLjCli)
                    if SA1->(FieldPos("A1_XAFXSTA")>0)
                        if SA1->(RecLock("SA1",.F.))
                            If lIntegr 
                                SA1->A1_XAFXSTA := "I"
                                If FwJsonDeserialize(oRest:CRESULT,@oJson)
                                    cMsgResp := oRest:GetLastError()
                                    cMsgResp += " - "
                                    cMsgResp += oJson:SUCCESS+CRLF
                                    cMsgResp += ""+CRLF
                                    cMsgResp += oRest:CPOSTPARAMS
                                    SA1->A1_XAFXMSG := cMsgResp
                                else
                                    cMsgResp := oRest:GetResult()+CRLF
                                    cMsgResp += ""+CRLF
                                    cMsgResp += oRest:CPOSTPARAMS
                                    SA1->A1_XAFXMSG := cMsgResp
                                Endif
                            Else
                                SA1->A1_XAFXSTA := "E"
                                If FwJsonDeserialize(oRest:CRESULT,@oJson)
                                    cMsgResp := oRest:GetLastError() +CRLF
                                    cMsgResp += "" +CRLF
                                    cMsgResp += oJson:ERROR +CRLF
                                    cMsgResp += "" +CRLF
                                    cMsgResp += oRest:CPOSTPARAMS
                                    SA1->A1_XAFXMSG := cMsgResp
                                else
                                    cMsgResp := oRest:GetResult()+CRLF
                                    cMsgResp += "" +CRLF
                                    cMsgResp += oRest:CPOSTPARAMS
                                    SA1->A1_XAFXMSG := cMsgResp
                                Endif
                            Endif
                            SA1->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaA1)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Endif
    (cAlias)->(DbCloseArea())

Return lIntegr
