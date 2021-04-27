#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  �MORA()   �Autor  �TOTVS                � Data �  14/06/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � FONTE DESENVOLVIDO PARA CALCULO DE JUROS MORA/DIA,         ���
���          � CONFORME LAYOUT CNAB ITAU COBRAN�A. (POSICOES 161 A 173)   ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
���������������������������������������������������������������������������*/

User Function MULTA()
Local _nMulta 	:= 0
Local _cBanco	:= SEE->EE_CODIGO
Local _cAgencia	:= SEE->EE_AGENCIA
Local _cConta	:= SEE->EE_CONTA	
DbSelectArea("SEE")       
Dbsetorder(1)
Dbseek(xfilial("SEE")+_cBanco+_cAgencia+_cConta+"R")                     
If _cBanco=="341"
	_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 13, "0" )
ElseIf _cBanco=="001"
	_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 15, "0" )
Else                                                                                                                        
	_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 13, "0" )
EndIf
Return _nMulta