#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH" 
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"   

/*/{Protheus.doc} FATA001             
//	        Processo de desmembramento do pedido de venda de uma empresa a outra no relatório
            PEDIDO DE VENDA - PORTAL DE VENDAS
@author 	iVan de Oliveira - EthosX	
@since 		01/02/2021
@uso        Especifico TC
@version 	1.0
@param		_aCab ,  Array, Informações do cabeçalho do pedido de venda
@param		_aItens, Array, Informações dos  Itens pedido de venda para cálculo impostos + retorno HTML
@type       Function
/*/ 
User function FATA001(_aCab, _aItens)

Local _cRetHtml := ''
Local _nTamFil  := len( FWCodFil())
Local _cFilExec := left(alltrim(Upper(SuperGetMv("FS_TCEMPTR",,"040101"))),_nTamFil)

// Executa a inclusão na filial indicada parâmetro FS_TCEMPTR
_cRetHtml := StartJob("u_FATA002",GetEnvserver(),.T.,_aCab, _aItens, cEmpAnt, _cFilExec )
	
Return _cRetHtml


/*/{Protheus.doc} FATA002             
//	        Processo de desmembramento do pedido de venda de uma empresa a outra no relatório
            PEDIDO DE VENDA - PORTAL DE VENDAS
@author 	iVan de Oliveira - EthosX	
@since 		01/02/2021
@uso        Especifico TC
@version 	1.0
@param		_aCabPed , Array    , Informações do cabeçalho do pedido de venda
@param		_aItPed  , Array    , Informações dos  Itens pedido de venda para cálculo impostos + retorno HTML
@param		_cEmpExec, character, Empresa onde será executado.
@param		_cFilEx  , character, Filial onde será executado.
@type       Function
/*/ 

User Function FATA002(_aCabPed, _aItPed, _cEmpExec, _cFilEx )

