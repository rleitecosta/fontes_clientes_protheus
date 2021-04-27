#include "totvs.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �xvalcli   �Autor  �Frank Zwarg Fuga    � Data �  03/02/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao no C5_CLIENTE para bloquear quando houver um      ���
���          �titulo vencido                                              ���
�������������������������������������������������������������������������͹��
���Uso       �Pedido de vendas                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/      

User Function xValCli
Local _aArea 	:= GetArea()
Local _lRetorno := .T.
Local _cQuery	:= ""        
Local cAliasQry         
Local _cBloq	:= ""

_cQuery := "select E1_VENCREA, E1_VALOR from "+ RetSqlName("SE1")
_cQuery += " where E1_FILIAL='"+ xFilial("SE1") +"'"
_cQuery += " and E1_VENCREA < '"+ dtos(dDataBase) +"'"
//_cQuery += " and E1_BAIXA = ''"  //comentado - leandro 
//Casos em que ha baixa parcial e marcado como baixa 
_cQuery += " and E1_SALDO > 0" //Alterado para verificar saldos em aberto - Leandro 
_cQuery += " and E1_CLIENTE='"+ M->C5_CLIENTE +"'"
//_cQuery += " and E1_LOJA='"+ M->C5_LOJACLI +"'"     //sempre 01 (osmar 14 01 2019) - Leandro 
_cQuery += " and D_E_L_E_T_ = ' '"
cAliasQry := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TCGENQRY(,, _cQuery), cAliasQry, .T., .T. )
					
if ! (cAliasQry)->( EOF() )

	While !(cAliasQry)->( EOF() )
		_cBloq += "["+substr(E1_VENCREA,7,2)+"/"+substr(E1_VENCREA,5,2)+"/"+substr(E1_VENCREA,1,4)+" R$"+alltrim(str(E1_VALOR))+"] "
		(cAliasQry)->( dbSkip() )
	EndDo
    
    SA1->(dbSetorder(1))
    //If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
    //Nos usuarios de vendas a loja e bloqueada nao chegando o valor na memoria ate a busca
      If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE))	//somente busca por cliente - Leandro   
		If SA1->A1_XBLQ <> "S"
			_lRetorno := .F.   
			MsgAlert(SuperGetMV("IT_MSGCLIX",,"Existem t�tulos em atraso para este cliente.")+_cBloq, "Aten��o!")
		EndIf
	EndIF
endif
					
(cAliasQry)->( dbCloseArea() )

RestArea(_aArea)
Return _lRetorno


