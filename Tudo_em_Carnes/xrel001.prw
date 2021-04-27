
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "COLORS.CH"
#INCLUDE "rwmake.ch" 
#INCLUDE "TOPCONN.CH""
#INCLUDE 'TOTVS.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "FONT.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ XREL001  ºAutor  ³ João Carlos        º Data ³  27/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão do Romaneio.                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tudo em Carnes                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XREL001()  //Romaneio
Local cDocD,cDocA,cSerD,cSerA,cPedD,cPedA
Local cPerg:="XREL001"

ValidPerg(cPerg)
If !Pergunte(cPerg,.t.)
	Return(.f.)
EndIf

cDocD:=MV_PAR01
cDocA:=MV_PAR02
cSerD:=MV_PAR03
cSerA:=MV_PAR04
cPedD:=MV_PAR05
cPedA:=MV_PAR06

fXREL001(cDocD,cDocA,cSerD,cSerA,cPedD,cPedA)  //Imprime o Romaneio

Return
//-----------------------------------------------------------------------------

Static Function fXREL001(cDocD,cDocA,cSerD,cSerA,cPedD,cPedA)  //Imprime o Romaneio
Local aTabAux,cDocAnt,cSerAnt,dEmiAnt,aVencto

oPrint:=TMSPrinter():New("Romaneio")
oPrint:SetPortrait()
oPrint:Setup()

SB1->(dbSetOrder(1))  //B1_FILIAL+B1_COD
SF2->(dbSetOrder(1))  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
SC5->(dbSetOrder(1))  //C5_FILIAL+C5_PEDIDO

fMontaSD2("QRYSD2",cDocD,cDocA,cSerD,cSerA,cPedD,cPedA)  //Monta a Query

QRYSD2->(dbGoTop())
While QRYSD2->(!Eof())

	aVencto:=fTrazSE1(QRYSD2->D2_DOC,QRYSD2->D2_SERIE)

	SF2->(dbSeek(xFilial("SF2")+QRYSD2->D2_DOC+QRYSD2->D2_SERIE))  //Posiciona no SF2
	SC5->(dbSeek(xFilial("SC5")+QRYSD2->D2_PEDIDO))  //Posiciona no SC5

	aTabAux:={}
	cDocAnt:=QRYSD2->D2_DOC
	cSerAnt:=QRYSD2->D2_SERIE
	dEmiAnt:=QRYSD2->D2_EMISSAO
	While QRYSD2->(!Eof() .and. D2_DOC==cDocAnt)
		SB1->(dbSeek(xFilial("SB1")+QRYSD2->D2_COD))  //Posiciona no SB1
		//Adicionado campos de vendedor e cliente - Leandro  
		//QRYSD2->(AAdd(aTabAux,{D2_COD,SB1->B1_DESC,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_ICMSRET,D2_CLIENTE,D2_LOJA,D2_PEDIDO,SF2->F2_PLIQUI,SC5->C5_XRETIRA,SC5->C5_MENNOTA}))
		QRYSD2->(AAdd(aTabAux,{D2_COD,SB1->B1_DESC,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_ICMSRET,D2_CLIENTE,D2_LOJA,D2_PEDIDO,SF2->F2_PLIQUI,SC5->C5_XRETIRA,SC5->C5_MENNOTA,SC5->C5_VEND1, }))
		QRYSD2->(dbSkip())
	End

	oPrint:StartPage()
	fRomaneio(oPrint,cDocAnt,cSerAnt,dEmiAnt,aTabAux,aVencto)
	oPrint:EndPage()
End

QRYSD2->(dbCloseArea())

oPrint:Preview()

Return
//-----------------------------------------------------------------------------

Static Function fMontaSD2(cAliasQRY,cDocD,cDocA,cSerD,cSerA,cPedD,cPedA)  //Monta a Query
Local aEstru,cQry:="",cCRLF:=Chr(13)+Chr(10)

cQry+="SELECT D2_DOC,D2_SERIE,D2_EMISSAO,D2_COD,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_ICMSRET,D2_CLIENTE,D2_LOJA,D2_PEDIDO"
cQry+=" FROM " + RetSqlName("SD2") + " SD2" + cCRLF
cQry+=" WHERE SD2.D_E_L_E_T_=''" + cCRLF
cQry+=" AND D2_FILIAL = '" + xFilial("SD2") + "'" + cCRLF
cQry+=" AND D2_DOC BETWEEN '" + cDocD + "' AND '" + cDocA + "'" + cCRLF
cQry+=" AND D2_SERIE BETWEEN '" + cSerD + "' AND '" + cSerA + "'" + cCRLF
cQry+=" AND D2_PEDIDO BETWEEN '" + cPedD + "' AND '" + cPedA + "'" + cCRLF
cQry+=" ORDER BY D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEM" + cCRLF
cQry:=ChangeQuery( cQry )

