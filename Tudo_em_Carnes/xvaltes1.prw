#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} xvaltes1
@description Preenche a TES para todos os itens do pedido. 
Criar gatilho C5_CLIENTE para C5_CLIENTE. Campos de controle A1_XTESSNA e A1_SIMPNAC.                        
@type function

@author Leandro Procopio	
@since 29 04 2019
@version 1.0
/*/
user function xvaltes1()

Local _nItem
Local cCLi     := M->C5_CLIENTE
Local cNum     := M->C5_CLIENTE
Local cTes     := Posicione("SA1",1,xFilial("SA1") + cCLi,"A1_XTESSNA")   //criar o campo A1_XTESSNA
Local cSnac    := Posicione("SA1",1,xFilial("SA1") + cCLi,"A1_SIMPNAC")   //opt simples nacional 
Local cGrup	   := Posicione("SA1",1,xFilial("SA1") + cCLi,"A1_GRPTRIB")   //grupo cliente 
Local cSnacPro := ""
Local cprod    := ""
Local _cQuery  := ""        
Local cAliasQry        

nPosTes  := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_TES"})      //tes item 
nPosProd := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_PRODUTO"})  //Produto item
nPosTipo := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_OPER"})     //Tipo Oper. item

_cQuery := "select FM_TIPO TIPO, FM_TS TESINT, FM_GRTRIB GRUPOT, FM_PRODUTO PRODUTO from "+ RetSqlName("SFM")
_cQuery += " where FM_FILIAL ='"+ xFilial("SFM") +"'"
_cQuery += " and FM_GRTRIB ='"+ cGrup +"'"  //filtra pelo grupo tributario
_cQuery += " and D_E_L_E_T_ = ' '"
     		
If Select("cAliasQry")>0 ; ("cAliasQry")->(dbCloseArea()) ; EndIf
DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cQuery)), "cAliasQry", .F., .T.)		

For _nItem := 1 to Len(aCols)                    
    //If ! aCols[_nItem,Len(aHeader)+1] 
     	If cSnac == "1" .AND. cGrup == "010"  //.AND. cTes <> ''    //cliente simples nacional com tes sugerida 
     		cprod 	 := aCols[_nItem,nPosProd]
     		//cSnacPro := Posicione("SA1",1,xFilial("SB1") + cprod,"B1_XSIMNAC")   //criar o campo B1_XSIMNAC  
     		
     		//If cAliasQry->(!Eof()) 	
     			If cAliasQry->(!Eof()) .AND. cAliasQry->GRUPOT == cGrup .AND. cAliasQry->PRODUTO == cprod     			
     				aCols[_nItem,nPosTes] := cAliasQry->TESINT  //preenche tes 
     				aCols[_nItem,nPosTipo]:= cAliasQry->TIPO //preenche tipo oper. 
     			Endif 
     			//cAliasQry->(dbSkip())		
     		//Endif
     		//cAliasQry->(dbCloseArea()) 	
     	Endif 
    //Endif 	
Next

return cCLi