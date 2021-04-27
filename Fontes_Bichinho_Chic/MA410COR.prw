#Include "protheus.ch"

// -------------------------------------------- \\
/*/{Protheus.doc} M410STTS()
// Ponto de entrada para tratar as cores das Legendas com o faturamento parcial no pedido de vendas.
@author Claudio Macedo
@since 20/04/2019
@version 1.0
@type Function
/*/
// -------------------------------------------- \\

User Function MA410COR()
Local aCoresPE := ParamIXB

// � importante destacar que, ao utilizar este ponto de entrada, voc� ser� o respons�vel por priorizar a valida��o para cada caracter�stica da legenda, de forma a existir apenas 01 condi��o verdadeira.
// Caso contr�rio, sua customiza��o pode n�o ter o resultado esperado.

aAdd(aCoresPE, NIL)
aIns(aCoresPE, 1)
aCoresPE[01] := {"Empty(C5_LIBEROK).And.!Empty(C5_NOTA) .And. Empty(C5_BLQ) ", "BR_VERDE_ESCURO ", "Pedido faturado parcial"}
aAdd(aCoresPE, NIL)
aIns(aCoresPE, 1)
aCoresPE[01] := {"!Empty(C5_LIBEROK).And.!Empty(C5_NOTA).And. Empty(C5_BLQ)", "BR_BRANCO ", "Pedido faturado parcial liberado"}


Return aCoresPE
