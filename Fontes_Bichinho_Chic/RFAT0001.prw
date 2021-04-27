#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFAT0001  บAutor  ณDPA                 บ Data ณ  29/01/14   บฑฑ                   
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao de Pedido de Venda.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณElitte Motors                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function RFAT0001(cCod)

Private oPrint

Private cPerg := "XPDVEN"
PutSX1( cPerg,"01","Pedido: ","","","MV_CH1","C",TAMSX3("C5_NUM")[1],TAMSX3("C5_NUM")[2],0,"G","","SC5","","","MV_PAR01")
PutSx1( cPerg,"02","Ordenar por: ","","","MV_CH2","N",1,0,0,"C",,"","","","mv_par02","Item P.V.","Item P.V.","Item P.V.","","Desc.Produto","Desc.Produto","Desc.Produto","","","","","","","",""," ",,,)

If cCod == Nil
	If Pergunte(cPerg,.T.)
		PrtRel()
	Endif
Else
	Pergunte(cPerg,.F.)
	MV_PAR01 := cCod
	PrtRel()
Endif

If ValType(oPrint) == "O"
	oPrint:Preview()
Endif

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPrtRel    บAutor  ณDPA                 บ Data ณ  29/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsavel pela impressao do relatorio              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function PrtRel(cCod)

Local aRelImp       := MaFisRelImp("MT100",{"SF2","SD2"})
Local cAlias        := getNextAlias()
Private oFtA06		:= TFont():New("Arial"          ,06,06,,.F.,,,,.T.,.F.)
Private oFtA07		:= TFont():New("Arial"          ,07,07,,.F.,,,,.T.,.F.)
Private oFtA08		:= TFont():New("Arial"          ,08,08,,.F.,,,,.T.,.F.)
Private oFtA08n		:= TFont():New("Arial"          ,08,08,,.T.,,,,.T.,.F.)
Private oFtA09		:= TFont():New("Arial"          ,09,09,,.F.,,,,.T.,.F.)
Private oFtA10		:= TFont():New("Arial"          ,10,10,,.F.,,,,.T.,.F.)
Private oFtA10n		:= TFont():New("Arial"          ,10,10,,.T.,,,,.T.,.F.)
Private oFtA11		:= TFont():New("Arial"          ,11,11,,.F.,,,,.T.,.F.)
Private oFtA11n		:= TFont():New("Arial"          ,11,11,,.T.,,,,.T.,.F.)
Private oFtA12		:= TFont():New("Arial"          ,12,12,,.F.,,,,.T.,.F.)
Private oFtA12n		:= TFont():New("Arial"          ,12,12,,.T.,,,,.T.,.F.)
Private oFtA15n		:= TFont():New("Arial"          ,15,15,,.T.,,,,.T.,.F.)
Private oFtA15		:= TFont():New("Arial"          ,15,15,,.F.,,,,.T.,.F.)
Private oFtA22		:= TFont():New("Arial"          ,22,22,,.F.,,,,.T.,.F.)
Private oFtA22n		:= TFont():New("Arial"          ,22,22,,.T.,,,,.T.,.F.)
Private oFtA32n		:= TFont():New("Arial"          ,32,32,,.T.,,,,.T.,.F.)

Private oFtC06n		:= TFont():New("Courier New"    ,06,06,,.T.,,,,.T.,.F.)
Private oFtC09		:= TFont():New("Courier New"    ,09,09,,.F.,,,,.T.,.F.)
Private oFtC11n		:= TFont():New("Courier New"    ,10,08,,.t.,,,,.T.,.F.)
Private oFtC11		:= TFont():New("Courier New"    ,11,08,,.f.,,,,.T.,.F.)

Private oFtT14		:= TFont():New("Times New Roman",14,14,,.F.,,,,.T.,.F.)

Private nPag := 1


If ValType(oPrint) != "O"
	oPrint 	:= TMSPrinter():New("PEDVEN")
	oPrint:Setup()
	oPrint:SetPortrait()
	cStartPath := GetSrvProfString("StartPath","system")
	cLogo := cStartPath + "lgrl02.BMP"
Endif


