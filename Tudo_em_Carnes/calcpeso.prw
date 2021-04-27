#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CALCPESO Autor ³ xxxxxxxx                ³ Data ³ 16/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo  ³ Funcao responsavel pelo preenchimento dos campos         ±±
				   de Peso Bruto e Peso Liquido do Pedido de Vendas
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  ³ Criar Gatilho no Campo C6_QTDVEN igual a U_CALCPESO(M->C6_QTDVEN)
	 Contra dominio C6_QTDVEN                                         ³±±
±±                                                                        ³±±
±±                                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
User Function CalcPeso(nValor)
Local nPesoBruto := 0
Local nPesoLiqui := 0
Local _nItem

nPosItem := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_ITEM"})
nPosProd := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_PRODUTO"})
nPosQtde := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_QTDVEN"})
nPosQtdL := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_QTDLIB"})

For _nItem := 1 to Len(aCols)                    
    If ! aCols[_nItem,Len(aHeader)+1]
		 Posicione("SB1",1,xFilial("SB1")+aCols[_nItem,nPosProd],"")
		 Posicione("SB5",1,xFilial("SB5")+aCols[_nItem,nPosProd],"")
		 
       // Posiciona-se no item do pedido atual gravado e efetua o abatimento caso o mesmo já tenha sido atendido parcialmente

		 If SC6->(dbSetOrder(2), dbSeek(xFilial("SC6")+aCols[_nItem,nPosProd]+M->C5_NUM+aCols[_nItem,nPosItem]))
			If !Empty(aCols[_nItem,nPosQtdL])
				 nPesoLiqui += ((aCols[_nItem,nPosQtdL]) * SB1->B1_PESO)
				 nPesoBruto += ((aCols[_nItem,nPosQtdL]) * SB1->B1_PESBRU)    
			Else				 
				 nPesoLiqui += ((aCols[_nItem,nPosQtde] - SC6->C6_QTDENT) * SB1->B1_PESO)
				 nPesoBruto += ((aCols[_nItem,nPosQtde] - SC6->C6_QTDENT) * SB1->B1_PESBRU)                                                                     
			Endif
		 Else
			If !Empty(aCols[_nItem,nPosQtdL])
			 	nPesoLiqui += (aCols[_nItem,nPosQtdL] * SB1->B1_PESO)
			 	nPesoBruto += (aCols[_nItem,nPosQtdL] * SB1->B1_PESBRU)
			 	
			Else
			 	nPesoLiqui += (aCols[_nItem,nPosQtde] * SB1->B1_PESO)
			 	nPesoBruto += (aCols[_nItem,nPosQtde] * SB1->B1_PESBRU)
			 	
			Endif
		 Endif
    EndIf
Next

M->C5_PBRUTO := nPesoBruto
M->C5_PESOL  := nPesoLiqui       
GetDRefresh() 
Return nValor
//-----------------------------------------------------------------------------

User Function SC6VALID(cCampo)  //U_SC6VALID("C6_QTDVEN")
Local lRet:=.t.
Local cTipo,nQuant
Local nPosPro:=Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})

Do Case
Case Upper(cCampo)==Upper("C6_QTDVEN")
	cTipo:=Posicione("DA0",1,xFilial("DA0")+M->C5_TABELA,"DA0_XREVEN")  //Posiciona no DA0 (Tabela de Preço)
	If cTipo=="R"  //R=Revendedor
		nQuant:=fTrazQuant(aCols[N,nPosPro])  //Traz a quantidade por embalagem
		If nQuant>0
			If Mod(M->C6_QTDVEN,nQuant)<>0
				MsgStop("Quantidade invalida. Deve ser multiplo de "+AllTrim(Str(nQuant))+".")
				lRet:=.f.
			EndIf
		EndIf
	EndIf
EndCase

Return(lRet)
//-----------------------------------------------------------------------------

Static Function fTrazQuant(cCod)  //Traz a quantidade por embalagem
Local nPos,aTabAux
Local nRet:=0

If SB1->(!Empty(cCod) .and. FieldPos("B1_XQTD")>0)
	cCod:=SB1->(PadR(Subs(cCod,1,Len(B1_COD)),Len(B1_COD)))  //Deixa o cCod com o mesmo tamanho do B1_COD
	If SB1->(B1_COD<>cCod)
		Posicione("SB1",1,xFilial("SB1")+cCod,"B1_COD")  //Posiciona no SB1
	EndIf
	nRet:=SB1->B1_XQTD
Else
	aTabAux:={}
	AAdd(aTabAux,{"000001",12})
	AAdd(aTabAux,{"000002",12})
	AAdd(aTabAux,{"000015",12})
	AAdd(aTabAux,{"000013",12})
	AAdd(aTabAux,{"000011",10})
	AAdd(aTabAux,{"000004",08})
	AAdd(aTabAux,{"000012",12})
	AAdd(aTabAux,{"000014",12})
	AAdd(aTabAux,{"000010",08})
	AAdd(aTabAux,{"000126",12})  //LINGUICA
	AAdd(aTabAux,{"000127",12})  //LINGUICA APIMENTADA
	AAdd(aTabAux,{"000009",12})
	AAdd(aTabAux,{"000081",10})
	AAdd(aTabAux,{"000077",05})
	AAdd(aTabAux,{"000078",10})
	AAdd(aTabAux,{"000079",05})
	AAdd(aTabAux,{"000080",05})
	AAdd(aTabAux,{"000007",08})
	AAdd(aTabAux,{"000017",08})
	AAdd(aTabAux,{"000005",08})  //CORDEIRO
	AAdd(aTabAux,{"000006",08})
	AAdd(aTabAux,{"000008",08})  //MEDALHAO SUINO
	AAdd(aTabAux,{"000018",08})
	AAdd(aTabAux,{"000075",08})  //SALSICHAO
	AAdd(aTabAux,{"000062",10})
	AAdd(aTabAux,{"000063",10})
	AAdd(aTabAux,{"000150",10})
	AAdd(aTabAux,{"000159",16})
	AAdd(aTabAux,{"000135",17})
	AAdd(aTabAux,{"000134",16})
	AAdd(aTabAux,{"000136",16})
	AAdd(aTabAux,{"000137",10})
	
	nPos:=Ascan(aTabAux,{|x|x[1]==Subs(cCod,1,6)})
	If nPos>0
		nRet:=aTabAux[nPos,2]
	EndIf
EndIf

Return(nRet)
//-----------------------------------------------------------------------------
