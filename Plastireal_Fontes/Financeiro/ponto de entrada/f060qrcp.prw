#include "totvs.ch"
//------------------------------------------------------------------------------------------------
    /*/
        Funcao:u_f060qrcp()
        Autor:Marinaldo de Jesus [CONNECTTI]
        Data:28/01/2019
        Descricao:Este Ponto de Entrada e chamado nas funcoes Fa060Borde e Fa061Borde para adicao
                  de campos na Query da tabela SE1
    /*/
//------------------------------------------------------------------------------------------------
function u_f060qrcp() as character
    local cQuery as character
    begin sequence
        if (!type("ParamIXB")=="A")
            break
        endif
        if (!len(&("ParamIXB"))>=1)
            break
        endif
        cQuery:=&("ParamIXB")[1]
        cQuery:=f060qrcp(cQuery)
    end sequence
    DEFAULT cQuery:="SELECT SE1.* FROM "+retSQLName("SE1")+" WHERE SE1.D_E_L_E_T_=' '"
    return(cQuery)

static function f060qrcp(cQuery as character) as character
    DEFAULT cQuery:=cQuery
    return(cQuery)