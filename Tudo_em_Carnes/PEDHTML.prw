#INCLUDE "Protheus.ch"
#INCLUDE "TBIconn.ch"
#INCLUDE 'Totvs.ch'

User Function EPEDHTML(_Filial,_nMod,_Chave,_Opc)

Local cHtml     := ""
Local cQuery    := ""
Local nTotal    := 0
Local cAliasSC5 := GetNextAlias()
Local cAliasSC6 := GetNextAlias()
Local nItem     := 0
Local nValIpi   := 0 
Local nValIcm   := 0
Local nValIcms  := 0
Local nAliqIpi  := 0
Local aRefImp   := {}
Local nTotIpi   := 0
Local nTotSt    := 0
Local nTotPed   := 0
Local nTotIcm   := 0


Local _nTamFil := len( FWCodFil())
Local _cFilExec:= left(alltrim(Upper(SuperGetMv("FS_TCEMPTR",,"040101"))),_nTamFil)
Local _cGrupos := alltrim(Upper(SuperGetMv("FS_TCGRPRD",,"")))
Local _aInfoPr := {}
Local _aInfoSC5:= {}
Local _aInfoSC6:= {}

Default _Filial := '010103'
Default _nMod    := 0
Default _Chave  := ''
Default _Opc    := 3

If _nMod == 1

    cQuery += " SELECT * FROM "+ RetSqlName("SC5") + " SC5 "
    cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_COD = C5_CLIENT AND A1_LOJA = C5_LOJACLI "
    cQuery += "    AND SA1.D_E_L_E_T_ = '' "
    cQuery += " WHERE C5_FILIAL = '" + _Filial + "' "     
    cQuery += " AND   C5_NUM    = '" + _Chave + "' "	
    cQuery += " AND SC5.D_E_L_E_T_ = '' "
    //MemoWrite("PEDHTML.SQL", cQuery)
    cQuery := ChangeQuery(cQuery)	
    dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), cAliasSC5,.F.,.T.)	
    
    DbSelectArea("SE4")
    SE4->(DbSetOrder(1))
    SE4->(DbSeek(xFilial("SE4")+(cAliasSC5)->C5_CONDPAG))
    cCondPag := SE4->E4_DESCRI
    _Cliente := ''
    
    dEmissao := stod((cAliasSC5)->C5_EMISSAO)
    cEmissao := dtoc(dEmissao)
    
    dPrvEnt := stod((cAliasSC5)->C5_SUGENT)
    cPrvEnt := dtoc(dEmissao)
    
    cHtml += '<html>'
    cHtml += '<head>'	
    cHtml += '<style>body{ font-family: verdana;}</style>'
    cHtml += '</head>'	
    cHtml += '<body>'	
    cHtml += '<center>'
    cHtml += '<table border="1" cellpadding="5" cellspacing="0" style="font-size: 14px;">'			
    cHtml += '<tr>'
    cHtml += '<td colspan="13"><center><strong>PEDIDO DE VENDA - PORTAL DE VENDAS</strong></strong></td>'
    cHtml += '</tr>'			
    cHtml += '<tr>'
    cHtml += '<td><strong>Número</strong></td>'
    cHtml += '<td>'+ _Chave +'</td>'
    cHtml += '<td><strong>Cliente</strong></td>'
    cHtml += '<td colspan="10">'+ (cAliasSC5)->A1_NREDUZ +'</td>'
    cHtml += '</tr>'
                    
    cHtml += '<tr>'
    cHtml += '<td><strong>Emissão</strong></td>'
    cHtml += '<td>'+ cEmissao +'</td>'
    cHtml += '<td><strong>Prev. Entrega</strong></td>'
    cHtml += '<td colspan="10">'+ cPrvEnt +'</td>'
    cHtml += '</tr>'
    
    /*
    cHtml += '<tr>'
    cHtml += '<td><strong>Pedido de Compra</strong></td>'
    cHtml += '<td><strong>Desconto</strong></td>'
    cHtml += '<td colspan="11">'+ cValtoChar((cAliasSC5)->C5_DESC1) +' %</td>'
    cHtml += '</tr>'		
    */

    cHtml += '<tr>'
    cHtml += '<td colspan="13"></td>'
    cHtml += '</tr>'
    cHtml += '<tr>'
    cHtml += '<td colspan="13"><center><strong>Itens do Pedido</strong></center></td>'
    cHtml += '</tr>'				
    cHtml += '<tr style="text-align: center; font-weight: bold;">'
    cHtml += '<td>Código</td>'
    cHtml += '<td colspan="7">Descrição</td>'
    cHtml += '<td>Quantidade</td>'
    cHtml += '<td>Preço Tabela</td>'
    //cHtml += '<td>Desconto</td>'
    //cHtml += '<td>Valor Desconto</td>'
    cHtml += '<td>IPI</td>'
    cHtml += '<td>ICMS</td>'
    cHtml += '<td>Total</td>'
    cHtml += '</tr>'
 
    cQry := " SELECT C6_PRODUTO, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_VALDESC, C6_DESCONT, C6_TES ,C6_ITEM ,C6_DESCRI, C6_NFORI, C6_SERIORI FROM "+ RetSqlName("SC6") + " SC6 "
    cQry += " WHERE C6_FILIAL = '" + _Filial + "'"    
    cQry += " AND      C6_NUM = '" + _Chave + "'"
    cQry += " AND      C6_CLI = '" + (cAliasSC5)->A1_COD + "' "
    cQry += " AND      C6_LOJA = '" + (cAliasSC5)->A1_LOJA + "' "
    cQry += " AND SC6.D_E_L_E_T_ = '' "
    cQry += " ORDER BY C6_ITEM "	
    cQry := ChangeQuery(cQry)	
    dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry), cAliasSC6,.F.,.T.)
    
        //Calculo de impostos para pedidos de vendas
    If _nMod == 1
        aImpostos := U_CalcImp(_Filial,_Chave,_nMod)
    EndIf
    
    dbSelectArea("SA1")
    dbSetorder(1)
    dbSeek(xFilial("SA1")+_Cliente+"01")

    While (cAliasSC6)->(!Eof())	

        // Rotina Desmembramento de Itens ativo?
        _lPrTr := .F.
        If !empty(_cFilExec) 

            // Informação do Grupo Produto
			_aInfoPr := GetAdvFVal("SB1", {"B1_GRUPO"}, FwxFilial("SB1") + (cAliasSC6)->C6_PRODUTO, 1, {''} )
            _lPrTr   := alltrim(Upper(_aInfoPr[01])) $ _cGrupos

        EndIf

        // Se não for produto de transferência
        If !_lPrTr
            dbSelectArea("SB1")
            dbSetorder(1)
            dbSeek(xFilial("SB1")+(cAliasSC6)->C6_PRODUTO)
            // MsgInfo("produto é o "+(cAliasSC6)->C6_PRODUTO+" e o grupo é o "+SB1->B1_GRUPO)           //nItem := (cAliasSC6)->C6_ITEM
            If !(Alltrim(SB1->B1_GRUPO) $ "0011|0017|0018|0019|0020") 
                
                nItem++
                MaFisIni((cAliasSC5)->A1_COD,(cAliasSC5)->A1_LOJA,"C","N",(cAliasSC5)->A1_TIPO,aRefImp)
                MaFisIniLoad(nItem)
                MaFisLoad("IT_PRODUTO" ,(cAliasSC6)->C6_PRODUTO,nItem)
                MaFisLoad("IT_TES"     ,(cAliasSC6)->C6_TES    ,nItem)
                MaFisLoad("IT_QUANT"   ,(cAliasSC6)->C6_QTDVEN ,nItem)
                MaFisLoad("IT_PRCUNI"  ,(cAliasSC6)->C6_PRCVEN,nItem)
                MaFisLoad("IT_VALMERC" ,(cAliasSC6)->C6_VALOR ,nItem)
                MaFisLoad("IT_BASEIPI" ,(cAliasSC6)->C6_VALOR ,nItem)
                MaFisLoad("IT_BASEICM" ,(cAliasSC6)->C6_VALOR ,nItem)
                MaFisRecal("IT_TES"    ,nItem)
                MaFisRecal("IT_ALIQICM",nItem)
                MaFisRecal("IT_VALIPI" ,nItem)
                MaFisRecal("IT_VALSOL" ,nItem)
                MaFisEndLoad(nItem,2)

                nValIpi  := MaFisRet(nItem,"IT_VALIPI")
                nValIcm  := MaFisRet(nItem,"IT_VALSOL")
                nAliqIpi := MaFisRet(nItem,"IT_ALIQIPI")
                nValIcms := MaFisRet(nItem,"IT_VALICM")
            Endif
        
            nVlrVnd := (cAliasSC6)->C6_PRCVEN
            nSubTot := (cAliasSC6)->C6_QTDVEN * nVlrVnd
                        
            cHtml += '<tr>'
            cHtml += '<td>'+ (cAliasSC6)->C6_PRODUTO +'</td>'
            cHtml += '<td colspan="7">'+ (cAliasSC6)->C6_DESCRI +'</td>'
            cHtml += '<td style="text-align: center;"> '  + cValToChar((cAliasSC6)->C6_QTDVEN) + '</td>'
            cHtml += '<td style="text-align: right;">R$ ' + Transform((cAliasSC6)->C6_PRCVEN,"@E 999,999,999.99") + '</td>'
            cHtml += '<td style="text-align: right;">R$ ' + Transform(nValIpi,"@E 999,999,999.99") + ' </td>'
            cHtml += '<td style="text-align: right;">R$ ' + Transform(nValIcm,"@E 999,999,999.99") + ' </td>'
            cHtml += '<td style="text-align: right;">R$ ' + Transform(nSubTot,"@E 999,999,999.99") + ' </td>'
            cHtml += '</tr>'

                If !Empty(aImpostos)
                    nTotal  += nSubTot
                    nTotIpi := aImpostos[1][4]//nValIpi
                    nTotSt  := aImpostos[1][6]//nValIcm
                    nTotIcm := aImpostos[1][2]//nValIcms 
                Else
                    nTotal  += nSubTot
                    nTotIpi += nValIpi
                    nTotSt  += nValIcm
                EndIf            

        Else

            // Guarda Info Cabeçalho para transferência - Sc5
            if Empty(_aInfoSC5)

                Aadd(_aInfoSC5, {   (cAliasSC5)->C5_CLIENTE,;                        // 01 - Codigo Cliente/Fornecedor
				                    (cAliasSC5)->C5_LOJACLI,;                        // 02 - Loja do Cliente/Fornecedor
				                    Iif((cAliasSC5)->C5_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
				                    (cAliasSC5)->C5_TIPO,;                           // 04 - Tipo da NF
				                    (cAliasSC5)->C5_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
				                    MaFisRelImp("MTR700", {"SC5","SC6"}),;           // 06 - Relacao de Impostos que suportados no arquivo
				                    ,;                                               // 07 - Tipo de complemento
				                    ,;                                               // 08 - Permite Incluir Impostos no Rodape .T./.F.
				                    "SB1",;                                          // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				                    "MATA461",;                                      // 10 - Nome da rotina que esta utilizando a funcao
                                    SE4->E4_DESCRI,;                                 // 11 - Desc Cond Pgto.
                                    cEmissao,;                                       // 12 - Dt Emissão
                                    cPrvEnt,;                                        // 13 - Previsão Entrega
                                    _Chave,;                                        // 14 - Número do PV
                                    (cAliasSC5)->A1_NREDUZ,;                           // 15 - Nome CLiente   
                                    _Opc,;                                           // 16 - Opção 
                                    _Cliente })                                      // 17 - Parâmetro Cod CLiente      
         
            EndIf
            
            // Localiza o Item
            DBSelectArea( "SB1" )
            SB1->( DBSetOrder( 1 ))
            SB1->( DbSeek( FWxFilial("SB1") + (cAliasSC6)->C6_PRODUTO))

            // Guarda os itens para transferência - Sc6
             Aadd(_aInfoSC6, {  (cAliasSC6)->C6_PRODUTO,;     // 01 - Codigo do Produto                    ( Obrigatorio )
	                            (cAliasSC6)->C6_TES,;         // 02 - Codigo do TES                        ( Opcional )
	                            (cAliasSC6)->C6_QTDVEN,;      // 03 - Quantidade                           ( Obrigatorio )
	                            (cAliasSC6)->C6_PRCVEN,;      // 04 - Preco Unitario                       ( Obrigatorio )
	                            (cAliasSC6)->C6_VALDESC,;     // 05 - Desconto
	                            (cAliasSC6)->C6_NFORI,;       // 06 - Numero da NF Original                ( Devolucao/Benef )
	                            (cAliasSC6)->C6_SERIORI,;     // 07 - Serie da NF Original                 ( Devolucao/Benef )
	                            0,;                           // 08 - RecNo da NF Original no arq SD1/SD2
	                            0,;                           // 09 - Valor do Frete do Item               ( Opcional )
                                0,;                           // 10 - Valor da Despesa do item             ( Opcional )
                                0,;                           // 11 - Valor do Seguro do item              ( Opcional )
                                0,;                           // 12 - Valor do Frete Autonomo              ( Opcional )
                                (cAliasSC6)->C6_VALOR,;       // 13 - Valor da Mercadoria                  ( Obrigatorio )
                                0,;                           // 14 - Valor da Embalagem                   ( Opcional )
                                SB1->(RecNo()),;              // 15 - RecNo do SB1
                                0 ,;                          // 16 - RecNo do SF4
                                (cAliasSC6)->C6_DESCRI })     // 17 - Descrição Produto

            // Retorno area corrente
            dbSelectArea(cAliasSC6)   

        Endif

        (cAliasSC6)->(dbskip())
    
    EndDo
    
    (cAliasSC6)->(dbclosearea())
    If !Empty(aImpostos)
        nTotPed := aImpostos[1][7]
    Else 
        nTotPed := nTotal+nTotIpi+nTotSt
    EndIf
    
    cHtml += '<tr>'
    cHtml += '<td colspan="10"><strong>Total</strong></td>'
    cHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(nTotIpi,"@E 999,999,999.99") + '</strong></td>'
    cHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(nTotSt ,"@E 999,999,999.99") + '</strong></td>'
    cHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(nTotal ,"@E 999,999,999.99") + '</strong></td>'
    cHtml += '</tr>'
    cHtml += '<tr>'
    cHtml += '<td colspan="12"><strong>Total Pedido</strong></td>'
    cHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(nTotPed ,"@E 999,999,999.99") + '</strong></td>'
    cHtml += '</tr>'			
    cHtml += '<tr>'
    cHtml += '<td colspan="13" style="font-size: 12px;"><center><em>Pedido emitido pelo portal de vendas - ' + dtoc(date()) + ' - ' + TIME() + '<em></center></td>'
    cHtml += '</tr>'
    cHtml += '</table>'
    cHtml += '</center>'
    cHtml += '</body>'
    cHtml += '</html>'
    
    (cAliasSC5)->(dbclosearea())

ElseIf !Empty(_Cliente)

    DbSelectArea('SA1')
    SA1->(DbSetOrder(1))
    SA1->(DbSeek(xFilial()+_Cliente))

    cHtml := '<html>'
    cHtml += '<body>'
    If _Opc == 3
        cHtml += '<h2> Novo Cliente cadastrado: '+AllTrim(SA1->A1_NREDUZ)+' </h2>'
    ElseIf _Opc == 4
        cHtml += '<h2> Cliente: '+AllTrim(SA1->A1_NREDUZ)+' alterado. </h2>'
    EndIf

    cHtml += '</body>'
    cHtml += '</html>'

    

EndIf

// Impressão página de itens transferidos
If !empty(_aInfoSC5) .and. !empty(_aInfoSC6)

    // Coloca-se divisor para salto da página
    cHtml += "<div style='page-break-after:always'></div>"

    // Retorno com continuação do HTML página 2
    cHtml += u_FATA001(_aInfoSC5,_aInfoSC6)   
 
EndIf

//Eecview(cHtml)

Return cHtml


//Função para calculo de impostos do Pedido de Vendas
User Function CalcImp(_Filial,_Chave,_nMod)

Local aPedCli    := {}
Local aStruSC5   := {}
Local aStruSC6   := {}
Local aC5Rodape  := {}
Local aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
Local aFisGet    := Nil
Local aFisGetSC5 := Nil
Local li         := 100 // Contador de Linhas
Local lImp       := .F. // Indica se algo foi impresso
Local lRodape    := .F.
Local cbCont     := 0   // Numero de Registros Processados
Local cbText     := ""  // Mensagem do Rodape
Local cKey 	     := ""
Local cFilter    := ""
Local cAliasSC5  := "SC5"
Local cAliasSC6  := "SC6"
Local cQuery     := ""
Local cQryAd     := ""
Local cName      := ""
Local cPedido    := ""
Local cCliEnt	 := ""
Local cNfOri     := Nil
Local cSeriOri   := Nil
Local nItem      := 0
Local nTotQtd    := 0
Local nTotVal    := 0
Local nDesconto  := 0
Local nPesLiq    := 0
Local nSC5       := 0
Local nSC6       := 0
Local nX         := 0
Local nRecnoSD1  := Nil
Local nG		 := 0
Local nFrete	 := 0
Local nSeguro	 := 0
Local nFretAut	 := 0
Local nDespesa	 := 0
Local nDescCab	 := 0
Local nPDesCab	 := 0
Local nY         := 0
Local nValMerc   := 0
Local nPrcLista  := 0
Local nAcresFin  := 0
Local aRetImp    := {}

Private aItemPed := {}
Private aCabPed	 := {}

FisGetInit(@aFisGet,@aFisGetSC5)

cAliasSC5:= "C730Imp"
cAliasSC6:= "C730Imp"
aStruSC5  := SC5->(dbStruct())		
aStruSC6  := SC6->(dbStruct())		
cQuery := "SELECT SC5.R_E_C_N_O_ SC5REC,SC6.R_E_C_N_O_ SC6REC,"
cQuery += "SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,"
cQuery += "SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_PBRUTO,SC5.C5_PESOL,SC5.C5_DESC1,"
cQuery += "SC5.C5_DESC2,SC5.C5_DESC3,SC5.C5_DESC4,SC5.C5_MENNOTA,SC5.C5_EMISSAO,"
cQuery += "SC5.C5_CONDPAG,SC5.C5_FRETE,SC5.C5_DESPESA,SC5.C5_FRETAUT,SC5.C5_TPFRETE,SC5.C5_SEGURO,SC5.C5_TABELA,"
cQuery += "SC5.C5_VOLUME1,SC5.C5_ESPECI1,SC5.C5_MOEDA,SC5.C5_REAJUST,SC5.C5_BANCO,"
cQuery += "SC5.C5_ACRSFIN,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,"
cQuery += "SC5.C5_COMIS1,SC5.C5_COMIS2,SC5.C5_COMIS3,SC5.C5_COMIS4,SC5.C5_COMIS5,SC5.C5_PDESCAB,SC5.C5_DESCONT,C5_INCISS,"

If SC5->(FieldPos("C5_CLIENT"))>0
	cQuery += "SC5.C5_CLIENT,"			
Endif

For nY := 1 To Len(aFisGet)
	cQryAd += aFisGet[nY][2]+","
Next nY

For nY := 1 To Len(aFisGetSC5)
	cQryAd += aFisGetSC5[nY][2]+","
Next nY		

cQuery += cQryAd
cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PEDCLI,SC6.C6_PRODUTO,"
cQuery += "SC6.C6_TES,SC6.C6_CF,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,"
cQuery += "SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_DESCRI,SC6.C6_UM, "
cQuery += "SC6.C6_PRCVEN,SC6.C6_NOTA,SC6.C6_SERIE,SC6.C6_CLI,"
cQuery += "SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_DESCONT,SC6.C6_LOCAL,"
cQuery += "SC6.C6_QTDEMP,SC6.C6_QTDLIB,SC6.C6_QTDENT,SC6.C6_NFORI,SC6.C6_SERIORI,SC6.C6_ITEMORI "
cQuery += "FROM "
cQuery += RetSqlName("SC5") + " SC5 ,"
cQuery += RetSqlName("SC6") + " SC6 "		
cQuery += "WHERE "
cQuery += "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "		
cQuery += "SC5.C5_NUM = '" + _Chave + "' AND "
cQuery += "SC5.D_E_L_E_T_ = ' ' AND "
cQuery += "SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND "		
cQuery += "SC6.C6_NUM   = SC5.C5_NUM AND "
cQuery += "SC6.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY SC5.C5_NUM"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.T.)

