#include "totvs.ch"
#include "topconn.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVEXP    �Autor  �Frank Zwarg Fuga    � Data �  03/02/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para alterar o status do pedido de vendas enviando  ���
���          � para a expedicao                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Pedido de Vendas                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ENVEXP
If SC5->C5_XEXPED <> "1"
	If MsgYesNo("Deseja colocar no status Enviado para Expedi��o?","Aten��o!")
		SC5->(RecLock("SC5",.F.))
		SC5->C5_XEXPED := "1"
		SC5->(MsUnlock())
	EndIf
ElseIf SC5->C5_XEXPED == "1"
	If MsgYesNo("Deseja remover do status Enviado para Expedi��o?","Aten��o!")
		SC5->(RecLock("SC5",.F.))
		SC5->C5_XEXPED := ""
		SC5->(MsUnlock())
	EndIf
EndIF
Return                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVVEND    �Autor  �Frank Zwarg Fuga    � Data �  03/02/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para alterar o status do pedido de vendas enviando  ���
���          � para o vendedor                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Pedido de Vendas                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ENVVEND

If AT( alltrim(substr(cUsuario,7,15)), SuperGetMV("IT_USUVEN",,"EQUIP;CPNSUL")) > 0
	MsgAlert("Usu�rio sem permiss�o para esta opera��o","Aten��o!")
	Return .F.
EndIF

If SC5->C5_XEXPED <> "3"
	If MsgYesNo("Deseja colocar no status Enviado para Vendedor?","Aten��o!")
		SC5->(RecLock("SC5",.F.))
		SC5->C5_XEXPED := "3"
		SC5->(MsUnlock())
	EndIf
ElseIf SC5->C5_XEXPED == "3"
	If MsgYesNo("Deseja remover do status Enviado para Vendedor","Aten��o!")
		SC5->(RecLock("SC5",.F.))
		SC5->C5_XEXPED := ""
		SC5->(MsUnlock())
	EndIf
EndIF
Return                     



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �XBLQQTD   �Autor  �Frank Zwarg Fuga    � Data �  03/05/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controla a quantidade nos itens do pedido de vendas        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � C6_QTDVEN                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                      
User Function XBLQQTD
Local _lRetorno := .T.                                                
Local _aArea 	:= GetArea()      
Local _cProd	:= aCols[n][Ascan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})] 
Local _nQtde	:= M->C6_QTDVEN
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+_cProd))
 If !(alltrim(M->C5_TABELA)$ GetMV("IT_BLQQTD"))	
 	If SB1->B1_QE > 0 
		If MOD(_nQtde, SB1->B1_QE) <> 0 .or. _nQtde < SB1->B1_QE
			MsgAlert("Quantidade inv�lida n�o � multiplo de "+alltrim(str(SB1->B1_QE)),"Aten��o!")
			_lRetorno := .F.
		EndIF
	EndIf
 Endif	                              
EndIf
RestArea(_aArea)
Return _lRetorno




