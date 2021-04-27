#include "totvs.ch"
#include "topconn.ch"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁM410INIC  ╨Autor  ЁMicrosiga           ╨ Data Ё  03/02/18   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCarrega o acols dos pedidos, com os produtos marcados no    ╨╠╠
╠╠╨          Ёcampo B1_XALISC6 = S                                        ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
User Function M410INIC     
Local _aArea 	 := GetArea()
Local _cQuery	 := ""        
Local cAliasQry
Local _aProdutos := {}
Local _nX
Local _nItem

If !IsBlind()

If !INCLUI 
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

_aProdutos := asort(_aProdutos,,,{|X,Y| x[1] < y[1]}) 

For _nX:=1 to len(_aProdutos)       

	n := _nX  
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+_aProdutos[_nX][2]))
	
	If _nX == 1
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})] := _aProdutos[_nX][2]	
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_DESCRI"})]  := _aProdutos[_nX][3]
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_UM"})]      := _aProdutos[_nX][4]		
		aCols[_nX][len(aHeader)+1] := .T.   
			
		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5")+_aProdutos[_nX][2]))
			
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_REVPROD"})] := SB5->B5_VERSAO                                                                                      
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_SERVIC"})]  := SB5->B5_SERVSAI 
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_ENDPAD"})]  := SB5->B5_ENDSAI 
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CC"})]  	:= SB1->B1_CC      
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CONTA"})]	:= SB1->B1_CONTA  
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_ITEMCTA"})]	:= SB1->B1_ITEMCC
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CLVL"})]	:= SB1->B1_CLVL   
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_OPER"})]	:= "01"
	        
		a410Produto(_aProdutos[_nX][2])
		
	Else
	
		AAdd(aCols,Aclone(aCols[1]))
		aCols[_nX][1] := strzero(_nX,tamsx3("C6_ITEM")[1] )  
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})] := _aProdutos[_nX][2]
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_DESCRI"})]  := _aProdutos[_nX][3]
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_UM"})]      := _aProdutos[_nX][4]
		
		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5")+_aProdutos[_nX][2]))
			
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_REVPROD"})] := SB5->B5_VERSAO                                                                                      
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_SERVIC"})]  := SB5->B5_SERVSAI 
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_ENDPAD"})]  := SB5->B5_ENDSAI 
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CC"})]  	:= SB1->B1_CC      
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CONTA"})]	:= SB1->B1_CONTA  
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_ITEMCTA"})]	:= SB1->B1_ITEMCC
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_CLVL"})]	:= SB1->B1_CLVL   
		aCols[_nX][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_OPER"})]	:= "01"
			
		a410Produto(_aProdutos[_nX][2])
			
			
	EndIF
	
Next

	
n := 1
          
If Len(_aProdutos) > 0
	//AAdd(aCols,Aclone(aCols[1])) 
	//aCols[len(aCols)][1] := strzero(len(_aProdutos)+1,tamsx3("C6_ITEM")[1] )
	//aCols[len(aCols)][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})] := space(tamsx3("C6_PRODUTO")[1])
	//aCols[len(aCols)][len(aHeader)+1] := .F.
EndIf

EndIf
RestArea(_aArea)
Return 






/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁA410ProdutЁ Autor ЁEduardo Riera          Ё Data Ё 20.02.99 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁEfetua a Valida┤└o do Codigo do Produto e Inicializa as     Ё╠╠
╠╠Ё          Ёvariaveis do acols.                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁExpL1: Se o Produto eh valido                               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpC1: Codigo do Produto                                    Ё╠╠
╠╠Ё          ЁExpL1: Codigo de Barra                                      Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function XA410P(cProduto,lCB)

Local aDadosCfo     := {}

Local lRetorno		:= .T.
Local lContinua		:= .T.
Local lReferencia		:= .F.
Local lDescSubst		:= .F.
Local lGrade			:= MaGrade()
Local lTabCli       	:= (SuperGetMv("MV_TABCENT",.F.,"2") == "1")
Local lGrdMult	  	:= "MATA410" $ SuperGetMV("MV_GRDMULT",.F.,"")

Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPGrade			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_GRADE"})
Local nPItem			:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPItemGrd		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMGRD"})
Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPPrcVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPOpcional		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPC"})
Local nPDescon		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local nPContrat     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONTRAT"})
Local nPItemCon     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMCON"})
Local nPLoteCtl     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPNumLote     	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPEndPad      	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENDPAD"})
Local nPLocal       	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPTes         	:= GdFieldPos("C6_TES")
Local nITEMED 		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEMED"})
Local nCntFor     	:= 0   
Local nPosTes1 		:= 0 

Local nPrcTab			:= 0
Local nBytes 			:= IIf(SuperGetMv("MV_CONSBAR")>Len(SB1->B1_COD),Len(SB1->B1_COD),SuperGetMv("MV_CONSBAR") )

Local cProdRef		:= ""
Local cCFOP			:= Space(Len(SC6->C6_CF))
Local cDescricao		:= ""                                      
Local cCliTab     	:= ""
Local cLojaTab    	:= ""

Local cEstado	  		:= SuperGetMv("MV_ESTADO")
Local cFieldFor		:= "" 

// Indica se o preco unitario sera arredondado em 0 casas decimais ou nao. Se .T. respeita MV_CENT (Apenas Chile).
Local lPrcDec   		:= SuperGetMV("MV_PRCDEC",,.F.)  

If cPaisLoc == "BRA"
	lDescSubst			:= ( IIf( Valtype( mv_par02 ) == "N", ( Iif( mv_par02 == 1, .T., .F. ) ), .F. ) )  //mv_par02 parametro para deduzir ou nao a Subst. Trib.	
EndIf

mv_par01 := If(ValType(mv_par01)==NIL.or.ValType(mv_par01)!="N",1,mv_par01)
mv_par02 := If(ValType(mv_par02)==NIL.or.ValType(mv_par02)!="N",1,mv_par02)

DEFAULT lCb	:= .F.

aColsCCust := aClone(aCols)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCompatibiliza a Entrada Via Codigo de Barra com a Entrada via getdados  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lCB )
	SB1->( DBSetOrder( 1 ) )
	If SB1->( MsSeek(xFilial("SB1")+Substr(aCols[Len(aCols)][nPProduto],1,nBytes),.F.) )
		cProduto := SB1->B1_COD
	Else
		Help(" ",1,"C6_PRODUTO")
		Return .F.
	EndIf
	n := Len(aCols)
