#INCLUDE "Protheus.CH" 
#include "RWMake.CH"
#include "TOTVS.CH"  
#include "PRTOPDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PagSum   บAutor  ณ Joใo Carlos        บ Data ณ  28/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o valor total do Sispag                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOCABENS                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

User Function PAGSUM()  

Local aArea	 :=	GetArea()
Local nValor :=	SOMAVALOR()
Local nDesc	 :=	0
Local nJuros :=	0

cQuery := " SELECT SUM(SE2.E2_XDESCON) AS VALDESC, SUM(SE2.E2_XJUROS) AS VALJUR  " + CRLF
cQuery += " FROM " +	RetSqlName("SE2") + " SE2 (NOLOCK) " + CRLF
cQuery += " WHERE  SE2.E2_FILIAL = '"+ xFilial("SE2")+"' AND (SE2.E2_NUMBOR BETWEEN '"	+ MV_PAR01 + "' AND '"  + MV_PAR02 +  "') AND SE2.D_E_L_E_T_ <> '*' "

cAliasQry := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )

If !EoF() .AND. ( (cAliasQry)->VALDESC > 0 .Or. (cAliasQry)->VALJUR > 0 )

	nDesc	:=	(cAliasQry)->VALDESC
	nJuros	:=	(cAliasQry)->VALJUR
	
EndIf

DBCloseArea()

RestArea(aArea)

nValor	-= (nDesc*100)		
nValor	+= (nJuros*100)


Return(StrZero(nValor,17))