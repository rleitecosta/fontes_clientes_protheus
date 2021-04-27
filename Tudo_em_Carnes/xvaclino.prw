#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} XVACLINO
@description Verifica quantidade de titulos do cliente 
@type function

@author Leandro Procopio	
@since 18 02 2019
@version 1.0
/*/
user function XVACLINO()

Local _aArea 	:= GetArea()
Local lRet      := .T.			// Conteudo de retorno
Local cMsg      := ""			// Mensagem de alerta
Local lRegraS  	:= .f. 
//campos preenchidos 
Local cCli	    := M->C5_CLIENTE
Local cLCli     := M->C5_LOJACLI
Local cCondPg   := M->C5_CONDPAG
Local cCondPgAt:= "1"
//Local cCliNovo  := M->C5_CLINOVO
Local cCliNovo	:= ""
//query
Local _cQuery2	:= ""       
Local cAliasQry2   

//--------------------------------------------------------------------------
//FORMA DE PAGAMENTO INICIAL
//Verifica quantidade de titulos do cliente 
//--------------------------------------------------------------------------
_cQuery2 := "select COUNT(E1_CLIENTE) QTD from "+ RetSqlName("SE1")
_cQuery2 += " where E1_FILIAL='"+ xFilial("SE1") +"'"
_cQuery2 += " and E1_CLIENTE='"+ cCli +"'"
_cQuery2 += " and D_E_L_E_T_ = ' '"

If Select("cAliasQry2")>0 ; ("cAliasQry2")->(dbCloseArea()) ; EndIf
DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cQuery2)), "cAliasQry2", .F., .T.)

IF cAliasQry2->(!Eof()) 

	//Se for cliente novo e a quantidade for ate 3 titulos 
	//Obriga usar condicao pgto a vista. 
	SA1->(dbSetorder(1))
	If SA1->(dbSeek(xFilial("SA1")+ cCli))	//somente busca por cliente - Leandro   
		cCliNovo := SA1->A1_CLINOVO	
		If cAliasQry2->QTD <= 3 .AND. cCliNovo == '1'  //cliente novo   1= sim
			lRegraS := .T. 
			cMsg := "O Cliente " + cCli + " não emitiu a quantidade mínima de 3 Notas. Utilize apenas a Condição de pagamento: A VISTA."
			MsgAlert( cMsg, "Atenção!" ) 
			//lRet := .F. 
		EndIf
	Endif 	 
	
EndIf

RestArea(_aArea)
Return(lRegraS)

//-----------------------------------------------------------------------------

user function XVACONDP()

Local lRegraOK := U_XVACLINO()

Return(lRegraOK)