cQry := "SELECT  C5_NUM, C5_EMISSAO, C6_CLI, A1_NOME, A1_END, A1_MUN, A1_EST, A1_BAIRRO, A1_CEP, A1_CGC, A1_INSCR, A1_EMAIL, C5_TRANSP, C5_VEND1,A1_COD,A1_LOJA,A1_TIPO,"
cQry += " C5_TIPOCLI ,C6_TES,C5_FRETE,"
cQry += " C5_VOLUME1, C5_ESPECI1, E4_DESCRI, C5_DESPESA, C5_SEGURO, C5_DESC1, C5_DESCFI, C5_FECENT,C5_PESOL,C5_PBRUTO,C6_VALDESC,C5_DESPESA,C5_SEGURO,"
cQry += " C5_TPFRETE, C5_FRETE, C5_MENNOTA, C5_DESCONT,"
cQry += " ISNULL(A4_NREDUZ,' ') A4_NREDUZ, ISNULL(A3_NREDUZ,' ') A3_NREDUZ, C5_VEND2, C5_COMIS2,"
cQry += " A1_CONTATO, A1_DDD, A1_TEL, C5_COTACAO, C6_ENTREG, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_DESCRI, C6_PRCVEN, C6_VALOR"
cQry += " FROM "+RetSqlName("SC5")+" C5 INNER JOIN "+RetSqlName("SC6")+" C6 ON C5_NUM = C6_NUM"
cQry += " LEFT JOIN "+RetSqlName("SA1")+" A1 ON C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1.D_E_L_E_T_ <> '*'"
cQry += " LEFT JOIN "+RetSqlName("SB1")+" B1 ON C6_PRODUTO = B1_COD AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1.D_E_L_E_T_ <> '*'"
cQry += " LEFT JOIN "+RetSqlName("SE4")+" E4 ON C5_CONDPAG = E4_CODIGO AND E4_FILIAL = '"+xFilial("SE4")+"' AND E4.D_E_L_E_T_ <> '*'"
cQry += " LEFT JOIN "+RetSqlName("SA3")+" A3 ON A1_VEND = A3_COD AND A3_FILIAL = '"+xFilial("SA3")+"' AND A3.D_E_L_E_T_ <> '*'"
cQry += " LEFT JOIN "+RetSqlName("SA4")+" A4 ON C5_TRANSP = A4_COD AND A4_FILIAL = '"+xFilial("SA4")+"' AND A4.D_E_L_E_T_ <> '*'"
cQry += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += " AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += " AND C5_NUM = '"+MV_PAR01+"'"
cQry += " AND C5.D_E_L_E_T_ <> '*'"
cQry += " AND C6.D_E_L_E_T_ <> '*'"
cQry += " ORDER BY C6_ITEM"

MemoWrite( "C:\query\testSave.txt", cQry )


DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.T.)

dbSelectArea((cAlias))
(cAlias)->(dbGotop())

nTItem := 0
nTPBru := 0
nTPLiq := 0
nTVPro := 0
nTVIpi := 0
nTVST  := 0
nTDescZf  := 0
nDesc := 0

