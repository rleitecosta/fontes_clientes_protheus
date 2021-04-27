#include "totvs.ch"

static lE1XFORMPG    as logical

//------------------------------------------------------------------------------------------------
    /*/
        Funcao:u_fa060qry()
        Autor:Marinaldo de Jesus [CONNECTTI]
        Data:28/01/2019
        Descricao:Este Ponto de Entrada e chamado nas funcoes Fa060Borde e Fa061Borde para adicao
                  de filtro SQL
    /*/
//------------------------------------------------------------------------------------------------
function u_fa060qry() as character

    local aFilter       as array
    local aParamBox     as array
    local aParamRet     as array

    local cFilter       as character
    local cParamTit     as character
    local cFilterSQL    as character

    local nFilter       as numeric

    local lParamBox     as logical

    saveInter()

    begin sequence

        DEFAULT lE1XFORMPG:=SE1->(FieldPos("E1_XFORMPG")>0)

        if (!(lE1XFORMPG))
            break
        endif

        private cCadastro    as character
        cCadastro:="Deseja complementar o Filtro do Bordedô?"

        aFilter:=array(0)
        aAdd(aFilter,OemToAnsi("1-Filtro Forma de Pagamento"))
        aAdd(aFilter,OemToAnsi("2-Filtro Avançado"))

        aParamBox:=array(0)
        aAdd(aParamBox,{9,"Informe o Tipo de Filtro",150,7,.T.})
        aAdd(aParamBox,{2,"Selecione o Tipo de Filtro",0,aFilter,100,"",.F.})

        cParamTit:="Filtro"
        lParamBox:=ParamBox(@aParamBox,@cParamTit,@aParamRet)

        if !(lParamBox)
            break
        endif

        cFilter:=if(valtype(aParamRet[2])=="N",aFilter[aParamRet[2]],allTrim(aParamRet[2]))
        nFilter:=val(left(cFilter,1))

        cFilterSQL:=fa060qry(nFilter)

    end sequence

    restInter()

    DEFAULT cFilterSQL:="1=1"

    return(cFilterSQL)

static function fa060qry(nFilter as numeric) as character

    local cFilterSQL    as character

    begin sequence

        if (nFilter==1)
            cFilterSQL:=fa060qry1()
            break
        endif

        cFilterSQL:=fa060qry2()

    end sequence

    if (empty(cFilterSQL))
        cFilterSQL:="1=1"
    endif

    return(cFilterSQL)

static function fa060qry1() as character

    local aFilter       as array
    local aParamBox     as array
    local aParamRet     as array

    local cAlias        as character
    local cFilter       as character
    local cParamTit     as character
    local cFilterSQL    as character

    local nFilter       as numeric
    local nFilters      as numeric
    local nSX5RecNo     as numeric

    local lParamBox     as logical

    begin sequence

        DEFAULT lE1XFORMPG:=SE1->(FieldPos("E1_XFORMPG")>0)

        if (!(lE1XFORMPG))
            break
        endif

        cAlias:=getNextAlias()

        beginsql alias cAlias
            SELECT SX5.R_E_C_N_O_ SX5RECNO
             FROM %table:SX5% SX5
            WHERE SX5.%notDel%
              AND SX5.X5_FILIAL=%xFilial:SX5%
              AND SX5.X5_TABELA='24'
         ORDER BY SX5.X5_FILIAL,SX5.X5_TABELA,SX5.X5_CHAVE
        endsql

        aFilter:=array(0)
        while (cAlias)->(!eof())
            nSX5RecNo:=(cAlias)->SX5RECNO
            SX5->(dbGoTo(nSX5RecNo))
            aAdd(aFilter,{SX5->X5_CHAVE,SX5->X5_DESCRI})
            (cAlias)->(dbSkip())
        end while

        (cAlias)->(dbCloseArea())

        private cCadastro    as character
        cCadastro:="Selecione as Formas de Pagamento?"

        aParamBox:=array(0)
        nFilters:=len(aFilter)
        for nFilter:=1 to nFilters
            aAdd(aParamBox,array(7))
            aParamBox[nFilter][1]:=4//[1] : 4 - CheckBox ( Com Say )
            aParamBox[nFilter][2]:=aFilter[nFilter][2]//[2] : Descricao
            aParamBox[nFilter][3]:=.F.//[3] : Indicador Logico contendo o inicial do Check
            aParamBox[nFilter][4]:=aFilter[nFilter][1]//[4] : Texto do CheckBox
            aParamBox[nFilter][5]:=100//[5] : Tamanho do Radio
            aParamBox[nFilter][6]:="allWaysTrue()"//[6] : Validacao
            aParamBox[nFilter][7]:=.F.//[7] : Flag .T./.F. Parametro Obrigatorio ?
        next nFilter

        cParamTit := "Filtro"
        lParamBox := ParamBox(@aParamBox,@cParamTit,@aParamRet)

        if !(lParamBox)
            break
        endif

        cFilter:=""
        for nFilter:=1 to nFilters
            if (aParamRet[nFilter])
                cFilter+=("'"+aFilter[nFilter][1]+"'")
                cFilter+=if(aParamRet[min((nFilter+1),nFilters)],",","")
            endif
        next nFilter

        if (Right(cFilter,1)==",")
            cFilter:=Substr(cFilter,1,(len(cFilter)-1))
        endif

        if (empty(cFilter))
            break
        endif

        cFilterSQL:=(" E1_XFORMPG IN("+cFilter+") AND E1_XSTITAU != 1 ")

    end sequence

    if (empty(cFilterSQL))
        cFilterSQL:="E1_XSTITAU != 1"
    endif

    return(cFilterSQL)

static function fa060qry2() as character

    local cFilterSQL    as character

    local oWnd          as object
    local oFWFilter     as object

    begin sequence

        oWnd:=getWNDDefault()
        oFWFilter:=FWFilter():New(oWnd,{||.T.})

        oFWFilter:SetAlias("SE1")

        oFWFilter:LoadFilter()

        oFWFilter:DisableSave(.T.)

        oFWFilter:Activate(oWnd,.T.)

        cFilterSQL:=oFWFilter:getExprSQL()
        if (empty(cFilterSQL))
            cFilterSQL:="E1_XSTITAU != 1"
        endif

        oFWFilter:SaveFilter()
        oFWFilter:CleanFilter(.F.)
        oFWFilter:DeActivate()

    end sequence

    if (empty(cFilterSQL))
        cFilterSQL:="E1_XSTITAU != 1"
    endif

    return(cFilterSQL)
