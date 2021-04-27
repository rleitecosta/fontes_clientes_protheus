#include "totvs.ch"

static lE1XFORMPG   as logical
static lE1XE4COD    as logical
static lE1XE4COND   as logical
static lE1XE4TIPO   as logical

static lE4XFORMPG   as logical

//------------------------------------------------------------------------------------------------
    /*/
        Funcao:u_m040se1()
        Autor:Marinaldo de Jesus [CONNECTTI]
        Data:28/01/2019
        Descricao:Este Ponto de Entrada e chamado na funcao A040DupRec durante a geracao de duplicatas
    /*/
//------------------------------------------------------------------------------------------------
function u_m040se1() as logical

    local cStack    as character

    local lm040se1  as logical

    begin sequence

        cStack:="A460DUPL"
        if (!IsInCallStack(cStack))
            cStack:="MANFS2FIN"
            if (!IsInCallStack(cStack))
                break
            endif
        endif

        DEFAULT lE1XFORMPG:=SE1->(FieldPos("E1_XFORMPG")>0)

        if (!(lE1XFORMPG))
            break
        endif

        DEFAULT lE4XFORMPG:=SE4->(FieldPos("E4_XFORMPG")>0)

        if (!(lE4XFORMPG))
            break
        endif

        if (SE1->(eof().or.bof()))
            break
        endif

        lm040se1:=m040se1()

    end sequence

    DEFAULT lm040se1:=.F.

    return(lm040se1)

static function m040se1() as logical

    local aFormPg   as array

    local cStack    as character
    local cFormPg   as character

    local lm040se1  as logical
    local lFLocked  as logical
    local lIsLocked as logical

    local nFormPg   as numeric

    cStack:="A460DUPL"
    if (!IsInCallStack("A460DUPL"))
        cStack:="MANFS2FIN"
    endif

    if (!(type("nA460DUPLC")=="N"))
        _SetNamedPrvt("nA460DUPLC",0,cStack)
    endif

    if (!(type("cA460C5NUM")=="C"))
        _SetNamedPrvt("cA460C5NUM",SC5->C5_NUM,cStack)
    endif

    if (!(SC5->C5_NUM==&("cA460C5NUM")))
        &("nA460DUPLC"):=0
    endif

    aFormPg:=StrTokArr2(allTrim(SE4->E4_XFORMPG),",")

    &("nA460DUPLC")+=1

    nFormPg:=min(&("nA460DUPLC"),len(aFormPg))

    cFormPg:=if(nFormPg>0,aFormPg[nFormPg],"")
    lm040se1:=!empty(cFormPg)

    lFLocked:=findFunction("IsLocked")

    lIsLocked:=((lFLocked).and.(SE1->(IsLocked("SE1"))))

    if (!lIsLocked)
        SE1->(recLock("SE1",.F.))
    endif

    SE1->E1_XFORMPG:=cFormPg

    DEFAULT lE1XE4COD:=SE1->(FieldPos("E1_XE4COD")>0)

    if (lE1XE4COD)
        SE1->E1_XE4COD:=SE4->E4_CODIGO
    endif

    DEFAULT lE1XE4COND:=SE1->(FieldPos("E1_XE4COND")>0)

    if (lE1XE4COND)
        SE1->E1_XE4COND:=SE4->E4_COND
    endif

    DEFAULT lE1XE4TIPO:=SE1->(FieldPos("E1_XE4TIPO")>0)

    if (lE1XE4TIPO)
        SE1->E1_XE4TIPO:=SE4->E4_TIPO
    endif

    if (!lIsLocked)
        if (lFLocked)
            SE1->(MsUnLock())
        endif
    endif

    return(lm040se1)