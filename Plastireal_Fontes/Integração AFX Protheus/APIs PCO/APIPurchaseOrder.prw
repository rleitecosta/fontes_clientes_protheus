#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE TYPE_INTEGRATION    'api'

/*/{Protheus.doc} APIPurchaseOrder
    @type class api rest
    @author Rodrigo dos Santos
    @since 05/11/2020
    @version P12
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/

WSRESTFUL APIPurchaseOrder DESCRIPTION 'Purchase order service' SECURITY 'MATA120' FORMAT APPLICATION_JSON    
    WSMETHOD POST InclusionPurchaseOrder;
        DESCRIPTION 'Inclusion of purchase order information';
        WSSYNTAX '/InclusionPurchaseOrder';
        PATH 'InclusionPurchaseOrder';
        PRODUCES APPLICATION_JSON
    WSMETHOD DELETE DeletePurchaseOrder;
        DESCRIPTION 'Delete purchase order information';
        WSSYNTAX '/DeletePurchaseOrder';
        PATH 'DeletePurchaseOrder';
        PRODUCES APPLICATION_JSON
ENDWSRESTFUL

/*/{Protheus.doc} InclusionPurchaseOrder
    Método para incluir o pedido de compra
    @type class
    @author Rodrigo dos Santos
    @since 05/11/2020
    @version P12
    @param body json
    @return objeto json
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/
WSMETHOD POST InclusionPurchaseOrder WSRECEIVE WSREST APIPurchaseOrder
    Local lRet  As Logical       // retorno do método
    Local lPed  As Logical       // numeração automática

    Local aArea         As Array    // área em uso
    Local aHeader       As Array    // cabeçalho do pedido
    Local aItems        As Array    // items do pedido
    Local aLinha        As Array    // items do pedido (auxiliar)
    Local aLogAuto      As Array    // log de retorno
    Local aRateioCC     As Array    // items do rateio de centro de custo
    Local aRateioPrj    As Array    // items do rateio de projeto
    
    Local oJson     As J        // body json
    Local oReturn   As J        // retorno json do método

    Local cErro     As Character    // conteudo do erro
    Local cArqLog   As Character    // arquivo de log
    Local cPedido   As Character    // numero do pedido enviado
    Local cDir      As Character    // diretorio do log
    Local cContent  As Character    // conteudo do log

    Local nX        As Numeric  // contador do item
    Local nY        As Numeric  // contador do log
    Local nOpcao    As Numeric  // opção da rotina automática
    Local nPCAE     As Numeric  // PC ou AE

    Private lMsErroAuto     As Logical 
    Private lMsHelpAuto     As Logical
    Private lAutoErrNoFile  As Logical

    lRet    := .T.
    lPed    := .T.

    aArea         := GetArea()
    aHeader       := {}
    aItems        := {}
    aLinha        := {}
    aLogAuto      := {}
    aRateioCC     := {}
    aRateioPrj    := {}   

    oJson   := JsonObject():New()
    oReturn := JsonObject():New()

    cErro         := ''
    cArqLog       := ''
    cPedido       := ''
    cDir          := ''
    cContent      := ''

    nX      := 0
    nY      := 0
    nOpcao  := 3
    nPCAE   := 0

    lMsErroAuto     := .F.
    lMsHelpAuto     := .T.
    lAutoErrNoFile  := .T.

    /*
    irá carregar os dados vindos no corpo da requisição...
    */
    oJson:FromJson(Self:GetContent())

    /*
    1 - pedido de compra; 2 - autorização de entrega
    */
    nPCAE   := oJson['header']:GetJsonObject('pcae') // 1 - pedido de compra; 2-autorização de entrega

    /*
    caso nao seja definido o conteudo esperado, ou o conteudo seja 2, irá apresentar a exceção...
    */
    IF Empty(oJson['header']:GetJsonObject('pcae')) .OR. oJson['header']:GetJsonObject('pcae') == 2
        SetRestFault(400,'type of integration not defined or deal for delivery authorization not available')
        lRet    := .F.
        Return(lRet)
    EndIF

    /*
    é obrigatório informar o fornecedor, loja, emissao, condição de pagamento, contato e filial de entrega...
    */
    IF Empty(oJson['header']:GetJsonObject('suppliercode')) .OR. Empty(oJson['header']:GetJsonObject('supplierunit'))
        SetRestFault(400,'Providercode and providerunit is mandatory')
        lRet    := .F.
        Return(lRet)
    EndIF

    /*
    caso o fornecedor exista, inicia o processo para rotina automática...
    */
    SA2->(dbSetOrder(1))
    IF (SA2->(dbSeek(xFilial('SA2')+PadR(oJson['header']:GetJsonObject('suppliercode'),TamSX3('A2_COD')[1])+PadR(oJson['header']:GetJsonObject('supplierunit'),TamSX3('A2_LOJA')[1]))))
        
        /*
        tenta obter o numero do pedido...
        caso o pedido não tenha sido informado, fará a geração de forma automática...
        */
        IF Empty(AllTrim(oJson['header']:GetJsonObject('purchaseordernumber')))
            cPedido := GetSxeNum('SC7','C7_NUM')
            lPed := .F.
        ELSE
            cPedido := AllTrim(oJson['header']:GetJsonObject('purchaseordernumber'))
        EndIF        

        aAdd(aHeader,{'C7_NUM',     cPedido                                                         }) 
        aAdd(aHeader,{'C7_EMISSAO', Date()                                                          })
        aAdd(aHeader,{'C7_FORNECE', AllTrim(oJson['header']:GetJsonObject('suppliercode'))          })
        aAdd(aHeader,{'C7_LOJA',    AllTrim(oJson['header']:GetJsonObject('supplierunit'))          })
        aAdd(aHeader,{'C7_COND',    AllTrim(oJson['header']:GetJsonObject('paymentcode'))           })
        aAdd(aHeader,{'C7_CONTATO', AllTrim(oJson['header']:GetJsonObject('contact'))               })
        aAdd(aHeader,{'C7_FILENT',  AllTrim(oJson['header']:GetJsonObject('branchfordelivery'))     })
        /*
        C-CIF,F-FOB,T-Por conta de terceiros,R-Por conta de remetentes,D-Por conta do destinatario,S-Sem frete
        CIF-Não informa transportadora e loja e informa valor do frete
        FOB-Não informa valor, mas informa transportadora e loja
        T,R,D,S-Não informa valor e nem transportadora
        */
        IF .NOT. Empty(AllTrim(oJson['header']:GetJsonObject('freightype')))
            aAdd(aHeader,{'C7_TPFRETE', AllTrim(oJson['header']:GetJsonObject('freightype'))            })
            IF AllTrim(oJson['header']:GetJsonObject('freightype')) == 'C'
                aAdd(aHeader,{'C7_FRETE', oJson['header']:GetJsonObject('agreedfreightvalue')            })
            ELSEIF AllTrim(oJson['header']:GetJsonObject('freightype')) == 'F'
                aAdd(aHeader,{'C7_FRETE', AllTrim(oJson['header']:GetJsonObject('carriercode'))            })    
                aAdd(aHeader,{'C7_FRETE', AllTrim(oJson['header']:GetJsonObject('carrierstore'))            })
            EndIF
        EndIF

        For nX  := 1 To Len (oJson['items'])
            aLinha  := {}
            aAdd(aLinha,{'C7_PRODUTO',  AllTrim(oJson['items'][nX]:GetJsonObject('product')),               NIL})
            aAdd(aLinha,{'C7_ITEM',     AllTrim(oJson['items'][nX]:GetJsonObject('item')),                  NIL})
            aAdd(aLinha,{'C7_QUANT',    oJson['items'][nX]:GetJsonObject('lossquantity'),                   NIL})
            aAdd(aLinha,{'C7_PRECO',    oJson['items'][nX]:GetJsonObject('unitpriceofitem'),                NIL})
            aAdd(aLinha,{'C7_TOTAL',    oJson['items'][nX]:GetJsonObject('itemtotalvalue'),                 NIL})
            /*
            caso nao tenha rateio, preenche conta e centro de custo no item...
            */
            IF AllTrim(oJson['items'][nX]:GetJsonObject('costapportionment'))=='2'
                aAdd(aLinha,{'C7_CONTA',    AllTrim(oJson['items'][nX]:GetJsonObject('productledgeraccount')),  NIL})
                aAdd(aLinha,{'C7_CC',       AllTrim(oJson['items'][nX]:GetJsonObject('costcenter')),            NIL})
                Else
                aAdd(aLinha,{'C7_CONTA',     "",      NIL})
                aAdd(aLinha,{'C7_CC',        "",      NIL})
                aAdd(aLinha,{'C7_RATEIO',    "1",     NIL})
            EndIF
            IF .NOT. Empty(oJson['items'][nX]:GetJsonObject('deliverydate'))
                xDelivery   := StrTran(oJson['items'][nX]:GetJsonObject('deliverydate'),'-','')
                xDelivery   := stod(xDelivery)
                aAdd(aLinha,{'C7_DATPRF',   xDelivery,   NIL})
            EndIF
            aAdd(aItems,aLinha)

            /*
            rateio do centro de custo...
            */
            IF AllTrim(oJson['items'][nX]:GetJsonObject('costapportionment'))=='1'
                //IF Len(oJson['items'][nX]['costcenteritems']) > 0    
                    aAdd(aRateioCC,Array(2))

                    //aRateioCC[Len(aRateioCC)][1] := AllTrim(oJson['items'][nX]:GetJsonObject('item'))
                    //aRateioCC[Len(aRateioCC)][2] := {}
                    
                    aRateioCC[1][1] := AllTrim(oJson['items'][nX]:GetJsonObject('item'))
                    aRateioCC[1][2] := {}

                    For nY := 1 To Len(oJson['items'][nX]['costcenteritems'])
                        aLinha := {}
                        aAdd(aLinha,{'CH_FILIAL',   xFilial('SCH'),                                                                         NIL})
                        aAdd(aLinha,{'CH_ITEM',     Padl(nY,TamSX3('CH_ITEM')[1],'0'),                                                      NIL})
                        aAdd(aLinha,{'CH_PERC',     oJson['items'][nX]['costcenteritems'][nY]:GetJsonObject('percentage'),                  NIL})
                        aAdd(aLinha,{'CH_CC',       AllTrim(oJson['items'][nX]['costcenteritems'][nY]:GetJsonObject('costcenter')),         NIL})
                        aAdd(aLinha,{'CH_CONTA',    AllTrim(oJson['items'][nX]['costcenteritems'][nY]:GetJsonObject('ledgeraccount')),      NIL})
                        aAdd(aLinha,{'CH_ITEMCTA',  AllTrim(oJson['items'][nX]['costcenteritems'][nY]:GetJsonObject('ledgeraccountitem')),  NIL})
                        aAdd(aLinha,{'CH_CLVL',     AllTrim(oJson['items'][nX]['costcenteritems'][nY]:GetJsonObject('accountvlclass')),     NIL})
                       // aAdd(aRateioCC[Len(aRateioCC)][2],aClone(aLinha))
                         aAdd(aRateioCC[1][2],aClone(aLinha))
                    Next nY
                //EndIF
            EndIF

            /*
            rateio do projeto...
            */
            IF AllTrim(oJson['items'][nX]:GetJsonObject('projectapportionment'))=='1'
                //IF Len(oJson['items'][nX]['projectitems']) > 0                    
                    aAdd(aRateioPrj,Array(2))
                    
                    aRateioPrj[Len(aRateioPrj)][1] := AllTrim(oJson['items'][nX]:GetJsonObject('product'))
                    aRateioPrj[Len(aRateioPrj)][2] := {}

                    nY := 0

                    For nY := 1 To Len(oJson['items'][nX]['projectitems'])
                        aLinha := {}
                        aAdd(aLinha,{'AJ7_FILIAL',  xFilial('AJ7'),                                                                      NIL})
                        aAdd(aLinha,{'AJ7_PROJET',  AllTrim(oJson['items'][nX]['projectitems'][nY]:GetJsonObject('projectcode')),        NIL})
                        aAdd(aLinha,{'AJ7_TAREFA',  oJson['items'][nX]['projectitems'][nY]:GetJsonObject('taskcode'),                    NIL})
                        aAdd(aLinha,{'AJ7_NUMPC',   cPedido,                                                                             NIL})
                        aAdd(aLinha,{'AJ7_ITEMPC',  AllTrim(oJson['items'][nX]['projectitems'][nY]:GetJsonObject('purchaseorderitem')),  NIL})
                        aAdd(aLinha,{'AJ7_COD',     AllTrim(oJson['items'][nX]['projectitems'][nY]:GetJsonObject('productcode')),        NIL})
                        aAdd(aLinha,{'AJ7_QUANT',   oJson['items'][nX]['projectitems'][nY]:GetJsonObject('projectquantity'),             NIL})
                        aAdd(aLinha,{'AJ7_REVISA',  AllTrim(oJson['items'][nX]['projectitems'][nY]:GetJsonObject('projectversion')),     NIL})
                        aAdd(aRateioPrj[Len(aRateioPrj)][2],aClone(aLinha))
                    Next nY
                //EndIF   
            EndIF        
        Next nX

        /*
        MATA120 - Pedido de Compras ( [ ExpN1 ] [ ExpA1 ] [ ExpA2 ] [ ExpN2 ] [ ExpL1 ] [ ExpA3] [ ExpA4 ] [ ExpA5 ])
        ExpN1-Numérico-Pedido de compra ou autorização de entrega
        ExpA1-Array-Cabeçalho do PC ou AE
        ExpA2-Array-Itens do PC ou AE
        ExpN2-Numérico-Opção da rotina automática (3-Inclusão,4-Alteração,5-Exclusão)
        ExpL1-Lógico-Apresenta tela da rotina automática
        ExpA3-Array-Rateio do centro de custo
        ExpA4-Reservado
        ExpA5-Array-Rateio do projeto
        MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e,f,,g)},nPCAE,aHeader,aItems,nOpcao,.F.,aRateioCC,aRatPrj)
        */        
        MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e,f,g)},nPCAE,aHeader,aItems,nOpcao,.F.,aRateioCC,aRateioPrj)

        IF lMsErroAuto

            /*
            rollback na numeração automática
            */
            IF .NOT. lPed
                RollBackSX8()
            EndIF

            cArqLog     := oJson['header']:GetJsonObject('suppliercode')+oJson['header']:GetJsonObject('supplierunit')+'-'+ProcName()+'-'+SubStr(Time(),1,2)+"-"+SubStr(Time(),4,2)+'.log'
            aLogAuto    := {}
            aLogAuto    := GetAutoGrLog()
            For nY := 1 To Len(aLogAuto)
                cErro += aLogAuto[nY] + CRLF
            Next nY
            
            /*
            Diretorio primario...
            */
            cDir := SuperGetMV('DIRINTEGRA',.F.,'\log_integration\')

            /*
            Geração de log...
            */
            U_LogDirectory(cDir,.F.,cArqLog,cErro,FunName(),ProcName(),TYPE_INTEGRATION)

            SetRestFault(500,cErro)
            lRet    := .F.
            Return(lRet)
        ELSE
            
            /*
            confirmação da numeração automática...
            */
            IF .NOT. lPed
                ConfirmSX8()
            EndIF

            /*
            criação do arquivo de log...
            */
            cArqLog := ProcName()+'-'+SC7->C7_NUM+'.log'

            /*
            conteúdo do arquivo...
            */
            cContent := 'Processo:'+ProcName()+'-ID:'+SC7->C7_NUM+'-Data:'+DTOS(Date())+'-Hora:'+SubStr(Time(),1,2)+':'+SubStr(Time(),4,2)
            
            /*
            Diretorio primario...
            */
            cDir := SuperGetMV('DIRINTEGRA',.F.,'\log_integration\')
            
            /*
            Geração de log...
            */
            U_LogDirectory(cDir,.T.,cArqLog,cContent,FunName(),ProcName(),TYPE_INTEGRATION)

            /*
            É idiomático em REST retornarmos as informações do registro criado
            */
            oReturn := JsonObject():New()
            oReturn['id']       := AllTrim(SC7->C7_NUM)
            oReturn['message']  := 'record sucessfully saved'
            
            /*
            Iremos retornar o json de forma serializada, e definição do codigo http, com 201, ou seja, criado...
            */
            Self:SetStatus(201)
            Self:SetContentType(APPLICATION_JSON)
            Self:SetResponse(FWJsonSerialize(oReturn))
        EndIF
        /*
        Liberar memória...
        */
        RestArea(aArea)
        FreeObj(oJson)
        FreeObj(oReturn)
    /*
    Fornecedor não foi encontrado.... apresenta exceção...
    */
    ELSE
        /*
        Retorno da exceção...
        */
        SetRestFault(400,'Suppliercode not found')
        lRet := .F.
        Return(lRet)
    EndIF

Return(lRet)

/*/{Protheus.doc} DeletePurchaseOrder
    Método para excluir o pedido de compra
    @type class
    @author Rodrigo dos Santos
    @since 06/11/2020
    @version P12
    @param body json
    @return objeto json
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/
WSMETHOD DELETE DeletePurchaseOrder WSRECEIVE WSREST APIPurchaseOrder
    Local lRet As Logical

    Local aArea     As Array
    Local aHeader   As Array       
    Local aItems    As Array
    Local aLinha    As Array
    Local aLogAuto  As Array

    Local oJson     As J
    Local oReturn   As J

    Local cErro     As Character
    Local cArqLog   As Character
    Local cDir      As Character
    Local cContent  As Character

    Local nX        As Numeric
    Local nY        As Numeric
    Local nOpcao    As Numeric
    Local nPCAE     As Numeric

    Private lMsErroAuto     As Logical
    Private lMsHelpAuto     As Logical
    Private lAutoErrNoFile  As Logical

    lRet  := .T.

    aArea         := GetArea()
    aHeader       := {}
    aItems        := {}
    aLinha        := {}
    aLogAuto      := {}

    oJson   := JsonObject():New()
    oReturn := JsonObject():New()

    cErro         := ''
    cArqLog       := ''
    cDir          := ''
    cContent      := ''

    nX      := 0
    nY      := 0
    nOpcao  := 5
    nPCAE   := 0

    lMsErroAuto     := .F.
    lMsHelpAuto     := .T.
    lAutoErrNoFile  := .T.

    /*
    irá carregar os dados vindos no corpo da requisição...
    */
    oJson:FromJson(Self:GetContent())

    /*
    1 - pedido de compra; 2 - autorização de entrega
    */
    nPCAE   := oJson['header']:GetJsonObject('pcae') // 1 - pedido de compra; 2-autorização de entrega

    /*
    caso nao seja definido o conteudo esperado, ou o conteudo seja 2, irá apresentar a exceção...
    */
    IF Empty(oJson['header']:GetJsonObject('pcae')) .OR. oJson['header']:GetJsonObject('pcae') == 2
        SetRestFault(400,'type of integration not defined or deal for delivery authorization not available')
        lRet    := .F.
        Return(lRet)
    EndIF

    /*
    é obrigatório informar o pedido...
    */
    IF Empty(oJson['header']:GetJsonObject('purchaseordernumber'))
        SetRestFault(400,'Purchaseordernumber is mandatory')
        lRet    := .F.
        Return(lRet)
    EndIF

    /*
    Caso o pedido exista, inicia o processo para rotina automática...
    */
    SC7->(dbSetOrder(1))
    IF (SC7->(dbSeek(xFilial('SC7')+PadR(oJson['header']:GetJsonObject('purchaseordernumber'),TamSX3('C7_NUM')[1]))))
        aHeader := {}
        aItems  := {}

        aAdd(aHeader,{'C7_NUM',     SC7->C7_NUM     }) 
        aAdd(aHeader,{'C7_FORNECE', SC7->C7_FORNECE })
        aAdd(aHeader,{'C7_LOJA',    SC7->C7_LOJA    })
        aAdd(aHeader,{'C7_COND',    SC7->C7_COND    })
        aAdd(aHeader,{'C7_FILENT',  SC7->C7_FILENT  })
        aAdd(aHeader,{'C7_MOEDA',   SC7->C7_MOEDA   })
        aAdd(aHeader,{'C7_TXMOEDA', SC7->C7_TXMOEDA })

        For nX  := 1 To Len (oJson['items'])
            aLinha  := {}
            aAdd(aLinha,{'C7_ITEM',     StrZero(nX,4),                                              NIL})
            aAdd(aLinha,{'C7_PRODUTO',  AllTrim(oJson['items'][nX]:GetJsonObject('product')),       NIL})
            aAdd(aLinha,{'C7_QUANT',    oJson['items'][nX]:GetJsonObject('lossquantity'),           NIL})
            aAdd(aLinha,{'C7_PRECO',    oJson['items'][nX]:GetJsonObject('unitpriceofitem'),        NIL})
            aAdd(aLinha,{'C7_TOTAL',    oJson['items'][nX]:GetJsonObject('itemtotalvalue'),         NIL})
            aAdd(aLinha,{'C7_CONTA',    oJson['items'][nX]:GetJsonObject('productledgeraccount'),   NIL})
            aAdd(aLinha,{'C7_CC',       oJson['items'][nX]:GetJsonObject('costcenter'),             NIL})
            aAdd(aLinha,{'C7_REC_WT',   SC7->(Recno()),                                             NIL})
            aAdd(aLinha,{'AUTDELETA',   'S',                                                        NIL})
            aAdd(aItems,aLinha)
        Next nX

        /*
        Aqui contempla as opções de rateio de centro de custo e projetos...
        MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e,f,,g)},nPCAE,aHeader,aItems,nOpcao,.F.,aRatCC,aRatPrj)
        */

        MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},nPCAE,aHeader,aItems,nOpcao,.F.)

        IF lMsErroAuto

            cArqLog     := AllTrim(oJson['header']:GetJsonObject('purchaseordernumber'))+'-'+ProcName()+'-'+SubStr(Time(),1,2)+"-"+SubStr(Time(),4,2)+'.log'
            aLogAuto    := {}
            aLogAuto    := GetAutoGrLog()
            For nY := 1 To Len(aLogAuto)
                cErro += aLogAuto[nY] + CRLF
            Next nY
            
            /*
            Diretorio primario...
            */
            cDir := SuperGetMV('DIRINTEGRA',.F.,'\log_integration\')

            /*
            Geração de log...
            */
            U_LogDirectory(cDir,.F.,cArqLog,cErro,FunName(),ProcName(),TYPE_INTEGRATION)

            SetRestFault(500,cErro)
            lRet    := .F.
            Return(lRet)
        ELSE
            cArqLog := ProcName()+'-'+AllTrim(oJson['header']:GetJsonObject('purchaseordernumber'))+'.log'

            cContent := 'Processo:'+ProcName()+'-ID:'+AllTrim(oJson['header']:GetJsonObject('purchaseordernumber'))+'-Data:'+DTOS(Date())+'-Hora:'+SubStr(Time(),1,2)+':'+SubStr(Time(),4,2)

            // diretorio primario
            cDir := SuperGetMV('DIRINTEGRA',.F.,'\log_integration\')

            // geração de log
            U_LogDirectory(cDir,.T.,cArqLog,cContent,FunName(),ProcName(),TYPE_INTEGRATION)

            /*
            É idiomático em REST retornarmos as informações do registro criado
            */
            oReturn := JsonObject():New()
            oReturn['id']       := AllTrim(oJson['header']:GetJsonObject('purchaseordernumber'))
            oReturn['message']  := 'record sucessfully deleted'
            /*
            Iremos retornar o json de forma serializada, e definição do codigo htto, com 201, ou seja, criado...
            */
            Self:SetStatus(201)
            Self:SetContentType(APPLICATION_JSON)
            Self:SetResponse(FWJsonSerialize(oReturn))
        EndIF
        /*
        Liberar memória...
        */
        RestArea(aArea)
        FreeObj(oJson)
        FreeObj(oReturn)
    /*
    Fornecedor não foi encontrado.... apresenta exceção...
    */
    ELSE
        SetRestFault(400,'Purchaseordernumber not found')
        lRet := .F.
        Return(lRet)
    EndIF

Return(lRet)
