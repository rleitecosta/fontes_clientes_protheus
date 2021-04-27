#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} XVACLIAT
@description verifica titulos cliente nos ultimos 60 dias 
@type function

@author Leandro Procopio	
@since 18 02 2019
@version 1.0
/*/
user function XVACLIAT()

Local _aArea 	:= GetArea()
Local lRet      := .T.			// Conteudo de retorno
Local cMsg      := ""			// Mensagem de alerta
//campos preenchidos 
Local cCli	    := M->C5_CLIENTE
Local cLCli     := M->C5_LOJACLI
Local cCondPg   := M->C5_CONDPAG
Local nDias	    := 0
Local dDate1
Local dDate2 	
Local cDate2
Local cDate1
Local dDataLib
Local nDiasLib  := 0

//query
Local _cQuery	:= ""        
Local cAliasQry     

//--------------------------------------------------------------------------
//INATIVAÇÃO DE CADASTRO CLIENTE 
//verifica titulos cliente nos ultimos 60 dias 
//--------------------------------------------------------------------------
_cQuery := "select MAX(E1_EMISSAO) MAXDATA from "+ RetSqlName("SE1")
_cQuery += " where E1_FILIAL='"+ xFilial("SE1") +"'"
_cQuery += " and E1_CLIENTE='"+ cCli +"'"
_cQuery += " and D_E_L_E_T_ = ' '"

If Select("cAliasQry")>0 ; ("cAliasQry")->(dbCloseArea()) ; EndIf
DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cQuery)), "cAliasQry", .F., .T.)

IF cAliasQry->(!Eof()) 
	
	//Se nao existir titulos retorna 0 para controle de dias. 
	IF cAliasQry->MAXDATA == '        '
		nDias := nDias
	EndIf 
	
	//ultima data existente ate dia do sistema 
	If  !EMPTY(cAliasQry->MAXDATA)
		dDate1 := dDataBase 
		cDate2 := cAliasQry->MAXDATA
		dDate2 := STOD(cDate2)
		nDias  := DateDiffDay( dDate1 , dDate2 )
		IF nDias < 0
			nDias := nDias * -1
		Endif
	Endif 
	
	//Verifica liberacao 
	SA1->(dbSetorder(1))
	If SA1->(dbSeek(xFilial("SA1")+ cCli))	//somente busca por cliente - Leandro   
		dDataLib := SA1->A1_DATALIB
		
		If EMPTY(dDataLib)
			nDiasLib := 0
		Else  
			dDate1 	 := dDataBase 
			nDiasLib := DateDiffDay( dDate1 , dDataLib )
			IF nDiasLib < 0
				nDiasLib := nDiasLib * -1
			Endif
		ENDif 
		
		//60 dias sem emitir notas 
		//Se nao tiver titulos bloqueia o cliente e nao permite salvar 				
		If (nDias >= 60 .AND. nDiasLib >= 60) .OR. (nDias >= 60 .AND. nDiasLib == 0)
			cMsg := "O Cliente " + cCli + " encontra-se inativo por não emitir notas nos últimos 60 dias. Realize o desbloqueio para emitir novos pedidos!"
			lRet := .F.   
			MsgAlert( cMsg, "Atenção!" )
			If SA1->A1_MSBLQL == "2"  //ativo 
				RecLock("SA1",.F.)
				SA1->A1_MSBLQL := "1" //inativo 
				SA1->(MsUnLock())
			Endif 
		EndIf 
	EndIf  
		
	//Primeiro pedido 
	If nDias == 0 
		cMsg := "Realizado o primeiro pedido do Cliente " + cCli + ". Caso fique 60 dias sem emissão, será realizado o bloqueio do mesmo!"
		MsgAlert( cMsg, "Atenção!" ) 
	EndIf 
			
EndIf

RestArea(_aArea)
Return(lRet)