#include "totvs.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410COR  �Autor  �Microsiga           � Data �  03/02/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                               

User Function MA410COR
Local aCoresPE := paramixb

aAdd(aCoresPE, NIL)
aIns(aCoresPE, 1)
aCoresPE[01] := {"C5_XEXPED=='1' .and. empty(C5_NOTA) .and. C5_LIBEROK <> 'S' ", "BR_PRETO", "Enviado para expedi��o"}
aAdd(aCoresPE, NIL)
aIns(aCoresPE, 1)
aCoresPE[01] := {"C5_XEXPED=='3'", "BR_BRANCO", "Enviado para vendedor"}
aAdd(aCoresPE, NIL)
aIns(aCoresPE, 1)
aCoresPE[01] := {"C5_XEXPED=='4'", "BR_MARROM", "Encerrado com altera��o"}
Return aCoresPE




