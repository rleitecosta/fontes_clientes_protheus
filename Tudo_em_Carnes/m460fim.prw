#include "totvs.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Frank Zwarg Fuga    º Data ³  05/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada apos a gravacao da nota fiscal de saida   º±±
±±º          ³ para geracao da OP                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                               

User Function M460FIM
Local _aArea    := GetArea()
Local _aAreaSFT := SFT->(GetArea())   //leandro 
Local _cNota    := SF2->F2_DOC
Local _cSerie   := SF2->F2_SERIE
Local _cCliente := SF2->F2_CLIENTE
Local _cLoja    := SF2->F2_LOJA
Local _nReg	    := SD2->(Recno())
Local _aProduto := {}
Local _nX               
Local nOpc		:= 3
Local _lGravouOP:= .F.
Local _cOrdens	:= ""


Private lMsErroAuto     := .F.

SG1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2")+_cNota+_cSerie+_cCliente+_cLoja))
While !SD2->(Eof()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+_cNota+_cSerie+_cCliente+_cLoja
	If SG1->(dbSeek(xFilial("SG1")+SD2->D2_COD)) // so gera op se o produto tiver estrutura
		aadd(_aProduto,{SD2->D2_COD, SD2->D2_QUANT, SD2->D2_UM, SD2->D2_LOCAL, "", SD2->D2_ITEM})
	EndIF
	SD2->(dbSkip())
EndDo                                               

For _nX := 1 to Len(_aProduto)
	
	aMata650  := {  {'C2_FILIAL'   	, xFilial("SC2")		,NIL},;
                 	{'C2_PRODUTO'  	, _aProduto[_nX][01]	,NIL},;                 
                	{'C2_LOCAL'		, _aProduto[_nX][04]	,NIL},;                              
                	{'C2_QUANT'		, _aProduto[_nx][02]	,NIL},;
                	{'C2_UM'		, _aProduto[_nx][03]	,NIL},;
                	{'C2_DATPRI'	, dDataBase				,NIL},;
                	{'C2_DATPRF'	, dDataBase				,NIL},;
                	{'C2_EMISSAO'	, dDataBase				,NIL},;
                	{'C2_TPOP'		, "F"					,NIL},;
                	{'C2_TPPR'		, "I"					,NIL}}
                	
	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
	If !lMsErroAuto
    	_aProduto[_nX][05] := SC2->C2_NUM	
	Else
    	ConOut("Erro!")
    	MostraErro()
	EndIf
 
Next                                     

_lGravouOP := .F.
      
// Gravacao da numeracao da OP nas tabelas
_cOrdens := ""
For _nX:=1 to Len(_aProduto)
	If !empty(_aProduto[_nX][05])
		If SD2->(dbSeek(xFilial("SD2")+_cNota+_cSerie+_cCliente+_cLoja+_aProduto[_nX][01]+_aProduto[_nX][06]))
			SD2->(RecLock("SD2",,.F.))
			SD2->D2_OP := _aProduto[_nX][05]
			SD2->(MsUnlock())                  
			
			SC6->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV+D2_COD)))
				SC6->(RecLock("SC6",,.F.))
				SC6->C6_NUMOP := _aProduto[_nX][05]
				SC6->(MsUnlock())
			EndIf
			
			_lGravouOP := .T.  
			_cOrdens += _aProduto[_nX][05]+" "
		EndIF                                     
    EndIF
Next

If _lGravouOP
	MsgAlert("A(s) OP(s): "+_cOrdens+"foi(ram) gerada(s) para a nota fiscal: "+_cNota,"Ordens de produção.")
EndIf                   

SD2->(dbGoto(_nReg))

/*
Leandro -ITUP 
Grava 1 real nos novos campos de tributacao da Sefaz com base no calculo de media 
das notas de entrada pelo modulo de compras.
Regra para imposto de substituicao tributaria >>> (classificacao fiscal 060)
*/ 

Begin transaction 
//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO 
_cQuery := "select FT_TIPOMOV TIPOMOV, FT_SDOC SDOC, FT_EMISSAO EMISSAO, FT_CLASFIS CLASFIS, FT_FILIAL FILIAL, FT_NFISCAL NFISCAL, FT_SERIE SERIE, FT_CLIEFOR CLIEFOR, FT_LOJA LOJA, FT_ITEM ITEM, FT_PRODUTO PRODUTO from "+ RetSqlName("SFT")
_cQuery += " where FT_FILIAL ='"+ xFilial("SFT") +"'"
_cQuery += " and FT_CLASFIS = '060'"  	      //classificacao fiscal 
_cQuery += " and FT_EMISSAO >= '20190507'"   //inicio obrigacao sefaz 
_cQuery += " and D_E_L_E_T_ = ' '"
     		
