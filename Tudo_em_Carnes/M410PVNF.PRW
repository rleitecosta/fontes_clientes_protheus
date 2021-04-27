#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} M410PVNF             
//			Este P.E. serve para validação. Executado antes da rotina de geração de NF's (MA410PVNFS())
@author 	iVan de Oliveira - EthosX
@since 		12/11/2020
@version 	1.0
@param  	Nil	, Nil, Nil
@return 	_lRet, Lógico, Retorno da Função --> Sucesso .T. / Falha .f.
@type 		User Function
/*/
User Function M410PVNF()

Local _aAreaAnt := { GetArea(),SC5->(GetArea()),SC6->(GetArea()) }
Local _lRet     := .T.
Local _aInfo    := {}

// Verificando se o Pedido tem itens a transferir de Empresa.
Processa( {|| _lRet := u_FATA010(SC5->C5_NUM, 'L', @_aInfo) }, "Aguarde...", "Verificando Transferência de Pedidos...",.F.)

if !Empty(_aInfo)

    if MsgYesNo ("Foi gerado LOG do Processamento de Transferência, deseja visulizar? ")

        // Monstra log
         _CriaLOG(_aInfo)

    Endif

Endif

// Retorna aos ambientes
aEval(_aAreaAnt, {|x| RestArea(x) })

Return _lRet


/*/{Protheus.doc} _CriaLOG             
//			Criar o arquivo de LOG e exibi-lo
@author 	iVan de Oliveira - EthosX
@since 		12/11/2020
@version 	1.0
@param  	_aInfo, Array, Array com Informação do LOG
@return 	Nil, Nil, Nil
@type 		User Function
/*/
Static Function _CriaLOG(_aInfo)

Local cDir  := GetTempPath()
Local cArq  := Dtos(date())+StrTran(Time(),':','') + ".log""
Local _nIt  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nHandle := FCreate(cDir+cArq)
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Ocorreu um erro na criação do arquivo de LOG. Informe ao Suporte esta ocorrência.", "Atenção")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cCab1	:= Repl('*',250 )   
    _cCab2	:= 'Filial Destino' +  space(10) + 'Nº. Pedido Original' +  space(10) + 'Nº. Pedido Gerado' +  space(20) + 'Ocorrência' 
    _cCab3	:= Repl('*',250 )  

    _cErros := _cCab1 + Chr(13) + chr(10) + _cCab2 + Chr(13) + chr(10) + _cCab3 + Chr(13) + chr(10)

    // Cabeçalho
    FWrite(nHandle, _cErros + CRLF)

    // Itens do LOG
    For _nIt := 1 to len(_aInfo)  
        
        FWrite(nHandle, Padr(Alltrim(_aInfo[_nIt][01]),24) + Padr(Alltrim( _aInfo[_nIt][02]),28) + Padr(Alltrim( _aInfo[_nIt][03]),37) + _aInfo[_nIt][04] + CRLF )
        
    Next 

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abre o arquivo para visualização.                                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    ShellExecute( "Open", "C:\Windows\System32\notepad.exe", cArq, cDir, 1 )

EndIf

Return
