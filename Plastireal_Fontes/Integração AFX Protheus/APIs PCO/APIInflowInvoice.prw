#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE TYPE_INTEGRATION    'api'

/*/{Protheus.doc} APIInflowInvoice
    @type class api rest
    @author Rodrigo dos Santos
    @since 25/11/2020
    @version P12
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/

WSRESTFUL APIInflowInvoice DESCRIPTION 'Inflow invoice service' SECURITY 'MATA140' FORMAT APPLICATION_JSON    
    WSMETHOD POST InclusionInflowInvoice;
        DESCRIPTION 'Inclusion of inflow invoice information';
        WSSYNTAX '/InclusionInflowInvoice';
        PATH 'InclusionInflowInvoice';
        PRODUCES APPLICATION_JSON
ENDWSRESTFUL

/*/{Protheus.doc} InclusionInflowInvoice
    M�todo para incluir o documento de entrada pr�-nota
    @type class
    @author Rodrigo dos Santos
    @since 25/11/2020
    @version P12
    @param body json
    @return objeto json
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/
WSMETHOD POST InclusionInflowInvoice WSRECEIVE WSREST APIInflowInvoice
    Local lRet      As Logical       // retorno do m�todo
    Local lSimula   As Logical       // permite simular a opera��o

    Local aArea         As Array    // �rea em uso
    Local aHeader       As Array    // cabe�alho do documento
    Local aItems        As Array    // items do documento
    Local aLinha        As Array    // items do documento (auxiliar)
    Local aLogAuto      As Array    // log de retorno
        
    Local oJson     As J        // body json
    Local oReturn   As J        // retorno json do m�todo

    Local cErro     As Character    // conteudo do erro
    Local cArqLog   As Character    // arquivo de log
    Local cDir      As Character    // diretorio do log
    Local cContent  As Character    // conteudo do log
    Local cError    As Character    // parser

    Local nX        As Numeric  // contador do item
    Local nY        As Numeric  // contador do log
    Local nOpcao    As Numeric  // op��o da rotina autom�tica
    Local nTelaAuto As Numeric  // controle de tela
    
    Private lMsErroAuto     As Logical 
    Private lMsHelpAuto     As Logical
    Private lAutoErrNoFile  As Logical

    lRet    := .T.
    
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
    cError        := ''

    nX          := 0
    nY          := 0
    nOpcao      := 3
    nTelaAuto   := 0
    
    lMsErroAuto     := .F.
    lMsHelpAuto     := .T.
    lAutoErrNoFile  := .T.
    lSimula         := .F.

    /*
    ir� carregar os dados vindos no corpo da requisi��o...
    */
    cError := oJson:FromJson(Self:GetContent())

    /*
    verifico se o json est� v�lido
    */
    IF .NOT. Empty(cError)
        SetRestFault(400,'Json parse error')
        lRet    := .F.
        Return(lRet)
    EndIF

    /*
    header do documento de entrada / pre nota
    */
    aAdd(aHeader,{'F1_FILIAL',  xFilial('SF1'),                                     NIL})
    aAdd(aHeader,{'F1_TIPO',    oJson['header']:GetJsonObject('invoicetype'),       NIL})
    aAdd(aHeader,{'F1_FORMUL',  oJson['header']:GetJsonObject('ownform'),           NIL})
    aAdd(aHeader,{'F1_DOC',     oJson['header']:GetJsonObject('invoice'),           NIL})
    aAdd(aHeader,{'F1_SERIE',   oJson['header']:GetJsonObject('series'),            NIL})
    aAdd(aHeader,{'F1_EMISSAO', Date(),                                             NIL})
    aAdd(aHeader,{'F1_FORNECE', oJson['header']:GetJsonObject('supplier'),          NIL})
    aAdd(aHeader,{'F1_LOJA',    oJson['header']:GetJsonObject('unit'),              NIL})
    aAdd(aHeader,{'F1_ESPECIE', oJson['header']:GetJsonObject('typeofdocument'),    NIL})
    aAdd(aHeader,{'F1_COND',    oJson['header']:GetJsonObject('paymentterm'),       NIL})
    aAdd(aHeader,{'F1_STATUS',  '',                                                 NIL})

    For nX  := 1 To Len(oJson['items'])
        aLinha  := {}
        aAdd(aLinha,{'D1_COD',      oJson['items'][nX]:GetJsonObject('product'),             NIL})
        aAdd(aLinha,{'D1_QUANT',    oJson['items'][nX]:GetJsonObject('quantity'),            NIL})
        aAdd(aLinha,{'D1_VUNIT',    oJson['items'][nX]:GetJsonObject('unitvalue'),           NIL})
        aAdd(aLinha,{'D1_TOTAL',    oJson['items'][nX]:GetJsonObject('grandtotal'),          NIL})
        aAdd(aLinha,{'D1_PEDIDO',   oJson['items'][nX]:GetJsonObject('purchaseorder'),       NIL})
        aAdd(aLinha,{'D1_ITEMPC',   oJson['items'][nX]:GetJsonObject('purchaseorderitem'),   NIL})
        /*
        1-rateio,2-sem rateio
        Ocorre uma falha estranha no ambiente piloto PlastiReal...
        No momento de classificar o documento, ocorre a altera��o do rateio para sim, ignorando o inicializador padr�o, ser� necess�rio abrir um chamado no padr�o...
        Por�m no meu ambiente (release 27 rpo + lib + bin�rio), o problema n�o ocorre.... =)
        */
        IF oJson['items'][nX]:GetJsonObject('apportionment') == 1
            aAdd(aLinha,{'D1_RATEIO',   '1',       NIL})
        ELSE
            aAdd(aLinha,{'D1_RATEIO',   '2',       NIL})
        EndIF
        aAdd(aItems,aLinha)
    Next nX

    /*
    MATA140 - Pr� nota
    aHeader-Array-Cabe�alho
    aItems-Array-Itens da nota
    nOpcao-3-Inclus�o,4-Altera��o,5-Exclus�o,7-Estorno da classifica��o
    lSimula-L�gico-.T. simula,.F.desabilita
    nTelaAuto-Num�rico-0-N�o mostra tela,1-Mostra a tela,2-Mostra tela e valida somente cabe�alho
    MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)
    */
    MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)},aHeader,aItems,nOpcao,lSimula,nTelaAuto)
        
    IF lMsErroAuto

        cArqLog     := oJson['header']:GetJsonObject('series')+'-'+oJson['header']:GetJsonObject('invoice')+'-'+ProcName()+'-H'+SubStr(Time(),1,2)+"-M"+SubStr(Time(),4,2)+'.log'
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
        Gera��o de log...
        */
        U_LogDirectory(cDir,.F.,cArqLog,cErro,FunName(),ProcName(),TYPE_INTEGRATION)

        SetRestFault(500,cErro)
        lRet    := .F.
        Return(lRet)
    ELSE

        /*
        cria��o do arquivo de log...
        */
        cArqLog := SF1->F1_SERIE+'-'+SF1->F1_DOC+'-'+ProcName()+'-H'+SubStr(Time(),1,2)+"-M"+SubStr(Time(),4,2)+'.log'

        /*
        conte�do do arquivo...
        */
        cContent := 'Processo:'+ProcName()+'-ID:'+SF1->F1_SERIE+'/'+SF1->F1_DOC+'-Data:'+DTOS(Date())+'-Hora:'+SubStr(Time(),1,2)+':'+SubStr(Time(),4,2)
            
        /*
        Diretorio primario...
        */
        cDir := SuperGetMV('DIRINTEGRA',.F.,'\log_integration\')
            
        /*
        Gera��o de log...
        */
        U_LogDirectory(cDir,.T.,cArqLog,cContent,FunName(),ProcName(),TYPE_INTEGRATION)

        /*
        � idiom�tico em REST retornarmos as informa��es do registro criado
        */
        oReturn := JsonObject():New()
        oReturn['id']       := AllTrim(SF1->F1_SERIE)+'/'+AllTrim(SF1->F1_DOC)
        oReturn['message']  := 'record sucessfully saved'
            
        /*
        Iremos retornar o json de forma serializada, e defini��o do codigo http, com 201, ou seja, criado...
        */
        Self:SetStatus(201)
        Self:SetContentType(APPLICATION_JSON)
        Self:SetResponse(FWJsonSerialize(oReturn))
    EndIF
    /*
    Liberar mem�ria...
    */
    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)

Return(lRet)
