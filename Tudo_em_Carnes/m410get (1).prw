#include "totvs.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410GET   บAutor  ณFrank Zwarg Fuga    บ Data ณ  03/02/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega o acols dos pedidos, com os produtos marcados no    บฑฑ
ฑฑบ          ณcampo B1_XALISC6 = S                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function M410GET
Local _aArea 	 := GetArea()
Local _cQuery	 := ""        
Local cAliasQry
Local _aProdutos := {}
Local _nX
Local _cItem
Local _nConta	 := 0 
Local _cNum
Local _cProduto

If !IsBlind()

If !ALTERA 
	Return
EndIF          

_cQuery := "select B1_XALISC6, B1_COD, B1_DESC, B1_UM from "+ RetSqlName("SB1")
_cQuery += " where B1_FILIAL='"+ xFilial("SB1") +"'"
_cQuery += " and B1_XALISC6 <> ''"
_cQuery += " and D_E_L_E_T_ = ' '"
cAliasQry := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TCGENQRY(,, _cQuery), cAliasQry, .T., .T. )
					
While ! (cAliasQry)->( EOF() )
    aadd(_aProdutos,{(cAliasQry)->B1_XALISC6,(cAliasQry)->B1_COD,(cAliasQry)->B1_DESC,(cAliasQry)->B1_UM })
	(cAliasQry)->( dbSkip() )	
EndDo
					
(cAliasQry)->( dbCloseArea() )

_cItem := space(tamsx3("C6_ITEM")[1])
For _nX := 1 to Len(aCols)  
	If !aCols[_nX][len(aHeader)+1]
 		_cItem := aCols[_nX][01]
 	EndIf
 	_nConta ++
Next

_aProdutos := asort(_aProdutos,,,{|X,Y| x[1] < y[1]})
 
For _nX:=1 to len(_aProdutos)       

	AAdd(aCols,Aclone(aCols[1]))
	aCols[len(aCols)][len(aheader)+1] := .T.
	
        
	_cItem := soma1(_cItem)
	n := _nConta ++ 
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+_aProdutos[_nX][2]))
	
	aCols[len(aCols)][1] := _cItem
	
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})] := _aProdutos[_nX][2]
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_DESCRI"})]  := _aProdutos[_nX][3]
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_UM"})]      := _aProdutos[_nX][4]
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRCVEN"})]  := 0
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})]  := 0
			
	SB5->(dbSetOrder(1))
	SB5->(dbSeek(xFilial("SB5")+_aProdutos[_nX][2]))
			
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_REVPROD"})] 	:= SB5->B5_VERSAO                                                                                      
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_SERVIC"})]  	:= SB5->B5_SERVSAI 
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_ENDPAD"})]  	:= SB5->B5_ENDSAI 
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CC"})]  		:= SB1->B1_CC      
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CONTA"})]	:= SB1->B1_CONTA  
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_ITEMCTA"})]	:= SB1->B1_ITEMCC
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CLVL"})]		:= SB1->B1_CLVL   
	aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_OPER"})]		:= "01"
			
	n ++
	U_XA410P(_aProdutos[_nX][2])
	RunTrigger(2,n,nil,,'C6_PRODUTO')
		
Next


n := 1

EndIf
RestArea(_aArea)

Return 
