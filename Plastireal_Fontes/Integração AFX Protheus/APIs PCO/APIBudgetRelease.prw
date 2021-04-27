#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE TYPE_INTEGRATION    'api'

/*/{Protheus.doc} APIEntries
    @type class api rest
    @author Rodrigo dos Santos
    @since 12/11/2020
    @version P12
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/

WSRESTFUL APIBudgetRelease DESCRIPTION 'Budget release service' SECURITY 'MATA120' FORMAT APPLICATION_JSON    
    WSDATA InitialDate      AS DATE
    WSDATA FinalDate        AS DATE
    WSDATA BudgetaryCenter  AS CHARACTER
    WSDATA CostCenter       AS CHARACTER
    WSMETHOD GET GetBudgetRelease;
        DESCRIPTION 'Recovers budget entry amounts';
        WSSYNTAX '/GetBudgetRelease';
        PATH 'GetBudgetRelease';
        PRODUCES APPLICATION_JSON
ENDWSRESTFUL


/*/{Protheus.doc} GetBudgetRelease
    M�todo para obter valores de lan�amentos or�ament�rios
    @type class
    @author Rodrigo dos Santos
    @since 13/11/2020
    @version P12
    @param initialdate: data inicial no formato AAAA-MM-DD
    @param finaldate: data inicial no formato AAAA-MM-DD
    @param budgetarycenter: conta or�ament�ria
    @param costcenter: centro de custo
    @return objeto json
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/

WSMETHOD GET GetBudgetRelease WSRECEIVE InitialDate, FinalDate, BudgetaryCenter, CostCenter WSREST APIBudgetRelease
    Local lRet As Logical // retorno do m�todo
    
    Local aArea As Array // �rea em uso
        
    Local oJson As J // objeto json de retorno

    Local nCredOR   As Numeric // cr�dito OR
    Local nDebOR    As Numeric // d�bito OR
    Local nCredCT   As Numeric // cr�dito CT
    Local nDebCT    As Numeric // d�bito CT
    Local nCredEM   As Numeric // cr�dito EM
    Local nDebEM    As Numeric // d�bito EM
    Local nCredRE   As Numeric // cr�dito RE
    Local nDebRE    As Numeric // d�bito RE
    Local nTotal    As Numeric // resultado final
    
    lRet    := .T.

    aArea   := GetArea()

    oJson   := JsonObject():New()

    nCredOR := 0
    nDebOR  := 0
    nTotal  := 0
    
    Default InitialDate     := Date()
    Default FinalDate       := Date()
    Default BudgetaryCenter := ''
    Default CostCenter      := ''
    
    /*
    cr�dito OR
    */
    nCredOR := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '1', 'OR')

    /*
    d�bito OR
    */
    nDebOR  := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '2', 'OR')

    /*
    cr�dito CT
    */
    nCredCT := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '1', 'CT')

    /*
    d�bito CT
    */
    nDebCT := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '2', 'CT')

    /*
    cr�dito EM
    */
    nCredEM := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '1', 'EM')

    /*
    d�bito EM
    */
    nDebEM := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '2', 'EM')

    /*
    cr�dito RE
    */
    nCredRE := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '1', 'RE')

    /*
    d�bito EM
    */
    nDebRE := ValueADK(Self:InitialDate, Self:FinalDate, Self:BudgetaryCenter, Self:CostCenter, '2', 'RE')

    /*
    valor final que deve ser apresentado...
    */
    nTotal  := ((nCredOR - nDebOR)+(nCredCT - nDebCT)) - ((nCredEM - nDebEM)+(nCredRE - nDebRE))

    /*
    � idiom�tico em REST retornarmos as informa��es do registro criado
    */
    oJson['result'] := Transform(nTotal,'@E 999,999,999.99')

    /*
    Iremos retornar o json de forma serializada, e defini��o do codigo http, com 201, ou seja, criado...
    */
    Self:SetStatus(201)
    Self:SetContentType(APPLICATION_JSON)
    Self:SetResponse(FWJsonSerialize(oJson))
    
Return(lRet)

Static Function ValueADK(dDtIni As Date, dDtFim As Date, cConta As Character, cCCusto As Character, cTipo As Character, cTipoSaldo As Character) As Numeric
    Local cViewAKD  As Character // View da tabela

    Local nValor    As Numeric // Valor do lan�amento

    Default dDtIni  := Date()
    Default dDtFim  := Date()
    Default cConta  := ''
    Default cCCusto := ''
    Default cTipo   := ''
    Default cTipoSaldo  := ''

    cViewAKD    := GetNextAlias()

    nValor  := 0

    dDtIni  := dtos(dDtIni)
    dDtFim  := dtos(dDtFim)

    BeginSQL Alias cViewAKD
        SELECT SUM(AKD.AKD_VALOR1) AS AKDVALOR1
        FROM %Table:AKD% AKD
        WHERE AKD.%NotDel%
        AND AKD.AKD_DATA BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
        AND AKD_CO = %Exp:AllTrim(cConta)%
        AND AKD_CC = %Exp:AllTrim(cCCusto)%
        AND AKD_TIPO = %Exp:cTipo%
        AND AKD_TPSALD = %Exp:cTipoSaldo% 
        AND AKD_STATUS = %Exp:'1'%
    EndSQL

    IF (cViewAKD)->(.NOT. Eof())
        nValor := (cViewAKD)->AKDVALOR1
    ELSE
        nValor := 0
    EndIF
    
    (cViewAKD)->(dbCloseArea())
Return(nValor)
