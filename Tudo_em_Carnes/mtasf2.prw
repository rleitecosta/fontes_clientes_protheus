#include "totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTASF2    �Autor  �Frank Zwarg Fuga    � Data �  03/05/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �troca a legenda para marrom quando houver geracao de nota   ���
���          �e a legenda era branca                                      ���
�������������������������������������������������������������������������͹��
���Uso       �troca da legenda                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTASF2
If SC5->C5_XEXPED=='3'
	SC5->(RecLock("SC5"),.F.)
	SC5->C5_XEXPED := '4'
	SC5->(MsUnlock())
EndIF
Return .T.