#INCLUDE "PROTHEUS.CH"

User Function ITQTDMPP(nQtdMPP)

Local cPrdt := M->C2_PRODUTO
Local nQtdMPP := M->C2_XMATPRI
Local aArea := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery     := ""

cQuery += " SELECT SUM(G1_QUANT) QUANT " + CRLF
cQuery += " FROM " + RetSQLName("SG1") + CRLF
cQuery += " WHERE G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
cQuery += " AND G1_COD = '" + cPrdt + "' " + CRLF
cQuery += " AND G1_XMATPR = '1' " + CRLF
cQuery += " AND D_E_L_E_T_ = '' " + CRLF

dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
nQtdMPP := (nQtdMPP/(cAliasQry)->QUANT)

RestArea(aArea)

Return nQtdMPP
