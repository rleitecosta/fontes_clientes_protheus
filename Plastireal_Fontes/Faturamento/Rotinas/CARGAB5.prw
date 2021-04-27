#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"


User Function CARGAB5()
Local cQuery :=""
Local xAlias := GetNextAlias()




    
    cQuery += "SELECT SB1.B1_FILIAL FILIAL, SB1.B1_COD COD, SB1.B1_DESC DESCR FROM SB1010 SB1 WHERE SB1.D_E_L_E_T_ = ' ' "       
    cQuery += "AND SB1.B1_COD NOT IN (SELECT SB5.B5_COD FROM SB5010 SB5 WHERE SB5.D_E_L_E_T_ = ' ')         "
    
    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),xAlias,.t.,.t.)

    DBSelectArea(xAlias)
    (xAlias)->(dbgotop())
    While (xAlias)->(!Eof())

        DBSelectArea("SB5")
        RecLock("SB5",.T.)
        SB5->B5_FILIAL:=(xAlias)->FILIAL 
        SB5->B5_COD  := (xAlias)->COD
        SB5->B5_CEME := (xAlias)->DESCR


        DBSelectArea(xAlias)
        (xAlias)->(dbSkip())
    EndDo
    (xAlias)->(dbCloseArea())
    


Return