If Select("cAliasQry")>0 ; ("cAliasQry")->(dbCloseArea()) ; EndIf
DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cQuery)), "cAliasQry", .F., .T.)		

While cAliasQry->(!Eof()) 
	
	DbSelectArea("SFT")
	SFT->( Dbsetorder(1) )                                                
	SFT->( DbSeek( cAliasQry->FILIAL + cAliasQry->TIPOMOV + cAliasQry->SERIE + cAliasQry->NFISCAL + cAliasQry->CLIEFOR + cAliasQry->LOJA + cAliasQry->ITEM + cAliasQry->PRODUTO ) )       
	 																		 			
	While SFT->(!(Eof())) .AND. SFT->FT_FILIAL    = cAliasQry->FILIAL  .AND.;
	             			    SFT->FT_TIPOMOV   = cAliasQry->TIPOMOV .AND.;
	             			    SFT->FT_SERIE 	  = cAliasQry->SERIE   .AND.;
	             			    SFT->FT_NFISCAL   = cAliasQry->NFISCAL .AND.; 
	             			    SFT->FT_CLIEFOR   = cAliasQry->CLIEFOR .AND.;
	             			    SFT->FT_LOJA 	  = cAliasQry->LOJA    .AND.;
	             			    SFT->FT_ITEM 	  = cAliasQry->ITEM    .AND.;
	             			    SFT->FT_PRODUTO   = cAliasQry->PRODUTO   
	                                                                             			    
		//Gravo valores de base se estiverem vazios  
		IF SFT->FT_PSTANT == 0
			RecLock("SFT",.F.)
			SFT->FT_PSTANT := 1	
			SFT->(MsUnlock() )  
		Endif 
		IF SFT->FT_VSTANT == 0
			RecLock("SFT",.F.)
			SFT->FT_VSTANT := 1	
			SFT->(MsUnlock() )  
		Endif 
		IF SFT->FT_BSTANT == 0
			RecLock("SFT",.F.)
			SFT->FT_BSTANT := 1	
			SFT->(MsUnlock() )  
		Endif 
				
		SFT->( dbSkip() )
	 EndDo

cAliasQry->(dbSkip())
EndDo

End transaction  

RestArea(_aAreaSFT)
RestArea(_aArea)                
Return .T.


/*
leandro
modelo 
Local cPedido  := ''
    Local cCampo   := ''
    Local aAreaSF2 := SF2->(GetArea())
    Local aAreaSD2 := sd2->(GetArea())
    Local aAreaSC5 := sc5->(GetArea())
    Local aAreaSE1 := sE1->(GetArea())
    Local aAreaSA1 := sA1->(GetArea())
     
    //Pega o pedido
    DbSelectArea("SD2")
    SD2->(DbSetorder(3))
    If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
        cPedido := SD2->D2_PEDIDO
    Endif          
     
    //Se tiver pedido
    If !Empty(cPedido)
        DbSelectArea("SC5")
        SC5->(DbSetorder(1))
         
        //Se posiciona pega o tipo de pagamento
        If SC5->(DbSeek(FWxFilial('SC5')+cPedido))
            cCampo := SC5->C5_X_CAMPO
        Endif
    Endif     
     
    //Filtra títulos dessa nota
    cSql := "SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SE1")
    cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_<>'*' "
    cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
    cSql += " AND E1_TIPO = 'NF' "
    TcQuery ChangeQuery(cSql) New Alias "_QRY"
     
    //Enquanto tiver dados na query
    While !_QRY->(eof())
        DbSelectArea("SE1")
        SE1->(DbGoTo(_QRY->REC))
         
        //Se tiver dado, altera o tipo de pagamento
        If !SE1->(EoF())
            RecLock("SE1",.F.)
                Replace E1_X_CAMPO WITH cCampo
            MsUnlock()
        EndIf
         
        _QRY->(DbSkip())
    Enddo
    _QRY->(DbCloseArea())
     
    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aAreaSC5)
    RestArea(aAreaSE1)
    RestArea(aAreaSA1)

*/ 