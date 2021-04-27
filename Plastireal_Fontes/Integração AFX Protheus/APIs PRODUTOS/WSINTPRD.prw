
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} WSINTPRD
    Método para envio da estrutura JSON contendo dados do produto
    @type class
    @author Carlos H. Fernandes
    @since 26/01/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - http://54.233.177.56:9608/stk/saveItem 
    @obs Uso PlastReal
/*/
User Function WSINTPRD(cCodPrd,lLote,aDadosSB5)
    //------------------------------------------------------------------------------------------------
    // Estrutura modelo: Type JSON
    // {
    //     "id_service": "zD20190403H111753080R000000005",
    //     "environment": "HOMOLOGACAO", //HOMOLOGACAO | PRODUCAO | {vazio é produção}
    //     "tipo": "Prod Acab",
    //     "stk_item.codigo": "000001",
    //     "stk_item.descricao": "CODIT",
    //     "stk_item.id_unidademedida": "{0549E922-2EAD-4526-9EA2-EBD238CB7B20}",
    //     "stk_item_produto.EAN": "923802398"
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
    Local oBody     AS J          // Envio do corpo JSON
    Local oItens    AS J          // Objeto de itens da nota
    Local aHeader   AS Array      // Cabeçalho para requisição
    Local aAreaB1   AS Array      // Preserva area

    DEFAULT aDadosSB5 := {}
    
If ! IsBlind()  
    //Parametros da API
    cServer   := SuperGetMv("MV_IPSRV",.F.,"54.233.177.56")
    cPort     := SuperGetMv("MV_PORTSRV",.F.,"9608")
    cAmbiente := SuperGetMv("MV_APIAMBI",.F.,"HOMOLOGACAO")
    cURI      := "http://" + cServer + ":" + cPort
    cResource := SuperGetMv("MV_RAPIPRD",.F.,"/stk/saveItem")
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
        cQry += " From "+RetSqlName("SB1")+" SB1" + CRLF
        cQry += " Inner Join "+RetSqlName("SB5")+" SB5" + CRLF
        cQry += "         On B5_FILIAL = B1_FILIAL" + CRLF
        cQry += "        And B5_COD = B1_COD" + CRLF
        cQry += "        And SB5.D_e_l_e_t_ = ' '" + CRLF
        cQry += " Where SB1.D_e_l_e_t_ = ' ' " + CRLF
        cQry += "   And SB1.B1_FILIAL  = '"+FwXFilial('SB1')+"'"+ CRLF
        cQry += "   And SB1.B1_COD     = '"+cCodPrd+"'"
        DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cAlias) , .F., .T. )
        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())

        If (cAlias)->(!Eof())
            While (cAlias)->(!Eof())
                //Prepara o Objeto para cada NF a ser enviada
                oBody := JsonObject():New()
                
                //Montagem do cabeçalho da nota
                oBody['id_service']                             := cID
                oBody['environment']                            := cAmbiente          
                oBody['tipo']                                   := "Material"
                oBody['stk_item.isInactive']                    := Iif((cAlias)->B1_ATIVO=='S','false','true')
                oBody['stk_item.codigo']                        := (cAlias)->B1_COD
                oBody['stk_item.descricao']                     := (cAlias)->B1_DESC
                oBody['stk_item.id_unidademedida']              := (cAlias)->B1_UM
                oBody['stk_item.id_tipoitem']                   := (cAlias)->B1_TIPO
                oBody['stk_item_produto.EAN']                   := (cAlias)->B1_CODBAR
                oBody['stk_item_produto.pesoKG']                := (cAlias)->B1_PESO
                oBody['stk_item_produto.tipoProduto']           := (cAlias)->B1_BASE3
                oBody['stk_item_produto.tipoMaterial']          := (cAlias)->B1_DESBSE3
                oBody['stk_item_produto.prtPercIPI']            := (cAlias)->B1_IPI
                oBody['stk_item_produto.id_classeMaterial']     := (cAlias)->B1_CLASMAT
                oBody['fis_item_produto_fiscal.id_icms_origem'] := (cAlias)->B1_ORIGEM
                oBody['stk_item_produto.codigoPadrao3']         := (cAlias)->B1_PAD3
                //oBody['stk_item_produto.prtCusto']              := (cAlias)->B1_CUSTOD
                oBody['stk_item_produto.QtdEstoqueSeguranca']   := (cAlias)->B1_ESTSEG
                oBody['stk_item_produto.QtdRestMinima']         := (cAlias)->B1_EMIN
                //oBody['stk_item_produto.id_localestoque_3']     := (cAlias)->B1_LOCPAD
                If !Empty(aDadosSB5)
                 oBody['stk_item_produto.prtLargura']            := aDadosSB5[1][1]//(cAlias)->B5_LARG
                 oBody['stk_item_produto.prtComprimento']        := aDadosSB5[1][2]//(cAlias)->B5_COMPR
                 oBody['stk_item_produto.prtEspessura']          := aDadosSB5[1][3]//(cAlias)->B5_ESPESS
                 oBody['stk_item_produto.prtCor']                := aDadosSB5[1][4]//(cAlias)->B5_XCOR
                 oBody['stk_item_produto.prtDiametroInterno']    := aDadosSB5[1][5]//(cAlias)->B5_DIAINT
                 oBody['stk_item_produto.prtDiametroExterno']    := aDadosSB5[1][6]// (cAlias)->B5_DIAEXT
                Else
                 oBody['stk_item_produto.prtLargura']            := (cAlias)->B5_LARG
                 oBody['stk_item_produto.prtComprimento']        := (cAlias)->B5_COMPR
                 oBody['stk_item_produto.prtEspessura']          := (cAlias)->B5_ESPESS
                 oBody['stk_item_produto.prtCor']                := (cAlias)->B5_XCOR
                 oBody['stk_item_produto.prtDiametroInterno']    := (cAlias)->B5_DIAINT
                 oBody['stk_item_produto.prtDiametroExterno']    := (cAlias)->B5_DIAEXT
                EndIf
                If IsInCallStack("A010Deleta")
                    oBody['stk_item.isDeleted'] := 'true'
                Else
                    oBody['stk_item.isDeleted'] := 'false'
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
                DbSelectArea('SB1')
                aAreaB1 := SB1->(GetArea())
                DbSetOrder(1)
                SB1->(DbGotop())
                If DbSeek(FwXfilial('SB1')+cCodPrd)
                    if SB1->(FieldPos("B1_XAFXSTA")>0)
                        if SB1->(RecLock("SB1",.F.))
                            If lIntegr 
                                SB1->B1_XAFXSTA := "I"
                            Else
                                SB1->B1_XAFXSTA := "E"
                            Endif
                            SB1->(MsUnLock())
                        endif
                    endif
                Endif
                RestArea(aAreaB1)
                
                //Libera o Objeto
                FreeObj(oBody)
                Sleep( 2000 )
                (cAlias)->(DbSkip())
            EndDo
        Endif
    Endif
    (cAlias)->(DbCloseArea())
Endif

Return lIntegr
