#include 'protheus.ch'
#include 'parmtype.ch'

// -------------------------------------------- \\
/*/{Protheus.doc} M410STTS()
// Ponto de entrada após qualquer alteração do 
   pedido de venda.
@author Claudio Macedo
@since 20/04/2019
@version 1.0
@type Function
/*/
// -------------------------------------------- \\
User Function M410STTS()

Local cPedido := SC5->C5_XPEDCLI
//Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local cQuery  := ""
Local nResult := 0

If IsInCallStack("A410Deleta") 

	SZ1->(DbSetOrder(1))
	SZ1->(DbSeek(xFilial("SZ1")+cPedido))
	
	While SZ1->(!EOF()) .AND. SZ1->Z1_PEDIDO = cPedido		
		SZ1->(Reclock("SZ1",.F.))
		SZ1->Z1_NUMPED := ""
		SZ1->(MsUnLock())
	
		SZ1->(DbSkip())
	Enddo
	
Else
	If  MsgYesNo("Deseja que o sistema calcule a quantidade de volumes do pedido ?") 

		cQuery  := " SELECT  SUM(C9_QTDLIB) AS C9_QTDLIB ,C9_PEDIDO " + CRLF
		cQuery  += " FROM " + RETSQLNAME("SC9") + CRLF
		cQuery  += " WHERE D_E_L_E_T_ = '' AND C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = '"+SC5->C5_NUM+"' AND C9_NFISCAL = ''" + CRLF
		cQuery  += " GROUP BY C9_PEDIDO " + CRLF

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T. )

		dbSelectArea(cAlias)

		If (cAlias)->(!Eof())
			nResult := (cAlias)->C9_QTDLIB
		Endif

		SC5->(RecLock("SC5",.F.))
		SC5->C5_VOLUME1 := nResult 
		SC5->(MsUnlock())
	Endif

EndIf

Return Nil
