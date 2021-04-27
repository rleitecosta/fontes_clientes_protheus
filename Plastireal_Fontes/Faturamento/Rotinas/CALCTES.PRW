#INCLUDE "TOTVS.CH"

/*-------------------------------------------------------------------------------------------------
{Protheus.doc} CALCTES
Rotina para alplicar TES Inteligente, chamado pelo PE - MT410INC
@author  Mário A. Cavenaghi - EthosX
@since   15/09/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------*/
User Function CALCTES

   Local nCliente := Ascan(aAutoCab     , {|x| AllTrim(x[1]) == "C5_CLIENTE"})
   Local nLoja    := Ascan(aAutoCab     , {|x| AllTrim(x[1]) == "C5_LOJACLI"})
   Local nTipoCli := Ascan(aAutoCab     , {|x| AllTrim(x[1]) == "C5_TIPOCLI"})
   Local nTipoPV  := Ascan(aAutoCab     , {|x| AllTrim(x[1]) == "C5_TIPO"})
   Local nTES     := Ascan(aAutoItens[1], {|x| AllTrim(x[1]) == "C6_TES"})
   Local nProduto := Ascan(aAutoItens[1], {|x| AllTrim(x[1]) == "C6_PRODUTO"})
   Local cCliente := aAutoCab[nCliente  , 2]
   Local cLoja    := aAutoCab[nLoja     , 2]
   Local cTipoPV  := aAutoCab[nTipoPV   , 2]
   Local cTipoCli := aAutoCab[nTipoCli  , 2]
   Local cProduto := ""
   Local cTES     := ""
   Local cTESInt  := ""
   Local nItem    := 0

   For nItem   := 1 To Len(aAutoItens)
      cProduto := aAutoItens[nItem, nProduto, 2]
      cTES     := aAutoItens[nItem, nTES    , 2]
      cTESInt  := MaTesInt(2, "01", cCliente, cLoja, Iif(cTipoPV $ 'DB', "F", "C"), cProduto, "C6_TES", cTipoCli)
      If !Empty(cTESInt) .And. cTESInt <> cTES
         aAutoItens[nItem, nTES, 2] := cTESInt
      Endif
   Next

Return(.T.)
