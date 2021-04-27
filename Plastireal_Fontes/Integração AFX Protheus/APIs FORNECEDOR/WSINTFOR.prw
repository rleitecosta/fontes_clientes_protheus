
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSINTFOR
    Método para envio da estrutura JSON contendo dados do Fornecedor
    @type function
    @author Leandro Schumann Thomaz
    @since 03/02/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - http://endereço:porta/crm/saveConta
    @obs Uso PlastReal
/*/
User Function WSINTFOR(cCodFor,lLote,lDeleta)
    //------------------------------------------------------------------------------------------------
    // Estrutura modelo: Type JSON
    // {
    //"id_service": "zD20190403H111753080R000000005",
    //"environment": "HOMOLOGACAO", //HOMOLOGACAO | PRODUCAO | {vazio é produção}
    //"tipo": "Fornecedor",
    //"crm_conta.codigo": "000011",
    //"crm_conta.nome": "CODIT",
    //"crm_conta.razaosocial": "CODIT Tecnologia da LTDA",
    //"crm_conta.Documento_tipo": "CNPJ"
    // }

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
    Local aAreaA2   AS Array      // Preserva area
    
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
    cJson     :=""
    
    
    
    //Monta o Cabeçalho da requisição
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    //Montagem do Objeto para retorno do JSON
    If lLote
    
    Else
        //Query para seleção do Fornecedor
        cQry := " SELECT A2_TIPO,A2_NREDUZ,A2_NOME,A2_COD,"     + CRLF
        cQry += " A2_CGC,A2_FAX,A2_TEL,A2_HPAGE,A2_DTNASC,"     + CRLF
        cQry += " A2_BAIRRO,A2_CEP,A2_COMPLEM,A2_END,A2_MSBLQL "+ CRLF
        cQry += " FROM "+RetSqlName("SA2")+" SA2"               + CRLF
        cQry += " Where  "                                      + CRLF
        cQry += " SA2.A2_FILIAL  = '"+XFilial('SA2')+"'"        + CRLF
        cQry += "   And  SA2.D_E_L_E_T_ = ' ' "             + CRLF
        cQry += "   And SA2.A2_COD     = '"+cCodFor+"'"         + CRLF
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
                cJson     +='"id_service": "'+cID+'",'+ CRLF
                oBody['environment']                           := cAmbiente          
                cJson     +='"environment": "'+cAmbiente+'",'+ CRLF
                oBody['tipo']                                  := "Fornecedor"
                cJson     +='"tipo": "Fornecedor",'+ CRLF
                oBody['crm_conta.isInactive']                := Iif((cAlias)->A2_MSBLQL=='1',"true","false")
                cJson     +='"crm_conta.isInactive": '+iif((cAlias)->A2_MSBLQL=='1','"true"','"false"')+','+ CRLF
                If lDeleta
                    oBody['crm_conta.isDelete']                := "true"
                    cJson     +='"crm_conta.isDelete": "true",'+ CRLF
                Else
                    oBody['crm_conta.isDelete']                := "false"
                    cJson     +='"crm_conta.isDelete": "false",'+ CRLF
                Endif
                oBody['crm_conta.Documento_tipo']              := iif((cAlias)->A2_TIPO== 'F',"CPF", "CNPJ")
                cJson+='"crm_conta.Documento_tipo": '+iif((cAlias)->A2_TIPO== 'F','"CPF"', '"CNPJ"')+','+ CRLF
                oBody['crm_conta.nome']                        := ALLTRIM((cAlias)->A2_NREDUZ)
                cJson     +='"crm_conta.nome": "'+ALLTRIM((cAlias)->A2_NREDUZ)+'",'+ CRLF
                oBody['crm_conta.razaosocial']                 := ALLTRIM((cAlias)->A2_NOME)
                cJson     +='"crm_conta.razaosocial": "'+ALLTRIM((cAlias)->A2_NOME)+'",'+ CRLF
                oBody['crm_conta.codigo']                      := ALLTRIM((cAlias)->A2_COD)
                cJson     +='"crm_conta.codigo": "'+ALLTRIM((cAlias)->A2_COD)+'",'+ CRLF
                oBody['crm_conta.Documento']                   := ALLTRIM((cAlias)->A2_CGC)
                cJson     +='"crm_conta.Documento": "'+ALLTRIM((cAlias)->A2_CGC)+'",'+ CRLF
                oBody['crm_conta.FoneFax']                     := ALLTRIM((cAlias)->A2_FAX)
                cJson     +='"crm_conta.FoneFax": "'+ALLTRIM((cAlias)->A2_FAX)+'",'+ CRLF
                oBody['crm_conta.FoneOffice']                  := ALLTRIM((cAlias)->A2_TEL)
                cJson     +='"crm_conta.FoneOffice": "'+ALLTRIM((cAlias)->A2_TEL)+'",'+ CRLF
                oBody['crm_conta.WebSite']                     := ALLTRIM((cAlias)->A2_HPAGE)
                cJson     +='"crm_conta.WebSite": "'+ALLTRIM((cAlias)->A2_HPAGE)+'",'+ CRLF
                oBody['crm_conta.datafundacao']                := ALLTRIM((cAlias)->A2_DTNASC)
                cJson     +='"crm_conta.datafundacao": "'+ALLTRIM((cAlias)->A2_DTNASC)+'",'+ CRLF
                oBody['crm_endereco.Bairro']                   := ALLTRIM((cAlias)->A2_BAIRRO)
                cJson     +='"crm_endereco.Bairro": "'+ALLTRIM((cAlias)->A2_BAIRRO)+'",'+ CRLF
                oBody['crm_endereco.CEP']                      := ALLTRIM((cAlias)->A2_CEP)
                cJson     +='"crm_endereco.CEP": "'+ALLTRIM((cAlias)->A2_CEP)+'",'+ CRLF
                oBody['crm_endereco.Complemento']              := ALLTRIM((cAlias)->A2_COMPLEM)
                cJson     +='"crm_endereco.Complemento": "'+ALLTRIM((cAlias)->A2_COMPLEM)+'",'+ CRLF
                oBody['crm_endereco.Logradouro']               := ALLTRIM((cAlias)->A2_END)
                cJson     +='"crm_endereco.Logradouro": "'+ALLTRIM((cAlias)->A2_END)+'"'+ CRLF
                //oBody['crm_conta_fornecedor.transportadora'] := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.id_conta']               := (cAlias)->
                //cJson     +=""
                //oBody['crm_conta.comentarios']               := (cAlias)->   
                //cJson     +=""
                //oBody['crm_conta.FoneOther']                 := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.id_tipobairro']          := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.comentarios']            := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.id_cidade']              := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.id_estado']              := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.id_pais']                := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.id_tipologradouro']      := (cAlias)->
                //cJson     +=""
                //oBody['crm_endereco.numero']                   := ALLTRIM((cAlias)->A2_END) Inibido pois está estourando o tamanho do campo de número. 
                //cJson     +='"crm_endereco.numero": "'+ALLTRIM((cAlias)->A2_END)+'"'
                //oBody['crm_endereco.referencia']             := (cAlias)->
                //cJson     +=""
                //oBody['Fis_conta_fiscal.InscricaoEstadual']  := (cAlias)->
                //cJson     +=""
               
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
                DbSelectArea('SA2')
                aAreaA2 := SA2->(GetArea())
                DbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
                SA2->(DbGotop())
                If DbSeek(FwXfilial('SA2')+cCodFor)
                    if SA2->(FieldPos("A2_XAFXSTA")>0)
                        if SA2->(RecLock("SA2",.F.))
                            If lIntegr 
                                SA2->A2_XAFXSTA := "I"
                                If ValType(cTextJson) == "C"
                                    SA2->A2_XAFXMSG := SA2->A2_XAFXMSG + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Else
                                SA2->A2_XAFXSTA := "E"
                                If ValType(cTextJson) == "C"
                                    SA2->A2_XAFXMSG := SA2->A2_XAFXMSG + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Endif
                            SA2->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaA2)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Endif
    (cAlias)->(DbCloseArea())

Return lIntegr
