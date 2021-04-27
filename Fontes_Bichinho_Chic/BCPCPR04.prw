#include 'protheus.ch'
#include 'parmtype.ch'

//-------------------------------------------------\\
/*/{Protheus.doc} BCPCPR04
//TODO Rotina para impressão de etiqueta de produto,
       a partir da ordem de produção.
@author Claudio Macedo
@since 10/08/2020
@version 1.0
@type Function
/*/
//-------------------------------------------------\\
User Function BCPCPR04()

Local cPerg    := PADR('BCPCPR04',10)
Local cPorta   := 'LPT1' 
Local cNumOP   := ''
Local cNumOP1  := ''
Local cNumOP2  := ''
Local nI       := 0

If !Pergunte(cPerg, .T., 'Informe os Parâmetros')
	MsgInfo('Cancelado pelo usuário.')
	Return Nil
Endif

MSCBPRINTER('ZEBRA',cPorta,,50,.F.,,,,,,)
MSCBCHKSTATUS(.F.)

If SC2->(DbSeek(xFilial('SC2') + mv_par01))
	
	cNumOP := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + '   1'
    cNumOP1 := SUBSTR(cNumOP,1,10)
    cNumOP2 := SUBSTR(cNumOP,11,1)

	for nI := 1 to mv_par02
		
		MSCBBEGIN(1,6) 	
		MSCBWRITE("CT~~CD,~CC^~CT~")
		MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ")
		MSCBWRITE("^XA")
		MSCBWRITE("^MMT")
		MSCBWRITE("^PW400")
		MSCBWRITE("^LL0240")
		MSCBWRITE("^LS0")
		MSCBWRITE("^FO11,7^GB376,221,3^FS")
		MSCBWRITE("^FT28,50^A0N,37,40^FH\^FDOP "+SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN+"^FS")
		MSCBWRITE("^BY1,3,48^FT75,202^BCN,,Y,N")
		MSCBWRITE("^FD>;"+cNumOP1+">6"+cNumOP2+"   >71777747774^FS")
		MSCBWRITE("^PQ1,0,1,Y^XZ")


			//MSCBSAYBAR(28,3,cNumOP,'MB07','C',8.36,.F.,.T.,.F.,,2,1)

		MSCBEND()

	next nI
	
Endif

MSCBCLOSEPRINTER()

Return Nil

