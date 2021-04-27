#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M410LIOK
@description Valida linhas do pedido de venda para calculo do Peso Bruto e Peso Liquido. 
@type function

@author Leandro Procopio	
@since 18 03 2019 
@version 1.0
/*/
user function M410LIOK()

Local nPesoBruto := 0
Local nPesoLiqui := 0	
Local _nItem
Local nPesoBrut2 := 0
Local nPesoLiqu2 := 0 
Local lRet 		 := .t. 

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
	
return (lRet)