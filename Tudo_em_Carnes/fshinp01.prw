#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  �ITAUAGC5  �Autor  �JN     � Data �  02/07/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customiza��o para tratamento do Cnab SISPAG das Posi��es   ���
���          � 024 a 043. (Agencia e Conta com Digito).                   ���
�������������������������������������������������������������������������͹��
���Uso       � TC	                                                  ���
���������������������������������������������������������������������������*/

User Function FSHINP01()
Local cAgencia := ""
If AllTrim(SA2->A2_BANCO) $ "341/409" .And. SEA->EA_MODELO $ "01/02/03/04/06/07/41/43"	// Itau ou Unibanco
	cAgencia := "0" // 24 a 24
	cAgencia += PadL(AllTrim(StrTran(SA2->A2_AGENCIA,"-","")),4,"0") // 25 a 28
	cAgencia += Space(01) // 29 a 29
	cAgencia += "000000" // 30 a 35
	cAgencia += PadL(AllTrim(SubStr(SA2->A2_NUMCON,1,6)),6,"0") // 36 a 41
	cAgencia += Space(01) // 42 a 42
	cAgencia += Right(Trim(SA2->A2_DVCTA),1) // 43 a 43
ElseIf SEA->EA_MODELO = "10"	// Itau ou Unibanco
	cAgencia := "0" // 24 a 24
	cAgencia += "8493" // 25 a 28
	cAgencia += Space(01) // 29 a 29
	cAgencia += "000000" // 30 a 35
	cAgencia += Strzero(0,6) // 36 a 41
	cAgencia += Space(01) // 42 a 42
	cAgencia += "0" // 43 a 43
Else // Outros Bancos
	cAgencia := PadL(AllTrim(StrTran(SA2->A2_AGENCIA,"-","")),5,"0") // 24 a 28
	cAgencia += Space(01) // 29 a 29
	cAgencia += PadL(AllTrim(Substr(SA2->A2_NUMCON,1,12)),12,"0") // 30 a 41
	cAgencia += Space(01) // 42 a 42
	cAgencia += Right(Trim(SA2->A2_DVCTA),1) // 43 a 43
EndIf
Return cAgencia