Else
	cProduto := IIF(cProduto == Nil,&(ReadVar()),cProduto)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se o Produto foi Alterado                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !( Type("l410Auto") != "U" .And. l410Auto )
	If ( nPOpcional > 0 )
		If ( Empty(aCols[n][nPOpcional]) )
			If ( RTrim(aCols[n][nPProduto]) == RTrim(cProduto) .And. !lCB)
				lContinua := .F.
			EndIf
		ElseIf ( !Empty(aCols[n][nPOpcional]) )
			If ( RTrim(aCols[n][nPProduto]) == RTrim(cProduto) .And. !lCB)
				lContinua := .F.
			EndIf
		EndIf
	Else
		If ( RTrim(aCols[n][nPProduto]) == RTrim(cProduto) .And. !lCB)
			lContinua := .F.
		EndIf
	EndIf
EndIf
cProdRef := cProduto
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica se a grade esta ativa e se o produto digitado eh uma referenciaЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lContinua := .T.
If ( lContinua .And. lGrade )
	lReferencia := MatGrdPrrf(@cProdRef)
	If ( lReferencia )
		If lGrdMult .And. !(MATA410_V() >= 20110131)
			//Final(STR0171)	//"Atualizar MATA410.PRX !!!"
		EndIf
		If ( M->C5_TIPO $ "D" )
			Help(" ",1,"A410GRADEV")
			lContinua := .F.
			lRetorno	 := .T.
		EndIf
		If ( nPGrade > 0 )
			aCols[n][nPGrade] := "S"
			lReferencia := .T.
		EndIf
		aCols[n,nPItemGrd] := StrZero(1,TamSX3("C6_ITEMGRD")[1])
	Else
		If ( nPGrade > 0 )
			aCols[n][nPGrade] := "N"
		EndIf
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta o AcolsGrade e o AheadGrade para este item     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды 
	If IsAtNewGrd()
		oGrade:MontaGrade(n,cProdRef,.T.,,lReferencia,.T.) 
	Else
		MatGrdMont(n,cProdRef,.T.)
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerificar se o Produto eh valido                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lContinua )
	SB1->( DBSetOrder( 1 ) )
	If !lReferencia .And. SB1->( !MsSeek(xFilial("SB1")+cProdRef,.F.) )
		Help(" ",1,"C6_PRODUTO")
		lContinua := .F.
		lRetorno  := .F.
	Else
		If !lReferencia .And. !RegistroOk("SB1")	
			lContinua := .F.
			lRetorno  := .F.
		Endif	
	EndIf