MaFisIni((cAlias)->A1_COD,;		     // 1-Codigo Cliente/Fornecedor
		(cAlias)->A1_LOJA,;		     // 2-Loja do Cliente/Fornecedor
		"C",;	                     // 3-C:Cliente , F:Fornecedor
		"N",;               		 // 4-Tipo da NF
		(cAlias)->A1_TIPO,;   		 // 5-Tipo do Cliente/Fornecedor
		aRelImp,;					 // 6-Relacao de Impostos que suportados no arquivo
		,;						   	 // 7-Tipo de complemento
		,;							 // 8-Permite Incluir Impostos no Rodape .T./.F.
		"SB1",;						 // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		"MATA461")					 // 10-Nome da rotina que esta utilizando a funcao

If (cAlias)->(!EOF())

Do While (cAlias)->(!EOF())

	MaFisAdd((cAlias)->C6_PRODUTO,; 	                // 1-Codigo do Produto ( Obrigatorio )
			 (cAlias)->C6_TES,;			            // 2-Codigo do TES ( Opcional )
			 (cAlias)->C6_QTDVEN,;		            // 3-Quantidade ( Obrigatorio )
			 (cAlias)->C6_PRCVEN,;	                // 4-Preco Unitario ( Obrigatorio )
			 (cAlias)->C6_VALDESC,;                  // 5-Valor do Desconto ( Opcional )
			 SPACE(9),;	                        // 6-Numero da NF Original ( Devolucao/Benef )
			 SPACE(3),;	                        // 7-Serie da NF Original ( Devolucao/Benef )
			 0,;      			                // 8-RecNo da NF Original no arq SD1/SD2
			 (cAlias)->C5_FRETE,;					// 9-Valor do Frete do Item ( Opcional )
			 (cAlias)->C5_DESPESA,;                  // 10-Valor da Despesa do item ( Opcional )
			 (cAlias)->C5_SEGURO,;          		    // 11-Valor do Seguro do item ( Opcional )
			 0,;					            // 12-Valor do Frete Autonomo ( Opcional )
			 (cAlias)->C6_VALOR,;                    // 13-Valor da Mercadoria ( Obrigatorio )
			 0,;					            // 14-Valor da Embalagem ( Opiconal )
			 0,;		     		            // 15-RecNo do SB1
			 0) 					            // 16-RecNo do SF4

  (cAlias)->(dbSkip())
Enddo

dbSelectArea((cAlias))
(cAlias)->(dbGotop())

	
	oPrint:StartPage()
	oPrint:SetPaperSize(9)
    nLin := 090
	oPrint:SayBitmap(nLin,0200,cLogo,200,200)
	nLin := 150
	oPrint:Say(nLin,0400,'D & M CONFECวีES DE ROUPAS PARA CAES EIRELI - EPP',oFtA12n)
	oPrint:Say(nLin,1600,alltrim(SM0->M0_ENDENT)+" - "+alltrim(SM0->M0_BAIRCOB),oFtA08)
	nLin += 40
	oPrint:Say(nLin,0650,"CGC.: "+alltrim(TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99"))+"  -  "+"IE.: "+alltrim(SM0->M0_INSC),oFtA08n)
	oPrint:Say(nLin,1600,alltrim(SM0->M0_CIDCOB)+"/"+alltrim(SM0->M0_ESTCOB)+" - CEP "+SM0->M0_CEPCOB,oFtA08)
	nLin += 40
	oPrint:Say(nLin,1600,"TEL: "+alltrim(SM0->M0_TEL)+" - email: bichinhochic@bichinhochic.com.br",oFtA08)
	nLin += 60
	
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 5
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 15
	oPrint:Say(nLin,200,'Pedido de Venda '+MV_PAR01,oFtA22n)
	oPrint:Say(nLin,1900,DTOC(STOD((cAlias)->C5_EMISSAO)),oFtA22n)
	nLin += 90
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 5
	oPrint:Line (nLin,100,nLin,2300)
	
	nLin += 20
	oPrint:Say(nLin,200,'CLIENTE:',oFtA10n)
	oPrint:Say(nLin,450,alltrim((cAlias)->A1_NOME),oFtA10)
	oPrint:Say(nLin,1480,'CำD.:',oFtA10n)
	oPrint:Say(nLin,1730,alltrim((cAlias)->C6_CLI),oFtA10)
	nLin += 40
	oPrint:Say(nLin,200,'END.:',oFtA10n)
	oPrint:Say(nLin,450,alltrim((cAlias)->A1_END),oFtA10)
	oPrint:Say(nLin,1480,'BAIRRO:',oFtA10n)
	oPrint:Say(nLin,1730,alltrim((cAlias)->A1_BAIRRO),oFtA10)
	nLin += 40
	oPrint:Say(nLin,200,'CIDADE/UF:',oFtA10n)
	oPrint:Say(nLin,450,upper(alltrim((cAlias)->A1_MUN)+" / "+alltrim((cAlias)->A1_EST)),oFtA10)
	oPrint:Say(nLin,1480,'CEP:',oFtA10n)
	oPrint:Say(nLin,1730,alltrim((cAlias)->A1_CEP),oFtA10)
	nLin += 40
	oPrint:Say(nLin,200,'CNPJ/CPF:',oFtA10n)
	oPrint:Say(nLin,450,alltrim(Transform((cAlias)->A1_CGC,"@R 99.999.999/9999-99")),oFtA10)
	oPrint:Say(nLin,800,'TEL:',oFtA10n)
	oPrint:Say(nLin,920,alltrim((cAlias)->A1_DDD)+" - "+alltrim((cAlias)->A1_TEL),oFtA10)
	oPrint:Say(nLin,1480,'COND.PGTO.:',oFtA10n)
	oPrint:Say(nLin,1730,alltrim((cAlias)->E4_DESCRI),oFtA10)
	nLin += 40
	oPrint:Say(nLin,200,'INSC.EST.:',oFtA10n)
	oPrint:Say(nLin,450,alltrim(Transform((cAlias)->A1_INSCR,"@R 999.999.999.99")),oFtA10)
	
	//oPrint:Say(nLin,1480,'FRETE: ',oFtA10n)
	//oPrint:Say(nLin,1730,alltrim((cAlias)->FRETE),oFtA10)
	nLin += 40
	oPrint:Say(nLin,200,'EMAIL:',oFtA10n)
	oPrint:Say(nLin,450,(cAlias)->A1_EMAIL,oFtA10)
	//oPrint:Say(nLin,1480,'TRANSP.:',oFtA10n)
	//oPrint:Say(nLin,1730,alltrim((cAlias)->C5_TRANSP)+" - "+alltrim((cAlias)->A4_NREDUZ),oFtA10)
	
	nLin += 50
	oPrint:Line (nLin,100,nLin,2300)
	
	nLin += 20
	oPrint:Say(nLin,0200,'Cod.Prod',oFtA10n)
	oPrint:Say(nLin,0390,'Descri็ใo',oFtA10n) //oPrint:Say(nLin,0390,'Quant.',oFtA10n)
	oPrint:Say(nLin,1000,'Quant.',oFtA10n)   //oPrint:Say(nLin,0520,'Unid.',oFtA10n)
	oPrint:Say(nLin,1150,'Unid.',oFtA10n)    //oPrint:Say(nLin,0630,'Descri็ใo',oFtA10n)
	oPrint:Say(nLin,1300,'VrUnit R$',oFtA10n)
	oPrint:Say(nLin,1500,'Valor R$',oFtA10n)//oPrint:Say(nLin,1500,'Subtotal',oFtA10n)
	oPrint:Say(nLin,1700,'%ICMS',oFtA10n)
	oPrint:Say(nLin,1900,'%IPI',oFtA10n) //oPrint:Say(nLin,1900,'Valor',oFtA10n)
	nLin += 40
	
 Do While (cAlias)->(!EOF())
		
		nTItem++
		//VERIFICA SALTO DE PAGINA E IMPRIME CABECALHO
		If nLin > 3200
			Cabeca((cAlias)->C5_EMISSAO)
		EndIf
		
		oPrint:Say(nLin,0200,(cAlias)->C6_PRODUTO,oFtC09)
		oPrint:Say(nLin,0930,transform((cAlias)->C6_QTDVEN,PesqPict("SC6","C6_QTDVEN")),oFtC09)//oPrint:Say(nLin,0340,transform((cAlias)->C6_QTDVEN,PesqPict("SC6","C6_QTDVEN")),oFtC09)
		oPrint:Say(nLin,1170,(cAlias)->C6_UM,oFtC09)//oPrint:Say(nLin,0530,(cAlias)->C6_UM,oFtC09)
		oPrint:Say(nLin,1250,transform((cAlias)->C6_PRCVEN,PesqPict("SC6","C6_PRCVEN")),oFtC09)//oPrint:Say(nLin,1200,transform((cAlias)->C6_PRCVEN,PesqPict("SC6","C6_PRCVEN")),oFtC09)
		oPrint:Say(nLin,1440,transform((cAlias)->C6_VALOR,PesqPict("SC6","C6_VALOR")),oFtC09)//oPrint:Say(nLin,1400,transform((cAlias)->C6_PRCVEN*(cAlias)->C6_QTDVEN,PesqPict("SC6","C6_PRCVEN")),oFtC09)		
		oPrint:Say(nLin,1570,transform(MaFisRet(nTItem,"IT_VALICM"),PesqPict("SC6","C6_PRCVEN")),oFtC09)
		oPrint:Say(nLin,1750,transform(MaFisRet(nTItem,"NF_VALIPI"),PesqPict("SC6","C6_PRCVEN")),oFtC09)//oPrint:Say(nLin,1800,transform((cAlias)->C6_VALOR,PesqPict("SC6","C6_VALOR")),oFtC09)
		
		aDesc := aClone(QuebraStr((cAlias)->C6_DESCRI,30))
		For i:=1 to len(aDesc)
			oPrint:Say(nLin,0390,aDesc[i],oFtC09)
			nLin += 35
		Next i
		
		nLin += 15
				
		nTVPro += (cAlias)->C6_PRCVEN*(cAlias)->C6_QTDVEN
		nTVST  += MaFisRet(nTItem,"IT_VALICM")	
		nTVIpi += MaFisRet(nTItem,"IT_VALIPI")
				
	(cAlias)->(dbSkip())
		
	Enddo
	nLin += 10
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 20
	
	(cAlias)->(dbGoTop())
	
	//VERIFICA SALTO DE PAGINA E IMPRIME CABECALHO
	If nLin > 3200
		Cabeca((cAlias)->C5_EMISSAO)
	EndIf      
		
	//oPrint:Say(nLin,200,'VOLUMES:',oFtA10n)	
	//oPrint:Say(nLin,600,cValtoChar((cAlias)->C5_VOLUME1),oFtC09)
	oPrint:Say(nLin,1480,'VALOR PRODUTOS R$:',oFtA10n)
	oPrint:Say(nLin,1800,transform(nTVPro,PesqPict("SC6","C6_PRCVEN")),oFtC09)
	//nLin += 40
	//oPrint:Say(nLin,200,'ESPษCIE:',oFtA10n)
	//oPrint:Say(nLin,600,alltrim((cAlias)->C5_ESPECI1),oFtC09)
	//oPrint:Say(nLin,1480,'VALOR IPI',oFtA10n)
	//oPrint:Say(nLin,1800,transform(nTVIpi,PesqPict("SC6","C6_PRCVEN")),oFtC09)
	nLin += 40
	//oPrint:Say(nLin,200,'PESO LIQ.:',oFtA10n)
	//oPrint:Say(nLin,600,Alltrim(transform((cAlias)->C5_PESOL,PesqPict("SC5","C5_PESOL"))),oFtC09)
	oPrint:Say(nLin,1480,'ICMS:',oFtA10n)
	oPrint:Say(nLin,1800,transform(nTVST,PesqPict("SC6","C6_PRCVEN")),oFtC09)
	nLin += 40
	//oPrint:Say(nLin,200,'PESO BRUTO:',oFtA10n)
	//oPrint:Say(nLin,600,Alltrim(transform((cAlias)->C5_PBRUTO,PesqPict("SC5","C5_PBRUTO"))),oFtC09)
	oPrint:Say(nLin,1480,'TOTAL DESC. R$:',oFtA10n)
	oPrint:Say(nLin,1750,transform((cAlias)->C5_DESCONT,PesqPict("SC5","C5_DESCONT")),oFtC09)
	
	nLin += 40
	
	oPrint:Say(nLin,1480,'VALOR TOTAL R$:',oFtA10n)
	oPrint:Say(nLin,1800,transform(nTVPro+nTVIpi-(cAlias)->C5_DESCONT,PesqPict("SC6","C6_PRCVEN")),oFtC09)
	nLin += 50                                              
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 5
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 20
	
	//VERIFICA SALTO DE PAGINA E IMPRIME CABECALHO
	If nLin > 3200
		Cabeca((cAlias)->C5_EMISSAO)
	EndIf
	
	//oPrint:Say(nLin,200,'VENDEDOR:',oFtA10n)	 
	//oPrint:Say(nLin,600,alltrim(Posicione("SA3",1,xFilial("SA3")+(cAlias)->C5_VEND1,"A3_NREDUZ")),oFtA10)
	//oPrint:Say(nLin,1480,'REPRESENTANTE:',oFtA10n)
    //oPrint:Say(nLin,1800,alltrim(Posicione("SA3",1,xFilial("SA3")+(cAlias)->C5_VEND2,"A3_NREDUZ"))+" ("+alltrim(transform((cAlias)->C5_COMIS2,PesqPict("SC5","C5_COMIS2")))+"%)",oFtA10)
	//nLin += 40
	//oPrint:Say(nLin,200,'COMPRADOR:',oFtA10n)
	//oPrint:Say(nLin,600,alltrim((cAlias)->A1_CONTATO)+Iif(!Empty((cAlias)->A1_EMAIL)," ("+alltrim((cAlias)->A1_EMAIL)+")",""),oFtA10)
	//nLin += 40
	//oPrint:Say(nLin,200,'PED. CLIENTE:',oFtA10n)
	//oPrint:Say(nLin,600,alltrim((cAlias)->C5_COTACAO),oFtA10)
	nLin += 40
	oPrint:Say(nLin,200,'ENTREGA:',oFtA10n)
	oPrint:Say(nLin,600,DTOC(STOD((cAlias)->C5_FECENT)),oFtA10)  // Alterado por Leandro em 09/06/14 - campo anterior: C6_ENTREG
	nLin += 40
	
	//VERIFICA SALTO DE PAGINA E IMPRIME CABECALHO
	If nLin > 3200
		Cabeca((cAlias)->C5_EMISSAO)
	EndIf
	
	oPrint:Say(nLin,200,'OBSERVAวีES.:',oFtA10n)	
	If !Empty((cAlias)->C5_MENNOTA)
		aMsg := aClone(QuebraStr(upper((cAlias)->C5_MENNOTA),90))
		For i:=1 to len(aMsg)
			oPrint:Say(nLin,0600,aMsg[i],oFtA10)
			nLin += 40
		Next i
	Else
		nLin += 50
	Endif
	
	/*oPrint:Say(nLin,200,'OBSERVAวีES:',oFtA10n)
	If !Empty((cAlias)->C5_OBSERV)
		aObs := aClone(QuebraStr(upper((cAlias)->C5_OBSERV),90))
		For i:=1 to len(aObs)
			oPrint:Say(nLin,0600,aObs[i],oFtA10)
		   	nLin += 40
		Next i
		nLin += 10
		//VERIFICA SALTO DE PAGINA E IMPRIME CABECALHO
		
	Endif*/
	
	//nLin += 40	
	//oPrint:Say(nLin,200,'CAIXA       (  )4    (  )12       _______________________________________________________________',oFtA10n)
	//nLin += 150	
	//oPrint:Say(nLin,200,'DATA     /    /       Assinatura  _______________________________________________________________',oFtA10n)
	
	If nLin > 3200
		Cabeca((cAlias)->C5_EMISSAO)
	EndIf

	nLin += 150
	oPrint:Say(nLin,200,'  _____________________________                                                                     ______________________________',oFtA10n)
	nLin += 35	
	oPrint:Say(nLin,200,'                    Cliente                                                                                                                                 Empresa',oFtA10n)
	nLin += 60
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 5
	oPrint:Line (nLin,100,nLin,2300)
	nLin += 20
	oPrint:Say(nLin,2000,'Pแgina '+cValToChar(nPag),oFtA12n)
	
	
	oPrint:EndPage()
	
Else
	Msgbox("Nใo foi possํvel localizar o pedido "+MV_PAR01+".","Aten็ใo")
Endif

fErase(cAlias)

Return()


Static Function Cabeca(cDataEmiss)

nLin += 40
oPrint:Line (nLin,100,nLin,2300)
nLin += 5
oPrint:Line (nLin,100,nLin,2300)
nLin += 20
oPrint:Say(nLin,100,'Continua na pr๓xima pแgina...',oFtA11n)
oPrint:Say(nLin,2000,'Pแgina '+cValToChar(nPag),oFtA11n)
nPag++

oPrint:EndPage()
oPrint:StartPage()
oPrint:SetPaperSize(9)
nLin := 090
oPrint:SayBitmap(nLin,0200,cLogo,200,200)
nLin := 150
oPrint:Say(nLin,0400,'D & M CONFECวีES DE ROUPAS PARA CAES EIRELI - EPP',oFtA12n)
oPrint:Say(nLin,1600,alltrim(SM0->M0_ENDENT)+" - "+alltrim(SM0->M0_BAIRCOB),oFtA08)
nLin += 40
oPrint:Say(nLin,0650,"CGC.: "+alltrim(TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99"))+"  -  "+"IE.: "+alltrim(SM0->M0_INSC),oFtA08n)
oPrint:Say(nLin,1600,alltrim(SM0->M0_CIDCOB)+"/"+alltrim(SM0->M0_ESTCOB)+" - CEP "+SM0->M0_CEPCOB,oFtA08)
nLin += 40
oPrint:Say(nLin,1600,"TEL: "+alltrim(SM0->M0_TEL)+" - email: bichinhochic@bichinhochic.com.br",oFtA08)
nLin += 60

oPrint:Line (nLin,100,nLin,2300)
nLin += 5
oPrint:Line (nLin,100,nLin,2300)
nLin += 20
oPrint:Say(nLin,200,'Pedido de Venda '+MV_PAR01,oFtA22n)
oPrint:Say(nLin,1900,DTOC(STOD(cDataEmiss)),oFtA22n)
nLin += 90
oPrint:Line (nLin,100,nLin,2300)
nLin += 5
oPrint:Line (nLin,100,nLin,2300)

nLin += 20
oPrint:Say(nLin,0200,'Cod.Prod',oFtA10n)
oPrint:Say(nLin,0390,'Quant.',oFtA10n)
oPrint:Say(nLin,0520,'Unid.',oFtA10n)
oPrint:Say(nLin,0620,'Descri็ใo',oFtA10n)
oPrint:Say(nLin,1300,'VrUnit',oFtA10n)
oPrint:Say(nLin,1500,'Subtotal',oFtA10n)
oPrint:Say(nLin,1700,'VrIPI',oFtA10n)
oPrint:Say(nLin,1900,'VrST',oFtA10n)
oPrint:Say(nLin,2100,'Valor',oFtA10n)
nLin += 40


Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณQuebraStr บAutor  ณDPA                 บ Data ณ  30/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao resposavel por quebrar uma string considerando o     บฑฑ
ฑฑบ          ณespaco entre as palavras.                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function QuebraStr(cStr,nIni)

aStr := {}
//aAdd(aStr,chr(13)+chr(10))
cStr := Alltrim(cStr)
//nIni := 40 //INICIO DA LINHA
nFim := len(cStr) //FIM DA LINHA

//cStr := StrTran(cStr,".",". ")
//cStr := StrTran(cStr,",",", ")
cStr := StrTran(cStr,"  "," ")

If nFim > nIni
	Do While len(cStr) > 0
		nAt := At(" ",substr(cStr,nIni,len(cStr)))
		If at(chr(13)+chr(10),cStr) > 0 //SE ENCONTRAR ALGUM "ENTER"
			nAtEnter := at(chr(13)+chr(10),cStr)
		Else
			nAtEnter := 99999999999
		Endif
		
		If nAtEnter < nAt+nIni //enter antes da quebra de linha
			aAdd(aStr,alltrim(Substr(cStr,1,nAtEnter)))
			cStr := Substr(cStr,nAtEnter+2,len(cStr))
		Else
			aAdd(aStr,alltrim(Substr(cStr,1,nIni+nAt-1)))
			cStr := Substr(cStr,nIni+nAt,len(cStr))
		Endif
	Enddo
Else
	nAt := At(" ",substr(cStr,nIni,len(cStr)))
	nAtEnter := at(chr(13)+chr(10),cStr)
	aAdd(aStr,alltrim(Substr(cStr,1,nFim )))
Endif

Return(aStr)
