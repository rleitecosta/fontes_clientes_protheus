/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � F240SUM  �Autor  � Jo�o Carlos        � Data �  28/10/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ajusta o valor total do Sispag                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CNA                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function F240SUM() 

Return(SE2->(E2_SALDO+SE2->E2_ACRESC-SE2->E2_XDESCON))
//---------------------------------------------------------------------------