EndIf

If INCLUI .And. !Empty(M->C5_MDCONTR) .And. !Empty(aCols[n,nITEMED]) .And. M->C6_PRODUTO # aCols[n,nPProduto]
	//Aviso(STR0127,STR0128,{"Ok"}) //SIGAGCT - Este pedido foi vinculado a um contrato e por isto nЦo pode ter este campo alterado.
	lContinua := .F.
	lRetorno  := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁChecar se este item do pedido nao foi faturado total -Ё
//Ёmente ou parcialmente                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lContinua .And. ALTERA )
	SC6->( DBSetOrder(1) )
	If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem]+aCols[n][nPProduto]) )
		If ( SC6->C6_QTDENT != 0  .And. cProduto != aCols[n][nPProduto] .And. !lCB )
			Help(" ",1,"A410ITEMFT")
			lRetorno 	:= .F.
			lContinua 	:= .F.
		EndIf
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁChecar se este item do pedido esta amarrado com       Ё
//Ёalguma Ordem de Producao                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lContinua .And. ALTERA )
	SC6->( DBSetOrder(1) )
	If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+aCols[n][nPItem]+aCols[n][nPProduto]) )
		If ( SC6->C6_OP $ "01#03" )
			If (SuperGetMV("MV_ALTPVOP") == "N") .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT") .And. AvIntEmb())
				Help(" ",1,"A410TEMOP")
				lRetorno 	:= .F.
				lContinua 	:= .F.
			EndIf
		EndIf
		If ( SC6->C6_OP == "05" )
			If (SuperGetMV("MV_ALTPVOP") == "N") .And. !(!Empty(SC5->C5_PEDEXP) .And. SuperGetMv("MV_EECFAT") .And. AvIntEmb())
				//Aviso(STR0038,STR0039,{STR0040}) //"Atencao!"###"Este item foi marcado para gerar uma Ordem de Producao mas nao gerou, pois havia saldo disponivel em estoque. Este Pedido de Venda ja comprometeu o saldo necessario."###'Ok'
			EndIf
		EndIf
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica o contrato de parceria                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nPContrat > 0 .And. nPItemCon > 0
	ADB->( DBSetOrder(1) )
	If ADB->( MsSeek(xFilial("ADB")+aCols[N][nPContrat]+aCols[N][nPItemCon]) )
		If ADB->ADB_CODPRO <> M->C6_PRODUTO
			aCols[n][nPContrat] := Space(Len(aCols[n][nPContrat]))
			aCols[n][nPItemCon] := Space(Len(aCols[n][nPItemCon]))
		EndIf		
	Else
		aCols[n][nPContrat] := Space(Len(aCols[n][nPContrat]))
		aCols[n][nPItemCon] := Space(Len(aCols[n][nPItemCon]))
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica os Opcionais e a Tabela de Precos           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lContinua )
	
	dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
	dbSetOrder(1)
	MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+IIf(!Empty(M->C5_LOJAENT),M->C5_LOJAENT,M->C5_LOJACLI)) 
				
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁPosicionar o TES para calcular o CFOP                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	If !lReferencia .And. nPTes > 0 
   		If ( Type("l410Auto") != "U" .And. l410Auto .And. Type("aAutoItens[n]") !=  "U")
	       		nPosTes1 := aScan(aAutoItens[n],{|x| AllTrim(x[1])=="C6_TES"})
	   	   	If nPosTes1 > 0
	   		   aCols[n][nPTes] := aAutoItens[n][nPosTes1][2]
	   		Endif
	   		If Empty(aCols[n][nPTes])
	   			aCols[n][nPTes] := RetFldProd(SB1->B1_COD,"B1_TS")
	   		Endif
	   	Else	
	   		aCols[n][nPTes] := RetFldProd(SB1->B1_COD,"B1_TS")
		EndIF
	ElseIf lReferencia .And. nPTes > 0 .And. MatOrigGrd() == "SB4" 
		aCols[n][nPTes] := SB4->B4_TS
	Endif
	
	SF4->( DBSetOrder(1) )
	If SF4->( MsSeek(xFilial()+aCols[n][nPTes],.F.) )
		if cPaisLoc=="BRA"		
		 	Aadd(aDadosCfo,{"OPERNF","S"})
		 	Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
		 	Aadd(aDadosCfo,{"UFDEST",Iif(M->C5_TIPO$"DB", SA2->A2_EST,SA1->A1_EST)})
		 	Aadd(aDadosCfo,{"INSCR", If(M->C5_TIPO$"DB", SA2->A2_INSCR,SA1->A1_INSCR)})
			Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
			Aadd(aDadosCfo,{"FRETE" ,M->C5_TPFRETE})
	
			cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁAtualiza CFO de devido a nao correspondencia do CFO estadual  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Left(cCfop,4) == "6405"
				cCfop := "6404"+SubStr(cCfop,5,Len(cCfop)-4)
			Endif	

			
		Else
			cCfop:=SF4->F4_CF
		EndIf
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Trazer descricao do Produto                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SA7->( DBSetOrder(1) )
	If SA7->( MsSeek(xFilial("SA7")+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT+cProdRef,.F.) ) .And. !Empty(SA7->A7_DESCCLI)
		cDescricao := SA7->A7_DESCCLI
	Else
		If ( lReferencia )   
			If IsAtNewGrd()
				cDescricao := oGrade:GetDescProd(cProdRef) 
			Else
				
				SB4->( DBSetOrder(1) )
				If SB4->( MsSeek(xFilial("SB4")+cProdRef) )
					cDescricao := SB4->B4_DESC
				EndIf  
			EndIf	
		Else
			cDescricao := SB1->B1_DESC
		EndIf
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInicializar os campos a partir do produto digitado.                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lTabCli
		Do Case
			Case !Empty(M->C5_LOJAENT) .And. !Empty(M->C5_CLIENT)
				cCliTab   := M->C5_CLIENT
				cLojaTab  := M->C5_LOJAENT
			Case Empty(M->C5_CLIENT) 
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJAENT
			OtherWise
				cCliTab   := M->C5_CLIENTE
				cLojaTab  := M->C5_LOJACLI
		EndCase					
	Else
		cCliTab   := M->C5_CLIENTE
		cLojaTab  := M->C5_LOJACLI
	Endif
	
	
	For nCntFor :=1 To Len(aHeader)
		cFieldFor := AllTrim(aHeader[nCntFor][2])
		Do Case
		Case cFieldFor == "C6_UM"
			If !lReferencia
				aCols[n][nCntFor] := SB1->B1_UM
			ElseIf MatOrigGrd() == "SB4"
				aCols[n][nCntFor] := SB4->B4_UM
			Else
				aCols[n][nCntFor] := SBR->BR_UM
			EndIf
		Case cFieldFor == "C6_LOCAL"
			If !lReferencia
				aCols[n][nCntFor] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
			ElseIf MatOrigGrd() == "SB4"
				aCols[n][nCntFor] := SB4->B4_LOCPAD
			Else
				aCols[n][nCntFor] := SBR->BR_LOCPAD
			EndIf
		Case cFieldFor == "C6_DESCRI"
			aCols[n][nCntFor] := PadR(cDescricao,TamSx3("C6_DESCRI")[1])
		Case cFieldFor == "C6_SEGUM"
			If !lReferencia
				aCols[n][nCntFor] := SB1->B1_SEGUM
			ElseIf MatOrigGrd() == "SB4"
				aCols[n][nCntFor] := SB4->B4_SEGUM
			EndIf
		Case cFieldFor == "C6_PRUNIT" .And. !(lReferencia .And. lGrdMult)
			nPrcTab:=A410Tabela(	cProdRef,;
									M->C5_TABELA,;
									n,;
									aCols[n][nPQtdVen],;                                   
									cCliTab,;
									cLojaTab,;
									If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),;
									If(nPNumLote>0,aCols[n][nPNumLote],""),;
									NIL,;
									NIL,;
									.T.)				
			aCols[n][nCntFor] := A410Arred(nPrcTab,"C6_PRUNIT")
		Case cFieldFor == "C6_PRCVEN" .And. !(lReferencia .And. lGrdMult)
			nPrcTab:=A410Tabela(	cProdRef,;
									M->C5_TABELA,;
									n,;
									aCols[n][nPQtdVen],;
									cCliTab,;
									cLojaTab,;
									If(nPLoteCtl>0,aCols[n][nPLoteCtl],""),;
									If(nPNumLote>0,aCols[n][nPNumLote],""),;
									NIL,;
									NIL,;
									.F.)				
			If !(lReferencia .And. lGrdMult) .Or. nPrcTab <> 0
				If ( !lDescSubst)
					aCols[n][nCntFor] := A410Arred(FtDescCab(nPrcTab,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4})*(1-(aCols[n][nPDescon]/100)),"C6_PRCVEN",If(cPaisLoc=="CHI" .And. lPrcDec,M->C5_MOEDA,NIL))
				Else
					aCols[n][nCntFor] := FtDescCab(nPrcTab,{M->C5_DESC1,M->C5_DESC2,M->C5_DESC3,M->C5_DESC4},If(cPaisLoc=="CHI" .And. lPrcDec,M->C5_MOEDA,NIL))
				EndIf
			EndIf
		Case cFieldFor == "C6_UNSVEN"
			A410SegUm(.T.)
		Case cFieldFor == "C6_CF"
			aCols[n][nCntFor] := cCFOP
		Case "C6_COMIS" $ cFieldFor  
				aCols[n][nCntFor] := SB1->B1_COMIS	
		Case cFieldFor == "C6_QTDLIB"
			aCols[n][nCntFor] := 0
		Case cFieldFor == "C6_QTDVEN"
			aCols[n][nCntFor] := If(lCB,aCols[n][nPQtdVen],0)
		Case cFieldFor == "C6_VALOR"
			aCols[n][nCntFor] := A410Arred(aCols[n,nPPrcVen]*aCols[n,nPQtdVen],"C6_VALOR")
		Case cFieldFor == "C6_VALDESC"
			aCols[n][nCntFor] := 0
		Case cFieldFor == "C6_DESCONT"
			aCols[n][nCntFor] := 0
		Case cFieldFor == "C6_NUMLOTE"
			aCols[n][nCntFor] := CriaVar("C6_NUMLOTE")
		Case cFieldFor == "C6_LOTECTL"
			aCols[n][nCntFor] := CriaVar("C6_LOTECTL")
		Case cFieldFor == "C6_CODISS"
			aCols[n][nCntFor] := RetFldProd(SB1->B1_COD,"B1_CODISS")
		Case cFieldFor == "C6_NFORI"
			aCols[n][nCntFor] := CriaVar("C6_NFORI")
		Case cFieldFor == "C6_SERIORI"
			aCols[n][nCntFor] := CriaVar("C6_SERIORI")
		Case cFieldFor == "C6_ITEMORI"
			aCols[n][nCntFor] := CriaVar("C6_ITEMORI")
		Case cFieldFor == "C6_FCICOD" //SIGAFIS
			aCols[n][nCntFor] := Upper( XFciGetOrigem( SB1->B1_COD , M->C5_EMISSAO )[2] )
		EndCase
	Next nCntFor
	If ( MV_PAR01 == 1 .And. lCB )
		MaIniLiber(M->C5_NUM,aCols[n][nPQtdVen],n,lCB)
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInicializar os campos de enderecamento do WMS para uso na carga         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty(M->C5_TRANSP)
		SA4->(DbSetOrder(1))
		If SA4->(MsSeek(xFilial("SA4")+M->C5_TRANSP))
			If !Empty(SA4->A4_ESTFIS) .And. !Empty(SA4->A4_ENDPAD) .And. !Empty(SA4->A4_LOCAL) .And.;
				nPEndPad > 0 .And. nPLocal > 0		
				aCols[n][nPEndPad] := SA4->A4_ENDPAD
				aCols[n][nPLocal]  := SA4->A4_LOCAL
			Endif
		Endif
	Endif							
	
EndIf                                                     

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona nas tabelas SB1 e SF4 para o preenchimento correto da Ё
//Ё classificaГЦo fiscal dos itens C6_CLASFIS atravИs dos gatilhos. Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lContinua .And. RTrim(cProdRef) <> RTrim(SB1->B1_COD)
	If lgrade	
		lReferencia := MatGrdPrrf(@cProdRef)
	EndIf	
	if !lGrade .and. !lReferencia
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+cProdRef))
	Else
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+cProdRef),.F.)	
	EndIf
EndIf

Return(lRetorno)  