For nSC5 := 1 To Len(aStruSC5)
	If aStruSC5[nSC5][2] <> "C" .and.  FieldPos(aStruSC5[nSC5][1]) > 0
		TcSetField(cAliasSC5,aStruSC5[nSC5][1],aStruSC5[nSC5][2],aStruSC5[nSC5][3],aStruSC5[nSC5][4])
	EndIf
Next nSC5

For nSC6 := 1 To Len(aStruSC6)
	If aStruSC6[nSC6][2] <> "C" .and. FieldPos(aStruSC6[nSC6][1]) > 0
		TcSetField(cAliasSC6,aStruSC6[nSC6][1],aStruSC6[nSC6][2],aStruSC6[nSC6][3],aStruSC6[nSC6][4])
	EndIf
Next nSC6		    	

While !((cAliasSC5)->(Eof())) .and. xFilial("SC5")==(cAliasSC5)->C5_FILIAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao dos filtros do usuario           	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasSC5)

		cCliEnt   := IIf(!Empty((cAliasSC5)->(FieldGet(FieldPos("C5_CLIENT")))),(cAliasSC5)->C5_CLIENT,(cAliasSC5)->C5_CLIENTE)

		aCabPed := {}

		MaFisIni(cCliEnt,;							// 1-Codigo Cliente/Fornecedor
			(cAliasSC5)->C5_LOJACLI,;			// 2-Loja do Cliente/Fornecedor
			If((cAliasSC5)->C5_TIPO$'DB',"F","C"),;	// 3-C:Cliente , F:Fornecedor
			(cAliasSC5)->C5_TIPO,;				// 4-Tipo da NF
			(cAliasSC5)->C5_TIPOCLI,;			// 5-Tipo do Cliente/Fornecedor
			aRelImp,;							// 6-Relacao de Impostos que suportados no arquivo
			,;						   			// 7-Tipo de complemento
			,;									// 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;							// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")							// 10-Nome da rotina que esta utilizando a funcao
		//Na argentina o calculo de impostos depende da serie.
		If cPaisLoc == 'ARG'
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(xFilial()+(cAliasSC5)->C5_CLIENTE+(cAliasSC5)->C5_LOJACLI))
			MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
		Endif

		nFrete		:= (cAliasSC5)->C5_FRETE
		nSeguro		:= (cAliasSC5)->C5_SEGURO
		nFretAut	:= (cAliasSC5)->C5_FRETAUT
		nDespesa	:= (cAliasSC5)->C5_DESPESA
		nDescCab	:= (cAliasSC5)->C5_DESCONT
		nPDesCab	:= (cAliasSC5)->C5_PDESCAB

		aItemPed:= {}
		aCabPed := {	(cAliasSC5)->C5_TIPO,;
			(cAliasSC5)->C5_CLIENTE,;
			(cAliasSC5)->C5_LOJACLI,;
			(cAliasSC5)->C5_TRANSP,;
			(cAliasSC5)->C5_CONDPAG,;
			(cAliasSC5)->C5_EMISSAO,;
			(cAliasSC5)->C5_NUM,;
			(cAliasSC5)->C5_VEND1,;
			(cAliasSC5)->C5_VEND2,;
			(cAliasSC5)->C5_VEND3,;
			(cAliasSC5)->C5_VEND4,;
			(cAliasSC5)->C5_VEND5,;
			(cAliasSC5)->C5_COMIS1,;
			(cAliasSC5)->C5_COMIS2,;
			(cAliasSC5)->C5_COMIS3,;
			(cAliasSC5)->C5_COMIS4,;
			(cAliasSC5)->C5_COMIS5,;
			(cAliasSC5)->C5_FRETE,;
			(cAliasSC5)->C5_TPFRETE,;
			(cAliasSC5)->C5_SEGURO,;
			(cAliasSC5)->C5_TABELA,;
			(cAliasSC5)->C5_VOLUME1,;
			(cAliasSC5)->C5_ESPECI1,;
			(cAliasSC5)->C5_MOEDA,;
			(cAliasSC5)->C5_REAJUST,;
			(cAliasSC5)->C5_BANCO,;
			(cAliasSC5)->C5_ACRSFIN;
			}

		nTotQtd		:= 0
		nTotVal		:= 0
		nPesBru		:= 0
		nPesLiq		:= 0
		aPedCli		:= {}
		cPedido		:= (cAliasSC5)->C5_NUM
		aC5Rodape	:= {}
		
		aadd(aC5Rodape,{(cAliasSC5)->C5_PBRUTO,(cAliasSC5)->C5_PESOL,(cAliasSC5)->C5_DESC1,(cAliasSC5)->C5_DESC2,;
			(cAliasSC5)->C5_DESC3,(cAliasSC5)->C5_DESC4,(cAliasSC5)->C5_MENNOTA})

		aPedCli := U_PedHtmCli(cPedido)

		dbSelectArea(cAliasSC5)
		For nY := 1 to Len(aFisGetSC5)
			If !Empty(&(aFisGetSC5[ny][2]))
				If aFisGetSC5[ny][1] == "NF_SUFRAMA"
					MaFisAlt(aFisGetSC5[ny][1],Iif(&(aFisGetSC5[ny][2]) == "1",.T.,.F.),Len(aItemPed),.T.)		
				Else
					MaFisAlt(aFisGetSC5[ny][1],&(aFisGetSC5[ny][2]),Len(aItemPed),.T.)
				Endif	
			EndIf
		Next nY

		While !((cAliasSC6)->(Eof())) .And. xFilial("SC6")==(cAliasSC6)->C6_FILIAL .And.;
				(cAliasSC6)->C6_NUM == cPedido

			cNfOri     := Nil
			cSeriOri   := Nil
			nRecnoSD1  := Nil
			nDesconto  := 0

			If !Empty((cAliasSC6)->C6_NFORI)
				dbSelectArea("SD1")
				dbSetOrder(1)
				dbSeek(xFilial("SC6")+(cAliasSC6)->C6_NFORI+(cAliasSC6)->C6_SERIORI+(cAliasSC6)->C6_CLI+(cAliasSC6)->C6_LOJA+;
					(cAliasSC6)->C6_PRODUTO+(cAliasSC6)->C6_ITEMORI)
				cNfOri     := (cAliasSC6)->C6_NFORI
				cSeriOri   := (cAliasSC6)->C6_SERIORI
				nRecnoSD1  := SD1->(RECNO())
			EndIf

			dbSelectArea(cAliasSC6)

			nValMerc  := (cAliasSC6)->C6_VALOR
			nPrcLista := (cAliasSC6)->C6_PRUNIT
			If ( nPrcLista == 0 )
				nPrcLista := NoRound(nValMerc/(cAliasSC6)->C6_QTDVEN,TamSX3("C6_PRCVEN")[2])
			EndIf
			nAcresFin := A410Arred((cAliasSC6)->C6_PRCVEN*(cAliasSC5)->C5_ACRSFIN/100,"D2_PRCVEN")
			nValMerc  += A410Arred((cAliasSC6)->C6_QTDVEN*nAcresFin,"D2_TOTAL")		
			nDesconto := a410Arred(nPrcLista*(cAliasSC6)->C6_QTDVEN,"D2_DESCON")-nValMerc
			nDesconto := IIf(nDesconto==0,(cAliasSC6)->C6_VALDESC,nDesconto)
			nDesconto := Max(0,nDesconto)
			nPrcLista += nAcresFin

			If cPaisLoc=="BRA"
				nValMerc  += nDesconto
			EndIf			
						
			MaFisAdd((cAliasSC6)->C6_PRODUTO,; 	  // 1-Codigo do Produto ( Obrigatorio )
				(cAliasSC6)->C6_TES,;			  // 2-Codigo do TES ( Opcional )
				(cAliasSC6)->C6_QTDVEN,;		  // 3-Quantidade ( Obrigatorio )
				nPrcLista,;		  // 4-Preco Unitario ( Obrigatorio )
				nDesconto,;       // 5-Valor do Desconto ( Opcional )
				cNfOri,;		                  // 6-Numero da NF Original ( Devolucao/Benef )
				cSeriOri,;		                  // 7-Serie da NF Original ( Devolucao/Benef )
				nRecnoSD1,;			          // 8-RecNo da NF Original no arq SD1/SD2
				0,;							  // 9-Valor do Frete do Item ( Opcional )
				0,;							  // 10-Valor da Despesa do item ( Opcional )
				0,;            				  // 11-Valor do Seguro do item ( Opcional )
				0,;							  // 12-Valor do Frete Autonomo ( Opcional )
				nValMerc,;// 13-Valor da Mercadoria ( Obrigatorio )
				0,;							  // 14-Valor da Embalagem ( Opiconal )
				0,;		     				  // 15-RecNo do SB1
				0) 							  // 16-RecNo do SF4

			aadd(aItemPed,	{	(cAliasSC6)->C6_ITEM,;
				(cAliasSC6)->C6_PRODUTO,;
				(cAliasSC6)->C6_DESCRI,;
				(cAliasSC6)->C6_TES,;
				(cAliasSC6)->C6_CF,;
				(cAliasSC6)->C6_UM,;
				(cAliasSC6)->C6_QTDVEN,;
				(cAliasSC6)->C6_PRCVEN,;
				(cAliasSC6)->C6_NOTA,;
				(cAliasSC6)->C6_SERIE,;
				(cAliasSC6)->C6_CLI,;
				(cAliasSC6)->C6_LOJA,;
				(cAliasSC6)->C6_VALOR,;
				(cAliasSC6)->C6_ENTREG,;
				(cAliasSC6)->C6_DESCONT,;
				(cAliasSC6)->C6_LOCAL,;
				(cAliasSC6)->C6_QTDEMP,;
				(cAliasSC6)->C6_QTDLIB,;
				(cAliasSC6)->C6_QTDENT,;
				})							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Forca os valores de impostos que foram informados no SC6.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSC6)
			For nY := 1 to Len(aFisGet)
				If !Empty(&(aFisGet[ny][2]))
					MaFisAlt(aFisGet[ny][1],&(aFisGet[ny][2]),Len(aItemPed))
				EndIf
			Next nY

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do ISS                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+(cAliasSC6)->C6_TES))
			If ( (cAliasSC5)->C5_INCISS == "N" .And. (cAliasSC5)->C5_TIPO == "N")
				If ( SF4->F4_ISS=="S" )
					nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
					nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(Len(aItemPed))/100)),"D2_PRCVEN")
					MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
					MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
				EndIf
			EndIf	

			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+(cAliasSC6)->C6_PRODUTO))			
			MaFisAlt("IT_PESO",(cAliasSC6)->C6_QTDVEN*SB1->B1_PESO,Len(aItemPed))
			MaFisAlt("IT_PRCUNI",nPrcLista,Len(aItemPed))
			MaFisAlt("IT_VALMERC",nValMerc,Len(aItemPed))
			
			(cAliasSC6)->(dbSkip())
		EndDo
		
		MaFisAlt("NF_FRETE"   ,nFrete)
		MaFisAlt("NF_SEGURO"  ,nSeguro)
		MaFisAlt("NF_AUTONOMO",nFretAut)
		MaFisAlt("NF_DESPESA" ,nDespesa)

		If nDescCab > 0
			MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nDescCab+MaFisRet(,"NF_DESCONTO")))
		EndIf
		If nPDesCab > 0
			MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*nPDesCab/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
		EndIf

        aRetImp := U_RetImpPed(nPesLiq,nTotQtd,nTotVal,@li,nPesBru,aC5Rodape,cAliasSC5,,cAliasSC6)
        //ImpItem(nItem,@nPesLiq,@li,@nTotQtd,@nTotVal,@nPesBru,cAliasSC6,cAliasSC5)

		MaFisEnd()

