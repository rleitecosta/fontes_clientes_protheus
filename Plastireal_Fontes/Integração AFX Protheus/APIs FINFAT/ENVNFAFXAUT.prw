#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} WSRESTENVNF
    Método para envio da estrutura JSON contendo dados do documento de saida - NF
    @type class
    @author Carlos H. Fernandes
    @since 17/01/2021
    @version P12
    @param body json
    @return objeto json
    @obs EndPoint - http://54.233.177.56:9608/fis/confirmaEmissao 
    @obs Uso Carlson
/*/

User Function ENVNFAFXAUT()

Local aRetNfs	    := {}
Local aPergs	    := {}
Local aMensagens 	:= {}	//Máximo de 7
Local aBotoes 		:= {}	//Máximo de 5
Local nOpc          := 0
Local lExecuta      := .T.
Local cNfIni		:= space(TamSx3('F2_DOC')[1])
Local cNfFim		:= cNfIni
Local cSerAt		:= space(TamSx3('F2_SERIE')[1])
Local cQuery        := ""
Local cAliasNFS     := GetNextAlias()
Local cProcessa     := SPACE(1)
Local lProcessa     := .F.



		aAdd( aPergs ,{1,"Nota Fiscal de:",cNfIni,"@!",'','SF2','.T.',50,.F.})//1
		aAdd( aPergs ,{1,"Nota Fiscal até:",cNfFim,"@!",'','SF2','.T.',50,.F.})//2
		aAdd( aPergs ,{1,"Série:",cSerAt,"@!",'',,'.T.',50,.F.})//3
        aAdd( aPergs ,{1,"Processa Todos:",cProcessa,"@!",'',,'.T.',50,.F.})//3
        
        	
	
		If ParamBox(aPergs ,"Parametros de Exportação",aRetNfs) 

			if  Empty(aRetNfs[1]) .or. Empty(aRetNfs[2]) .or. Empty(aRetNfs[3]) 

				Help('',1,'NEWM0001_01',,"Parametros",1,0,,,,,,{"Informe todos os parametros, um intervalo de data ou um intervalo de notas com a série."})
				Return 

			EndIf

		Else

			Return

		EndIf


 
aAdd( aMensagens, 'Esta Rotina tem o Objetivo de Enviar as ')
aAdd( aMensagens, 'notas Fiscais não integradas entre Protheus e AFX')
 
aAdd( aBotoes, { 1, .T., { || nOpc := 1, FechaBatch() } } )
aAdd( aBotoes, { 2, .T., { || nOpc := 2, FechaBatch() } } )
//aAdd( aBotoes, { 3, .T., { || nOpc := 3, FechaBatch() } } )
//aAdd( aBotoes, { 4, .T., { || nOpc := 4,  } } )
aAdd( aBotoes, { 5, .T., { || ParamBox(aPergs ,"Parametros de Processamento",aRetNfs)  } } )
 
While  lExecuta  

FormBatch( 'Processa Notas AFX Protheus', aMensagens, aBotoes, {|| Iif( MsgYesNo( 'Processa as notas?', ), nOpc := 5,  ) }, 300, 400 )
 
If nOpc == 1
 
MsgInfo( 'Ok', '' )
 
ElseIf nOpc == 2
 
lExecuta      := .F.
 

ElseIf nOpc == 5
 
If select(cAliasNFS) > 0
    (cAliasNFS)->(dbCloseArea())
Endif

cQuery := " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA "+ CRLF
cQuery += " FROM " + RETSQLNAME("SF2") +CRLF
cQuery += " WHERE F2_XAFXSTA !='I' AND F2_DOC BETWEEN '"+aRetNfs[1]+"' AND '"+aRetNfs[2]+"' AND F2_SERIE = '"+aRetNfs[3]+"' AND D_E_L_E_T_ = '' "+CRLF

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasNFS, .F., .T. )

dbSelectArea((cAliasNFS))
(cAliasNFS)->(dbGoTop())

If Alltrim(aRetNfs[4]) = "S"
    lProcessa := .T.
Endif

While (cAliasNFS)->(!Eof())
    U_WSRESTNF((cAliasNFS)->F2_DOC, (cAliasNFS)->F2_SERIE,lProcessa)
(cAliasNFS)->(dbSkip())
Enddo
 
Endif

Enddo
msgInfo("Fim da Integração, verifique!")


Return()



Return()
