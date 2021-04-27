
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSINTFOR
    Método para envio da estrutura JSON contendo dados de Vendedores
    @type function
    @author Leandro Schumann Thomaz
    @since 05/02/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - http://endereço:porta/crm/saveVendedor
    @obs Uso PlastReal
/*/
User Function WSINTVEN(cCodVen,lLote,lDeleta)
    //------------------------------------------------------------------------------------------------
    // Estrutura modelo: Type JSON
    /*
    {
    "id_service": "zD20190403H111753080R000000005",   
    "environment": "HOMOLOGACAO", //HOMOLOGACAO | PRODUCAO | {vazio é produção}
    "cms_vendedor.codigo": "000001",
    "cms_vendedor.descricao": "Rodrigo Lourenço",
    "cms_vendedor.email": "rodrigo@codit.com.br",
    "cms_vendedor.comissaovendedor": 15.7
    }
    (exemplo)*/


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
    Local aAreaA3   AS Array      // Preserva area

    
    //Parametros da API
    cServer   := SuperGetMv("MV_IPSRV",.F.,"54.233.177.56")
    cPort     := SuperGetMv("MV_PORTSRV",.F.,"9608")
    cAmbiente := SuperGetMv("MV_APIAMBI",.F.,"HOMOLOGACAO")
    cURI      := "http://" + cServer + ":" + cPort
    cResource := SuperGetMv("MV_RAPIPRD",.F.,"/crm/saveVendedor")
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
    
    Else
        //Query para seleção do Fornecedor
        cQry := " SELECT A3_MSBLQL,A3_COD ,A3_NOME,A3_EMAIL ,"  + CRLF
        cQry += " A3_COMIS,A3_CGC,A3_GRPREP "                             + CRLF
        cQry += " FROM "+RetSqlName("SA3")+" SA3"               + CRLF
        cQry += " Where  "                                      + CRLF
        cQry += " SA3.A3_FILIAL  = '"+XFilial('SA3')+"'"        + CRLF
        If !lDeleta
            cQry += "   And  SA3.D_E_L_E_T_ = ' ' "             + CRLF
        Endif
        cQry += "   And SA3.A3_COD     = '"+cCodVen+"'"         + CRLF
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())

        If (cAlias)->(!Eof())
            While (cAlias)->(!Eof())
            
                DbSelectArea("ACA")
                DbSetOrder(1)
                DbSeek(XFilial("ACA")+(cAlias)->A3_GRPREP)
                //Prepara o Objeto para cada Fornecedor a ser enviado
                oBody := JsonObject():New()
                cJson     :=cURI+"/"+cResource + CRLF
                cJson     +="{ "+ CRLF
                
                oBody['id_service']                            := cID
                cJson     +='"id_service": "'+cID+'",'+ CRLF
                oBody['environment']                           := cAmbiente          
                cJson     +='"environment": "'+cAmbiente+'",'+ CRLF
                oBody['cms_vendedor.isInactive']                := Iif((cAlias)->A3_MSBLQL=='1',"true","false")
                cJson     +='"cms_vendedor.isInactive": '+iif((cAlias)->A3_MSBLQL=='1','"true"','"false"')+','+ CRLF
                If lDeleta
                    oBody['cms_vendedor.isDeleted']                := "true"
                    cJson     +='"cms_vendedor.isDeleted": "true",'+ CRLF
                Else
                    oBody['cms_vendedor.isDeleted']                := "false"
                    cJson     +='"cms_vendedor.isDeleted": "false",'+ CRLF
                Endif                
                oBody['cms_vendedor.descricao']                        := ALLTRIM((cAlias)->A3_NOME)
                cJson     +='"cms_vendedor.descricao": "'+ALLTRIM((cAlias)->A3_NOME)+'",'+ CRLF
                oBody['cms_vendedor.email']                 := ALLTRIM((cAlias)->A3_EMAIL)
                cJson     +='"cms_vendedor.email": "'+ALLTRIM((cAlias)->A3_EMAIL)+'",'+ CRLF
                oBody['cms_vendedor.codigo']                      := ALLTRIM((cAlias)->A3_COD)
                cJson     +='"cms_vendedor.codigo": "'+ALLTRIM((cAlias)->A3_COD)+'",'+ CRLF
                oBody['cms_vendedor.comissaovendedor']                   := (cAlias)->A3_COMIS
                cJson     +='"cms_vendedor.comissaovendedor": '+str((cAlias)->A3_COMIS)+','+ CRLF // Campo Numérico
                oBody['cms_vendedor.equipe']                  := ALLTRIM(ACA_DESCRI)
                cJson     +='"cms_vendedor.equipe": "'+ALLTRIM(ACA_DESCRI)+'",'+ CRLF
                oBody['cms_vendedor.documento']                     := ALLTRIM((cAlias)->A3_CGC)
                cJson     +='"cms_vendedor.documento": "'+ALLTRIM((cAlias)->A3_CGC)+'"'+ CRLF
                //oBody['cms_vendedor.tipoDocumento']              := iif((cAlias)->  == 'F',"CPF", "CNPJ")
                //cJson+='"cms_vendedor.tipoDocumento": '+iif((cAlias)->  == 'F','"CPF"', '"CNPJ"')+','+ CRLF
               
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
                DbSelectArea('SA3')
                aAreaA3 := SA3->(GetArea())
                DbSetOrder(1)//
                SA3->(DbGotop())
                If DbSeek(FwXfilial('SA3')+cCodVen)
                    if SA3->(FieldPos("A3_XAFXSTA")>0)
                        if SA3->(RecLock("SA3",.F.))
                            If lIntegr 
                                SA3->A3_XAFXSTA := "I"
                                If ValType(cTextJson) == "C"
                                    SA3->A3_XAFXMSG := SA3->A3_XAFXMSG + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Else
                                SA3->A3_XAFXSTA := "E"
                                If ValType(cTextJson) == "C"
                                    SA3->A3_XAFXMSG := SA3->A3_XAFXMSG + " log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson
                                EndIf
                            Endif
                            SA3->(MsUnLock())
                        endif
                    endif
                ElseIf lDeleta // Ao deletar, atualiza o log mesmo assim
                          /*              
                    TCLink()
                    //Atualizo o log mesmo que deletado
                    nStatus := TCSqlExec("UPDATE "+RetSqlName("SA2")+"  SET A2_XAFXMSG = A2_XAFXMSG +'log: "+Subs(dtos(date()),7,2)+"/"+Subs(dtos(date()),5,2)+"/"+Subs(dtos(date()),1,4)+" "+Time()+" JSON:"+ cJson+" msg -> "+cTextJson+"' WHERE A2_COD = '"+cCodVen+"' AND D_E_L_E_T_ = '*' " )
   
                    if (nStatus < 0)
                        conout("TCSQLError() " + TCSQLError())
                    endif*/
                Endif
                RestArea(aAreaA3)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Endif
    (cAlias)->(DbCloseArea())

Return lIntegr