Local _cTxtHtml  := ''
Local _nIt       := 0
Local _cCliente  := _aCabPed[01][01]
Local _cLjCli    := _aCabPed[01][02]
Local _cEmissao  := _aCabPed[01][12]
Local _cPrvEnt   := _aCabPed[01][13]  
Local _cNumPV    := _aCabPed[01][14]  
Local _cNomCli   := _aCabPed[01][15] 
Local _nOpc      := _aCabPed[01][16] 
Local _Cliente   := _aCabPed[01][17] 
Local  _nTotal   := 0
Local  _nTotIpi  := 0
Local  _nTotSt   := 0
Local _nTotPed   := 0 
// Preparando ambiente a ser realizado a transferência.
PREPARE ENVIRONMENT EMPRESA _cEmpExec FILIAL _cFilEx MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"

    // Nome Filial
    _cNomFil := Alltrim(FWFilialName(,_cFilEx))

    // Montando o HTML   
    _cTxtHtml := '<html>'
    _cTxtHtml += '<head>'	
    _cTxtHtml += '<style>body{ font-family: verdana;}</style>'
    _cTxtHtml += '</head>'	
    _cTxtHtml += '<body>'	
    _cTxtHtml += '<center>'
    _cTxtHtml += '<table border="1" cellpadding="5" cellspacing="0" style="font-size: 14px;">'			
    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td colspan="13"><center><strong>PEDIDO DE VENDA - (' + _cNomFil + ') PORTAL DE VENDAS</strong></strong></td>'
    _cTxtHtml += '</tr>'	

    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td><strong>Número</strong></td>'
    _cTxtHtml += '<td>'+ _cNumPV +'</td>'
    _cTxtHtml += '<td><strong>Cliente</strong></td>'
    _cTxtHtml += '<td colspan="10">'+ _cNomCli +'</td>'
    _cTxtHtml += '</tr>'
                    
    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td><strong>Emissão</strong></td>'
    _cTxtHtml += '<td>'+ _cEmissao +'</td>'
    _cTxtHtml += '<td><strong>Prev. Entrega</strong></td>'
    _cTxtHtml += '<td colspan="10">'+ _cPrvEnt +'</td>'
    _cTxtHtml += '</tr>'

    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td colspan="13"></td>'
    _cTxtHtml += '</tr>'

    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td colspan="13"><center><strong>Itens do Pedido</strong></center></td>'
    _cTxtHtml += '</tr>'				
    _cTxtHtml += '<tr style="text-align: center; font-weight: bold;">'
    _cTxtHtml += '<td>Código</td>'
    _cTxtHtml += '<td colspan="7">Descrição</td>'
    _cTxtHtml += '<td>Quantidade</td>'
    _cTxtHtml += '<td>Preço Tabela</td>'
    
    _cTxtHtml += '<td>IPI</td>'
    _cTxtHtml += '<td>ICMS</td>'
    _cTxtHtml += '<td>Total</td>'
    _cTxtHtml += '</tr>'

    // Inicia função fiscal
    MaFisIni(   _aCabPed[01][01],;    // 01 - Codigo Cliente/Fornecedor
                _aCabPed[01][02],;    // 02 - Loja do Cliente/Fornecedor
                _aCabPed[01][03],;    // 03 - C:Cliente , F:Fornecedor
                _aCabPed[01][04],;    // 04 - Tipo da NF
                _aCabPed[01][05],;    // 05 - Tipo do Cliente/Fornecedor
                _aCabPed[01][06],;    // 06 - Relacao de Impostos que suportados no arquivo
                _aCabPed[01][07],;    // 07 - Tipo de complemento
                _aCabPed[01][08],;    // 08 - Permite Incluir Impostos no Rodape .T./.F.
                _aCabPed[01][09],;    // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                _aCabPed[01][10])     // 10 - Nome da rotina que esta utilizando a funcao
    
    // Adicionando Itens na Função cálculo de impostos.  
    for _nIt := 1 to len(_aItPed)

    	_cProd   := _aItPed[_nIt][01]
        _cTpOper := SuperGetMV("MV_LJLPTIV",,"01")	
		_cTesInt := MaTESInt( 2, _cTpOper, _cCliente, _cLjCli,"C", _cProd)

        MaFisAdd( _aItPed[_nIt][01],;    // 01 - Codigo do Produto                    ( Obrigatorio )
                  _cTesInt,;             // 02 - Codigo do TES                        ( Opcional )
                  _aItPed[_nIt][03],;    // 03 - Quantidade                           ( Obrigatorio )
                  _aItPed[_nIt][04],;    // 04 - Preco Unitario                       ( Obrigatorio )
                  _aItPed[_nIt][05],;    // 05 - Desconto
	              _aItPed[_nIt][06],;    // 06 - Numero da NF Original                ( Devolucao/Benef )
	              _aItPed[_nIt][07],;    // 07 - Serie da NF Original                 ( Devolucao/Benef )
                  _aItPed[_nIt][08],;    // 08 - RecNo da NF Original no arq SD1/SD2
                  _aItPed[_nIt][09],;    // 09 - Valor do Frete do Item               ( Opcional )
                  _aItPed[_nIt][10],;    // 10 - Valor da Despesa do item             ( Opcional )
                  _aItPed[_nIt][11],;    // 11 - Valor do Seguro do item              ( Opcional )
                  _aItPed[_nIt][12],;    // 12 - Valor do Frete Autonomo              ( Opcional )
                  _aItPed[_nIt][13],;    // 13 - Valor da Mercadoria                  ( Obrigatorio )
                  _aItPed[_nIt][14],;    // 14 - Valor da Embalagem                   ( Opcional )
                  _aItPed[_nIt][15],;    // 15 - RecNo do SB1
                  _aItPed[_nIt][16])     // 16 - RecNo do SF4

        //Pegando totais por item
        _nValIpi := MaFisRet(_nIt, "IT_VALIPI")
        _nValSol := MaFisRet(_nIt, "IT_VALSOL")
        //_nValIcm := MaFisRet(_nIt, "IT_VALICM")
        _nSubTot := _aItPed[_nIt][03] * _aItPed[_nIt][04]

        // Totais Rodapé
        _nTotal  += _nSubTot
        _nTotIpi += _nValIpi
        _nTotSt  += _nValSol

        // Carrega HTML dos Itens
        _cTxtHtml += '<tr>'
        _cTxtHtml += '<td>'+ _aItPed[_nIt][01] +'</td>'
        _cTxtHtml += '<td colspan="7">'+ Alltrim(_aItPed[_nIt][17]) +'</td>'
        _cTxtHtml += '<td style="text-align: center;"> '  + cValToChar(_aItPed[_nIt][03]) + '</td>'
        _cTxtHtml += '<td style="text-align: right;">R$ ' + Transform( _aItPed[_nIt][04],"@E 999,999,999.99") + '</td>'
        _cTxtHtml += '<td style="text-align: right;">R$ ' + Transform( _nValIpi,"@E 999,999,999.99") + ' </td>'
        _cTxtHtml += '<td style="text-align: right;">R$ ' + Transform( _nValSol,"@E 999,999,999.99") + ' </td>'
        _cTxtHtml += '<td style="text-align: right;">R$ ' + Transform( _nSubTot,"@E 999,999,999.99") + ' </td>'
        _cTxtHtml += '</tr>'

    Next    

    MaFisEnd()   

    _nTotPed := _nTotal + _nTotIpi + _nTotSt

    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td colspan="10"><strong>Total</strong></td>'
    _cTxtHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(_nTotIpi,"@E 999,999,999.99") + '</strong></td>'
    _cTxtHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(_nTotSt ,"@E 999,999,999.99") + '</strong></td>'
    _cTxtHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(_nTotal ,"@E 999,999,999.99") + '</strong></td>'
    _cTxtHtml += '</tr>'
    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td colspan="12"><strong>Total Pedido</strong></td>'
    _cTxtHtml += '<td style="text-align: right;"><strong>R$ ' + Transform(_nTotPed ,"@E 999,999,999.99") + '</strong></td>'
    _cTxtHtml += '</tr>'			
    _cTxtHtml += '<tr>'
    _cTxtHtml += '<td colspan="13" style="font-size: 12px;"><center><em>Pedido emitido pelo portal de vendas - ' + dtoc(date()) + ' - ' + TIME() + '<em></center></td>'
    _cTxtHtml += '</tr>'
    _cTxtHtml += '</table>'
    _cTxtHtml += '</center>'
    _cTxtHtml += '</body>'
    _cTxtHtml += '</html>'

    _cTxtHtml += '<html>'
    _cTxtHtml += '<body>'

    if  !Empty(_Cliente)

        DbSelectArea('SA1')
        SA1->(DbSetOrder(1))
        SA1->(DbSeek(xFilial()+_Cliente))

        If _nOpc == 3

            _cTxtHtml += '<h2> Novo Cliente cadastrado: '+AllTrim(_cNomCli)+' </h2>'

        ElseIf _nOpc == 4

            _cTxtHtml += '<h2> Cliente: '+AllTrim(_cNomCli)+' alterado. </h2>'
            
        EndIf

    Endif

    _cTxtHtml += '</body>'
    _cTxtHtml += '</html>'

    
RESET ENVIRONMENT

Return _cTxtHtml

