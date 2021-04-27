#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MA040TOK
@description Ponto de entrada Cadastro de motorista 
@type function

@author Leandro Procopio	
@since 18 04 2019 
@version 1.0
/*/
user function MA040TOK()
	
Local lRet := .t.

IF MSGYESNO( "Deseja atualizar os cadastros de clientes?", "MA040TOK" )
	U_XATUSA1C() //Atualizo comissao do vendedor do cliente  
Endif 
	
return lRet 

/*/{Protheus.doc} MA040TOK
@description Veririca comissao do vendedor e atualiza clientes relacionados.  
@type function

@author Leandro Procopio	
@since 18 04 2019 
@version 1.0
/*/
user function XATUSA1C()


Local _aAreaSA1 := SA1->(GetArea())
Local _cQuery	:= ""       
Local cAliasQry  
Local nCom 		:= M->A3_COMIS
Local cCodVen 	:= M->A3_COD
Local _cQuery	:= ""       
Local cAliasQry  

//Atualiza historico 
Begin transaction 

	_cQuery += " SELECT A3_COD, a1_VEND, A3_COMIS, A1_COMIS , A1_COD, A1_LOJA, A1_FILIAL, A3_FILIAL "
	_cQuery += " FROM SA1010 SA1 "
	_cQuery += " INNER JOIN SA3010 SA3 "
	_cQuery += " ON A1_VEND = A3_COD "
	_cQuery += " AND SA3.D_E_L_E_T_ = '' "
	_cQuery += " AND A3_COD = '" + cCodVen + "' "   //filtro o vendedor do cliente 
	_cQuery += " where SA1.D_E_L_E_T_ = '' "
	
	
If Select("cAliasQry")>0 ; ("cAliasQry")->(dbCloseArea()) ; EndIf
DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cQuery)), "cAliasQry", .F., .T.)

While cAliasQry->(!Eof()) 

	SA1->( Dbsetorder(10) )                                                
	SA1->( DbSeek( cAliasQry->A1_FILIAL + cAliasQry->A1_VEND + cAliasQry->A1_COD + cAliasQry->A1_LOJA ) )   
	
	While SA1->(!(Eof())) .AND. SA1->A1_COD  = cAliasQry->A1_COD 	.AND.;
	             			    SA1->A1_LOJA = cAliasQry->A1_LOJA 	.AND.;
	             			    SA1->A1_VEND = cAliasQry->A1_VEND
	 						    
		IF SA1->A1_COMIS <> nCom
			RecLock("SA1",.F.)
			SA1->A1_COMIS := nCom
			SA1->(MsUnlock() )  
		Endif 
	 SA1->( dbSkip() )
	 EndDo

cAliasQry->(dbSkip())
EndDo

End transaction  

RestArea(_aAreaSA1)

Return()