EndDo

dbSelectArea(cAliasSC5)
dbCloseArea()


RetIndex("SC5")
dbSelectArea("SC5")
dbClearFilter()

dbSelectArea("SC6")
dbClearFilter()
dbSetOrder(1)
dbGotop()

Return aRetImp

Static Function FisGetInit(aFisGet,aFisGetSC5)

Local cValid      := ""
Local cReferencia := ""
Local nPosIni     := 0
Local nLen        := 0

If aFisGet == Nil
	aFisGet	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC6")
	While !Eof().And.X3_ARQUIVO=="SC6"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
EndIf

If aFisGetSC5 == Nil
	aFisGetSC5	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC5")
	While !Eof().And.X3_ARQUIVO=="SC5"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
EndIf
MaFisEnd()
Return(.T.)


User Function PedHtmCli(cPedido)

Local aPedidos := {}
Local aArea    := GetArea()
Local aAreaSC6 := SC6->(GetArea())

SC6->(dbSetOrder(1))
SC6->(MsSeek(xFilial("SC6")+cPedido))

While !(SC6->(Eof())) .And. xFilial("SC6")==SC6->C6_FILIAL .And.;
		SC6->C6_NUM == cPedido

	If !Empty(SC6->C6_PEDCLI) .and. Ascan(aPedidos,SC6->C6_PEDCLI) = 0
		Aadd(aPedidos, SC6->C6_PEDCLI )
	Endif		

	SC6->(dbSkip())
Enddo

RestArea(aAreaSC6)
RestArea(aArea)

Return(aPedidos)

User Function RetImpPed(nPesLiq,nTotQtd,nTotVal,li,nPesBru,aC5Rodape,cAliasSC5,lFinal,cAliasSC6)

Local aCodImps	:=	{}
Local aImpNF    := {}

aadd(aImpNF,{MaFisRet(,"NF_BASEICM"),MaFisRet(,"NF_VALICM"),MaFisRet(,"NF_BASEIPI"),MaFisRet(,"NF_VALIPI") ,;
			MaFisRet(,"NF_BASESOL"),MaFisRet(,"NF_VALSOL"),MaFisRet(,"NF_TOTAL"),MaFisRet(,"NF_BASEISS"),MaFisRet(,"NF_VALISS")})

Return aImpNF