If !Select(cAliasQRY)==0 ; (cAliasQRY)->(dbCloseArea()) ; EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasQRY, .F., .T.)

TCSetField(cAliasQRY,"D2_EMISSAO","D",08,00)

Return
//-----------------------------------------------------------------------------

Static Function fTrazSE1(cDoc,cSerie)
Local aTabAux:={}

SE1->(dbSetOrder(1))  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SE1->(dbSeek(xFilial("SE1")+cSerie+cDoc))  //Posiciona no SE1
While SE1->(!Eof() .and. E1_FILIAL+E1_PREFIXO+E1_NUM==xFilial("SE1")+cSerie+cDoc)
	SE1->(AAdd(aTabAux,{E1_VENCREA,E1_VALOR,Recno()}))
	SE1->(dbSkip())
End

Return(aTabAux)
//-----------------------------------------------------------------------------

User Function XREL001A(oPrint,cDocD,cDocA,aVencto,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
Local aAreaSE1:=SE1->(GetArea())
Local aTabAux,cDocAnt,cSerAnt,dEmiAnt

SB1->(dbSetOrder(1))  //B1_FILIAL+B1_COD
SF2->(dbSetOrder(1))  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
SC5->(dbSetOrder(1))  //C5_FILIAL+C5_PEDIDO

SD2->(dbSetOrder(3))  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->(dbSeek(xFilial("SD2")+cDocD,.t.))
While SD2->(!Eof() .and. D2_FILIAL+D2_DOC<=xFilial("SD2")+cDocA)

	SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE))  //Posiciona no SF2
	SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))  //Posiciona no SC5

	aTabAux:={}
	cDocAnt:=SD2->D2_DOC
	cSerAnt:=SD2->D2_SERIE
	dEmiAnt:=SD2->D2_EMISSAO
	While SD2->(!Eof() .and. D2_FILIAL+D2_DOC==xFilial("SD2")+cDocAnt)
		SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))  //Posiciona no SB1
		//Adicionado campos de vendedor - Leandro  
		//SD2->(AAdd(aTabAux,{D2_COD,SB1->B1_DESC,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_ICMSRET,D2_CLIENTE,D2_LOJA,D2_PEDIDO,SF2->F2_PLIQUI,SC5->C5_XRETIRA,SC5->C5_MENNOTA}))
		SD2->(AAdd(aTabAux,{D2_COD,SB1->B1_DESC,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_ICMSRET,D2_CLIENTE,D2_LOJA,D2_PEDIDO,SF2->F2_PLIQUI,SC5->C5_XRETIRA,SC5->C5_MENNOTA,SC5->C5_VEND1}))
		SD2->(dbSkip())
	End

	oPrint:StartPage()
	fFolhaGer(oPrint,cDocAnt,cSerAnt,dEmiAnt,aTabAux,aVencto,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	oPrint:EndPage()
End

SE1->(RestArea(aAreaSE1))
Return
//-----------------------------------------------------------------------------
/*
Leandro - ITUP
Imprimi a folha geral (boletos mais romaneio através da rorina ABFINR04)
*/ 
Static Function fFolhaGer(oPrint,cDoc,cSerie,dEmissao,aTabAux,aVencto,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
Local nPos,nLin1,nCol1,nLin2,nCol2, nPos2, nPos1
Local nPesoT:=0,nTotalT:=0,nSubstT:=0
Local oFont08,oFont08B,oFont12B, oFont08A
Local oPrint,aTabAux0,aTabAux1, aTabAux2, aTabAux3

//        TFont():New(cName        ,uPar2,nHeight,uPar4,lBold,uPar6,uPar7,uPar8,uPar9,lUnderline,lItalic)
oFont08 :=TFont():New("Arial"      ,08   ,08     ,     ,.F.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )
oFont08B:=TFont():New("Arial"      ,08   ,08     ,     ,.T.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )
oFont08A:=TFont():New("Arial"      ,     ,32     ,     ,.T.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )  
oFont12B:=TFont():New("Arial"      ,12   ,12     ,     ,.T.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )

nLin2:=0050

nLin1:=nLin2+0050
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxNotaFi(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
nLin2:=fBoxNotaFi(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

nLin1:=nLin2+0050
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxBoleto(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
nLin2:=fBoxBoleto(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

//nLin2+=(8*0050)  //Pula 8 linhas para dobrar a folha geral ao meio  //dimunicao da distancia - Leandro
nLin2+=(5*0050)  //Pula 8 linhas para dobrar a folha geral ao meio    

If Len(aTabAux)<=20   //Imprimi romaneio direto com qtd 20 de pedidos antes era 40 leandro
	nLin1:=nLin2+0050
	nCol1:=0030
	nLin2:=0000
	nCol2:=2280
	nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)
	nLin2:=fBoxRomane(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)

	nLin1:=nLin2+0030
	nCol1:=0030
	nLin2:=0000
	nCol2:=2280
	nLin2:=fBoxVencto(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
	nLin2:=fBoxVencto(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
	 

Else
	nPos:=nLin2  //Guarda o nLin2   //1630 
    /*
    //comentado leandro
    If Len(aTabAux)>20  .AND.  Len(aTabAux)<=25      
	nLin1:=nLin2+0050   
	nCol1:=0030
	nLin2:=0000
	nCol2:=2280
	nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)  //Para calcular os totais
	nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)  //Para calcular os totais

	nLin2:=nPos  //Volta o nLin2
    EndiF 
    */
    // Controla a quantidade de pedidos 
	aTabAux0:={}
	aTabAux1:={}
	aTabAux2:={}
	aTabAux3:={}
	
	/*
	********************************************************
	//Modo antigo fonte - leandro              >>>Refeito 
	For nPos:=1 to Len(aTabAux)
		AAdd(aTabAux0,aTabAux[nPos])
		If Len(aTabAux0)==40
			AAdd(aTabAux1,aTabAux0)
			aTabAux0:={}
		EndIf
	Next
	AAdd(aTabAux1,aTabAux0)
	For nPos:=1 to Len(aTabAux1)
		If nPos>1
			oPrint:EndPage()
			oPrint:StartPage()
			nLin2:=0050
		EndIf
		nLin1:=nLin2+0050
		nCol1:=0030
		nLin2:=0000
		nCol2:=2280
		nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux1[nPos],aVencto,nPesoT,nTotalT,nSubstT)
		nLin2:=fBoxRomane(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux1[nPos],aVencto,nPesoT,nTotalT,nSubstT)
	Next
	********************************************************
	*/
	For nPos:=1 to Len(aTabAux)
		//imprimi os 25 pedidos 
		If nPos<=25  
			AAdd(aTabAux0,aTabAux[nPos])
			AAdd(aTabAux1,aTabAux0)
			nPesoT+=aTabAux[nPos,3]  //Variável Local passada por referência
			nTotalT+=aTabAux[nPos,5]  //Variável Local passada por referência
			nSubstT+=aTabAux[nPos,6]  //Variável Local passada por referência
		Endif 
		//imprimi os demais pedidos 
		If nPos>25
			AAdd(aTabAux2,aTabAux[nPos])
			AAdd(aTabAux3,aTabAux2)
			nPesoT+=aTabAux[nPos,3]  //Variável Local passada por referência
			nTotalT+=aTabAux[nPos,5]  //Variável Local passada por referência
			nSubstT+=aTabAux[nPos,6]  //Variável Local passada por referência
		EndIf
	 Next
	 nPos1 := LEN (aTabAux1) 	//retorna a quantidade impressa 
	 nPos2 := LEN (aTabAux3)	//retorna a quantidade impressa
	 
	 If nPos1 > 1 
		 //primeira parte impressao leandro  
		 nLin1:=nLin2+0050
		 nCol1:=0030
		 nLin2:=0000
		 nCol2:=2280
		 nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux1[nPos1],aVencto,nPesoT,nTotalT,nSubstT)
		 nLin2:=fBoxRomane(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux1[nPos1],aVencto,nPesoT,nTotalT,nSubstT)
	 
		 nLin1:=nLin2+0030
		 nCol1:=0030
		 nLin2:=0000
		 nCol2:=2280
		 nLin2:=fBoxVencto(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
		 nLin2:=fBoxVencto(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
 
	 Endif 
	 
	 If nPos2 >= 1 
		 //pula pagina 	
		 oPrint:EndPage()
		 oPrint:StartPage()
		 nLin2:=0050
	 
	 	 //segunda parte impressao leandro 
		 nLin1:=nLin2+0050
		 nCol1:=0030
		 nLin2:=0000
		 nCol2:=2280
		 nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux3[nPos2],aVencto,nPesoT,nTotalT,nSubstT)
		 nLin2:=fBoxRomane(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux3[nPos2],aVencto,nPesoT,nTotalT,nSubstT)
		 //nLin2:=nPos  //Volta o nLin2
		 
		 nLin1:=nLin2+0030
		 nCol1:=0030
		 nLin2:=0000
		 nCol2:=2280
		 nLin2:=fBoxVencto(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
		 nLin2:=fBoxVencto(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
 
	 Endif 
	 
EndIf

nLin1:=nLin2+0000
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxRetira(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
nLin2:=fBoxRetira(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

Return
//-----------------------------------------------------------------------------
/*
Leandro - ITUP
Imprimi somente o Romaneio TC pela rotina XREL001
*/ 
Static Function fRomaneio(oPrint,cDoc,cSerie,dEmissao,aTabAux,aVencto)
Local nPos,nLin1,nCol1,nLin2,nCol2
Local nPesoT:=0,nTotalT:=0,nSubstT:=0
Local oFont08,oFont08B,oFont12B
Local oPrint

//        TFont():New(cName        ,uPar2,nHeight,uPar4,lBold,uPar6,uPar7,uPar8,uPar9,lUnderline,lItalic)
oFont08 :=TFont():New("Arial"      ,08   ,08     ,     ,.F.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )
oFont08B:=TFont():New("Arial"      ,08   ,08     ,     ,.T.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )
oFont12B:=TFont():New("Arial"      ,12   ,12     ,     ,.T.  ,     ,     ,     ,.T.  ,.F.       ,.F.    )

nLin2:=0050

nLin1:=nLin2+0050
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)
nLin2:=fBoxRomane(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)

nLin1:=nLin2+0030
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxVencto(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
nLin2:=fBoxVencto(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

nLin1:=nLin2+0030
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxCarimb(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
nLin2:=fBoxCarimb(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

//Adicionado leandro
nLin1:=nLin2+0000
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxRetira(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

If nLin2>1640
	oPrint:EndPage()
	oPrint:StartPage()
	nLin2:=0050
Else
	nLin2:=1640+0150
EndIf

nLin1:=nLin2+0050
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxRomane(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)
nLin2:=fBoxRomane(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,@nPesoT,@nTotalT,@nSubstT)

nLin1:=nLin2+0030
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxVencto(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
nLin2:=fBoxVencto(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

nLin1:=nLin2+0030
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxCarimb(.f.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
nLin2:=fBoxCarimb(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

//Adicionado leandro
nLin1:=nLin2+0000
nCol1:=0030
nLin2:=0000
nCol2:=2280
nLin2:=fBoxRetira(.t.,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)

Return
//-----------------------------------------------------------------------------

Static Function fBoxRomane(lImprime,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
Local nPos,nLin
Local cEmpresa,cEnd,cPedido
Local cRedCli,cNomCli,cEndCli,cCepCli,cBaiCli,cCidCli,cEstCli, cCNPJ, cCodCli, cTipCli // add leandro
//Adicionado campos de vendedor - Leandro  
Local cCodVen := aTabAux[1,13]  //Cod vendedor 
Local cNomeVen:= ""	//nome vendedor 
Local cTelVen := ""	//tel vendedor 
Local cTit1	  := "Vendedor:"
Local cTit2	  := "Contato:"
Local cNumCNPJ:= "" //numero cnpj
Local cCCli	  := "" //Codigo Cliente   
Local oFont08A
oFont08A:=TFont():New("Arial"      ,     ,25     ,     ,.T.  ,     ,     ,     ,.T.  ,.F.       ,.F.    ) 
cPedido:=aTabAux[1,9]  //9=D2_PEDIDO

cEmpresa:=AllTrim(SM0->M0_NOMECOM)//"COMERCIAL TUDO EM CARNES LTDA."
cEnd    :=AllTrim(SM0->M0_ENDCOB)+ " - " + AllTrim(SM0->M0_BAIRCOB) + " - " + AllTrim(SM0->M0_CIDCOB)+ " - " + SM0->M0_ESTCOB + Space(05) + "Fones: " + SM0->M0_TEL //Av. Nevada, 106 - Pq Novo Oratório - Santo André - SP"+Space(05)+"Fones: 11-4977-1200"

 //Adicionado campos de vendedor - Leandro  
cNomeVen:= ALLTRIM(POSICIONE("SA3", 1, xFilial("SA3") + cCodVen, "A3_NOME") ) //nome vendedor - Leandro 
cTelVen := ALLTRIM(POSICIONE("SA3", 1, xFilial("SA3") + cCodVen, "A3_TEL")	)//tel vendedor - Leandro 
cNomeVen:= "Vendedor:" +Space(01)+ cNomeVen + "               Contato:" +Space(02)+ cTelVen

SA1->(dbSetOrder(1))  //A1_FILIAL+A1_COD+A1_LOJA
SA1->(dbSeek(xFilial("SA1")+aTabAux[1,7]+aTabAux[1,8]))  //Posiciona no SA1
cRedCli:=SA1->A1_NREDUZ
cNomCli:=SA1->A1_NOME
cEndCli:=SA1->A1_END
cCepCli:=SA1->A1_CEP
cBaiCli:=SA1->A1_BAIRRO
cCidCli:=SA1->A1_MUN
cEstCli:=SA1->A1_EST
//add Leandro
cCodCli := aTabAux[1,7]
cCNPJ   := SA1->A1_CGC
cTipCli := SA1->A1_PESSOA
//Trata valor CNPJ Leandro
If cTipCli == 'J'
	cCNPJ := TRANSFORM(cCNPJ,"@R 99.999.999/9999-99")
Else
    cCNPJ := TRANSFORM(cCNPJ ,"@R 999.999.999-99")
EndIf

//cCCli	:= "Código Cliente:" +Space(02)+ cCodCli
cCCli	:= cCodCli
cNumCNPJ:= "CNPJ/CPF:" 	  +Space(02)+ cCNPJ

If lImprime
	oPrint:Say(nLin1+0000,nCol1+0040,cEmpresa,oFont08B)
	oPrint:Say(nLin1+0000,nCol1+1050,"Pedido:",oFont08B)
	oPrint:Say(nLin1+0000,nCol1+1600,"Romaneio",oFont08B)
	oPrint:Say(nLin1+0000,nCol1+1200,cPedido,oFont08B)
	oPrint:Say(nLin1+0000,nCol1+1800,cDoc,oFont08B)
	oPrint:Say(nLin1+0050,nCol1+0040,cEnd,oFont08)
	
	//Adicionado campos de vendedor - Leandro  
	//oPrint:Say(nLin1+0090,nCol1+0040,cTit1,oFont08B)  	//Vendedor
	//oPrint:Say(nLin1+0090,nCol1+0180,cNomeVen,oFont08)	
	//oPrint:Say(nLin1+0090,nCol1+0700,cTit2,oFont08B)	//Contato
	//oPrint:Say(nLin1+0090,nCol1+0820,cTelVen,oFont08)	
	oPrint:Say(nLin1+0090,nCol1+0040,cNomeVen,oFont08)  	//Vendedor
	
	oPrint:Say(nLin1+0050,nCol1+1600,"Data",oFont08B)
	oPrint:Say(nLin1+0050,nCol1+1800,DtoC(dEmissao),oFont08B)

	oPrint:Box(nLin1+0130,nCol1,nLin1+0270,nCol2)  //Box Cliente
	oPrint:Box(nLin1+0270,nCol1,nLin2+0000,nCol2)  //Box Romaneio

	oPrint:Say(nLin1+0140,nCol1+0020,cRedCli,oFont08B)
	oPrint:Say(nLin1+0140,nCol1+0900,cNomCli,oFont08B)
	oPrint:Say(nLin1+0180,nCol1+0020,cEndCli,oFont08)
	oPrint:Say(nLin1+0180,nCol1+1700,Transform(cCepCli,"@R XXXXX-XXX"),oFont08)
	oPrint:Say(nLin1+0220,nCol1+0020,AllTrim(cBaiCli)+" - "+AllTrim(cCidCli)+" - "+AllTrim(cEstCli),oFont08)
	
	//add leandro
	oPrint:Say(nLin1+0000,nCol1+2000,cCCli,oFont08A)
	oPrint:Say(nLin1+0220,nCol1+0900,cNumCNPJ,oFont08)
	
	oPrint:Line(nLin1+0270,nCol1+0250,nLin2+0000,nCol1+0250)  //Linha Vertical
	oPrint:Line(nLin1+0270,nCol1+1590,nLin2+0000,nCol1+1590)  //Linha Vertical
	oPrint:Line(nLin1+0270,nCol1+1810,nLin2+0000,nCol1+1810)  //Linha Vertical
	oPrint:Line(nLin1+0270,nCol1+2030,nLin2+0000,nCol1+2030)  //Linha Vertical
	oPrint:Say(nLin1+0290,nCol1+0020,"Cód.",oFont08B)
	oPrint:Say(nLin1+0290,nCol1+0270,"Descrição",oFont08B)
	oPrint:Say(nLin1+0290,nCol1+1610,"QTD",oFont08B)
	oPrint:Say(nLin1+0290,nCol1+1830,"Preço",oFont08B)
	oPrint:Say(nLin1+0290,nCol1+2050,"Total",oFont08B)
	oPrint:Line(nLin1+0340,nCol1+0000,nLin1+0340,nCol2+0000)  //Linha Horizontal
EndIf

nPesoT:=0  //Variável Local passada por referência
nTotalT:=0  //Variável Local passada por referência
nSubstT:=0  //Variável Local passada por referência

nLin:=nLin1+0310

For nPos:=1 to Len(aTabAux)
	nLin+=40
	If lImprime
		oPrint:Say(nLin,nCol1+0020,aTabAux[nPos,1],oFont08)
		oPrint:Say(nLin,nCol1+0270,aTabAux[nPos,2],oFont08)
		oPrint:Say(nLin,nCol1+1790,Transform(aTabAux[nPos,3],"@E 999,999,999.99"),oFont08,,,,1)
		oPrint:Say(nLin,nCol1+2010,Transform(aTabAux[nPos,4],"@E 999,999,999.99"),oFont08,,,,1)
		oPrint:Say(nLin,nCol1+2230,Transform(aTabAux[nPos,5],"@E 999,999,999.99"),oFont08,,,,1)
	EndIf
	nPesoT+=aTabAux[nPos,3]  //Variável Local passada por referência
	nTotalT+=aTabAux[nPos,5]  //Variável Local passada por referência
	nSubstT+=aTabAux[nPos,6]  //Variável Local passada por referência
Next

nPesoT:=aTabAux[1,10]  //10=F2_PLIQUI  //Variável Local passada por referência

nLin+=0040

Return(nLin)
//-----------------------------------------------------------------------------

Static Function fBoxVencto(lImprime,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto,nPesoT,nTotalT,nSubstT)
Local nPos,nLin,nCol

If lImprime
	oPrint:Box(nLin1,nCol1+0000,nLin2,nCol1+1350)  //Box Vencimento
	oPrint:Box(nLin1,nCol1+1370,nLin2,nCol2-0000)  //Box Totais
	oPrint:Line(nLin1+0070,nCol1+1370,nLin1+0070,nCol2+0000)  //Linha Horizontal
	oPrint:Line(nLin1+0000,nCol1+1590,nLin2+0000,nCol1+1590)  //Linha Vertical
	oPrint:Line(nLin1+0000,nCol1+1810,nLin2+0000,nCol1+1810)  //Linha Vertical
	oPrint:Line(nLin1+0000,nCol1+2030,nLin2+0000,nCol1+2030)  //Linha Vertical
	oPrint:Say(nLin1+0020,nCol1+0020,"Vencimento",oFont08B)
EndIf

nCol:=nCol1+0160

For nPos:=1 to Len(aVencto)
	nLin:=nLin1+0020
	nCol+=0090
	If lImprime
		oPrint:Say(nLin,nCol,DtoC(aVencto[nPos,1]),oFont08)
	EndIf
	nLin+=0050
	nCol+=0090
	If lImprime
		oPrint:Say(nLin,nCol+0040,Transform(aVencto[nPos,2],"@E 999,999,999.99"),oFont08,,,,1)
	EndIf
Next

If lImprime
	oPrint:Say(nLin1+0020,nCol1+1390,"Total Peso",oFont08B)
	oPrint:Say(nLin1+0020,nCol1+1610,"Total Produto",oFont08B)
	oPrint:Say(nLin1+0020,nCol1+1830,"ICMS Subs.",oFont08B)
	oPrint:Say(nLin1+0020,nCol1+2050,"Total Pedido",oFont08B)
	oPrint:Say(nLin1+0090,nCol1+1570,Transform(nPesoT,"@E 999,999,999.99"),oFont08B,,,,1)
	oPrint:Say(nLin1+0090,nCol1+1790,Transform(nTotalT,"@E 999,999,999.99"),oFont08B,,,,1)
	oPrint:Say(nLin1+0090,nCol1+2010,Transform(nSubstT,"@E 999,999,999.99"),oFont08B,,,,1)
	oPrint:Say(nLin1+0090,nCol1+2230,Transform(nTotalT+nSubstT,"@E 999,999,999.99"),oFont08B,,,,1)
EndIf

nLin:=nLin1+0140

Return(nLin)
//-----------------------------------------------------------------------------

Static Function fBoxNotaFi(lImprime,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto)
Local nPos,nLin

If lImprime
	oPrint:Box(nLin1,nCol1,nLin2,nCol2)  //Box Nota Fiscal
	oPrint:Line(nLin1+0140,nCol1+0000,nLin1+0140,nCol1+1850)  //Linha Horizontal
	oPrint:Say(nLin1+0020,nCol1+0040,OemToAnsi("RECEBEMOS DE COMERCIAL TUDO EM CARNES LTDA OS PRODUTOS / SERVIÇOS CONSTANTES DA NOTA"),oFont08B)
	oPrint:Say(nLin1+0070,nCol1+0040,"FISCAL INDICADA AO LADO",oFont08B)
	oPrint:Line(nLin1+0140,nCol1+0440,nLin2+0000,nCol1+0440)  //Linha Vertical
	oPrint:Say(nLin1+0160,nCol1+0040,"DATA DE RECEBIMENTO",oFont08B)
	oPrint:Say(nLin1+0160,nCol1+0470,OemToAnsi("IDENTIFICAÇÃO E ASSINATURA DO RECEBIMENTO"),oFont08B)
	oPrint:Line(nLin1+0000,nCol1+1850,nLin2+0000,nCol1+1850)  //Linha Vertical
	oPrint:Say(nLin1+0020,nCol1+2000,"NF-e",oFont08B)
	oPrint:Say(nLin1+0110,nCol1+1930,cDoc,oFont12B)
	oPrint:Say(nLin1+0210,nCol1+1980,OemToAnsi("SÉRIE ")+cSerie,oFont08B)
EndIf

nLin:=nLin1+0280

Return(nLin)
//-----------------------------------------------------------------------------

Static Function fBoxCarimb(lImprime,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto)
Local nPos,nLin

If lImprime
	oPrint:Box(nLin1,nCol1,nLin2,nCol1+1500)  //Box Carimbo
	oPrint:Line(nLin1+0100,nCol1+0000,nLin1+0100,nCol1+1500)  //Linha Horizontal
	oPrint:Line(nLin1+0000,nCol1+0300,nLin2+0000,nCol1+0300)  //Linha Vertical
	oPrint:Line(nLin1+0000,nCol1+1000,nLin2+0000,nCol1+1000)  //Linha Vertical
	oPrint:Say(nLin1+0120,nCol1+0100,"Data",oFont08B)
	oPrint:Say(nLin1+0120,nCol1+0540,"Recebimento",oFont08B)
	oPrint:Say(nLin1+0120,nCol1+1150,"Documento",oFont08B)
EndIf

nLin:=nLin1+0170


Return(nLin)
//-----------------------------------------------------------------------------

Static Function fBoxRetira(lImprime,oPrint,nLin1,nCol1,nLin2,nCol2,oFont08,oFont08B,oFont12B,cDoc,cSerie,dEmissao,aTabAux,aVencto)
Local nLin,cRetira,cEndEnt,cTexto,cTexto2,cTexto3

cRetira:=aTabAux[1,11]  //11=C5_XRETIRA (1=Sim,2=Não)
cEndEnt:=aTabAux[1,12]  //12=C5_MENNOTA (End.Entrega)

Do Case
Case cRetira=="1" .and. !Empty(cEndEnt)  //1=Sim,2=Não
	cTexto:="**RETIRA**"+Space(10)+"End.Entrega: "+AllTrim(cEndEnt)
Case cRetira=="1" .and.  Empty(cEndEnt)  //1=Sim,2=Não
	cTexto:="**RETIRA**"
Case cRetira<>"1" .and. !Empty(cEndEnt)  //1=Sim,2=Não
	cTexto:="End.Entrega: "+AllTrim(cEndEnt)
Otherwise
	cTexto:=""
EndCase

If lImprime
	//quebra texto - Leandro 
	cTexto1 := SUBSTR(cTexto, 1,  70)	//120)  
	cTexto2 := SUBSTR(cTexto, 70,113)	//121,118)
	cTexto3 := SUBSTR(cTexto, 113,227)	//239,118)
	If !EMPTY(cTexto1)
		oPrint:Say(nLin1+0020,nCol1+0020,alltrim(cTexto1),oFont12B) //parte 1
	Endif 
	If !EMPTY(cTexto2)
		oPrint:Say(nLin1+0060,nCol1+0020,alltrim(cTexto2),oFont12B) //parte 2
	Endif 
	If !EMPTY(cTexto3)
		oPrint:Say(nLin1+0100,nCol1+0020,alltrim(cTexto3),oFont12B) //parte 3
	Endif 
	
EndIf
nLin:=nLin1+0020

Return(nLin)
//-----------------------------------------------------------------------------

Static Function fBoxBoleto(lImprime,oPrint,nLin1,nCol1,nLin2,nCol2,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

If lImprime
	U_xxBoleto(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
EndIf

nLin:=nLin1+1000

Return(nLin)
//-----------------------------------------------------------------------------

Static Function ValidPerg(cPerg)
Local nPos,nPos1,aPerg

cPerg:=PadR(Subs(cPerg,1,Len(SX1->X1_GRUPO)),Len(SX1->X1_GRUPO))

aPerg:={}

//	       {X1_GRUPO,X1_ORDEM,X1_PERGUNT                    ,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANH0          ,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01  ,X1_DEF01      ,X1_DEFSPA1    ,X1_DEFENG1    ,X1_CNT01,X1_VAR02 ,X1_DEF02       ,X1_DEFSPA2  ,X1_DEFENG2  ,X1_CNT02,X1_VAR03,X1_DEF03         ,X1_DEFSPA3       ,X1_DEFENG3       ,X1_CNT03,X1_VAR04,X1_DEF04       ,X1_DEFSPA4     ,X1_DEFENG4     ,X1_CNT04,X1_VAR05,X1_DEF05        ,X1_DEFSPA5      ,X1_DEFENG5      ,X1_CNT05,X1_F3,X1_PYME,X1_GPSSXG,X1_HELP,X1_PICTURE})
AAdd(aPerg,{cPerg   ,"01"    ,"De Nota Fiscal:"             ,""       ,""       ,"mv_cha"  ,"C"    ,Len(SF2->F2_DOC)    ,00        ,0        ,"G"   ,""      ,"MV_PAR01",""            ,""            ,""            ,""      ,""       ,""             ,""          ,""          ,""      ,""      ,""               ,""               ,""               ,""      ,""      ,""             ,""             ,""             ,""      ,""      ,""              ,""              ,""              ,""      ,""   ,"S"    ,""       ,""     ,""        })
AAdd(aPerg,{cPerg   ,"02"    ,"Ate Nota Fiscal:"            ,""       ,""       ,"mv_chb"  ,"C"    ,Len(SF2->F2_DOC)    ,00        ,0        ,"G"   ,""      ,"MV_PAR02",""            ,""            ,""            ,""      ,""       ,""             ,""          ,""          ,""      ,""      ,""               ,""               ,""               ,""      ,""      ,""             ,""             ,""             ,""      ,""      ,""              ,""              ,""              ,""      ,""   ,"S"    ,""       ,""     ,""        })
AAdd(aPerg,{cPerg   ,"03"    ,"De Serie:"                   ,""       ,""       ,"mv_chc"  ,"C"    ,Len(SF2->F2_SERIE)  ,00        ,0        ,"G"   ,""      ,"MV_PAR03",""            ,""            ,""            ,""      ,""       ,""             ,""          ,""          ,""      ,""      ,""               ,""               ,""               ,""      ,""      ,""             ,""             ,""             ,""      ,""      ,""              ,""              ,""              ,""      ,""   ,"S"    ,""       ,""     ,""        })
AAdd(aPerg,{cPerg   ,"04"    ,"Ate Serie:"                  ,""       ,""       ,"mv_chd"  ,"C"    ,Len(SF2->F2_SERIE)  ,00        ,0        ,"G"   ,""      ,"MV_PAR04",""            ,""            ,""            ,""      ,""       ,""             ,""          ,""          ,""      ,""      ,""               ,""               ,""               ,""      ,""      ,""             ,""             ,""             ,""      ,""      ,""              ,""              ,""              ,""      ,""   ,"S"    ,""       ,""     ,""        })
AAdd(aPerg,{cPerg   ,"05"    ,"De Pedido:"                  ,""       ,""       ,"mv_che"  ,"C"    ,Len(SC5->C5_NUM)    ,00        ,0        ,"G"   ,""      ,"MV_PAR05",""            ,""            ,""            ,""      ,""       ,""             ,""          ,""          ,""      ,""      ,""               ,""               ,""               ,""      ,""      ,""             ,""             ,""             ,""      ,""      ,""              ,""              ,""              ,""      ,""   ,"S"    ,""       ,""     ,""        })
AAdd(aPerg,{cPerg   ,"06"    ,"Ate Pedido:"                 ,""       ,""       ,"mv_chf"  ,"C"    ,Len(SC5->C5_NUM)    ,00        ,0        ,"G"   ,""      ,"MV_PAR06",""            ,""            ,""            ,""      ,""       ,""             ,""          ,""          ,""      ,""      ,""               ,""               ,""               ,""      ,""      ,""             ,""             ,""             ,""      ,""      ,""              ,""              ,""              ,""      ,""   ,"S"    ,""       ,""     ,""        })

SX1->(dbSetOrder(1))  //X1_GRUPO+X1_ORDEM

For nPos:=1 to Len(aPerg)
	SX1->(dbSeek(aPerg[nPos,1]+aPerg[nPos,2]))
	If SX1->(Eof())
		SX1->(RecLock("SX1",.T.))
		For nPos1:=1 to SX1->(FCount())
			If nPos1<=Len(aPerg[nPos])
				SX1->(FieldPut(nPos1,aPerg[nPos,nPos1]))
			Endif
		Next
		SX1->(MsUnlock())
	Endif
Next

Return
//-----------------------------------------------------------------------------
