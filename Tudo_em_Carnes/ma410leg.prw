#include "totvs.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410LEG  �Autor  �Frank Zwarg Fuga    � Data �  03/02/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inser�ao da legenda Enviado para expedi��o no pedido de     ���
���          �vendas                                                      ���
�������������������������������������������������������������������������͹��
���Uso       �Pedido de Vendas                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MA410LEG
Local _aCores := paramixb
aadd(_aCores,{"BR_PRETO",SuperGetMV("ITXLEG",,"Pedido de Venda encaminhado para expedi��o")})
aadd(_aCores,{"BR_BRANCO",SuperGetMV("ITXLEG2",,"Pedido de Venda encaminhado para vendedor")})
aadd(_aCores,{"BR_MARROM","Pedido de Venda encerrado com altera��o"})
Return _aCores     