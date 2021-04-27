#include "protheus.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "topconn.ch"   

/*/{Protheus.doc} FATA003           
//	        Processo para Bloqueio Clientes 
@author 	iVan de Oliveira - EthosX	
@since 		18/02/2021
@uso        Especifico TC
@version 	1.0
@param		Nulo, Nulo, Nulo
@param		Nulo, Nulo, Nulo
@type       Function
/*/ 
User function FATA003()

Local _lSchedule := !(Type("oMainWnd")=="O") 
Local _aParamF   := {}

 // Se for processo Scheduller
if _lSchedule

    _cEmpresa  := '01'
    _cFilial   := '010101'

    // Preparando ambiente
    PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial MODULO "FAT"

Endif

// Criando os Parâmetros
Aadd(_aParamF, {'FS_TCPRZBL' , 'N', 'Prazo em dias para '   , 'Bloqueio Clientes. '	  , ' ', '0' })
Aadd(_aParamF, {'FS_TCEMCLB' , 'C', 'E-Mail para Envio dos ', 'Clientes bloqueados pela rotina. ', '  ',  ' '})

if CriaPar(_aParamF)

    _nPrzBlq := SuperGetMv("FS_TCPRZBL",,0)
    _cMailNT := SuperGetMv("FS_TCEMCLB",,"")
    _aNotif  := {}

    // Se zerado, desligar a rotina.
    if _nPrzBlq > 0

        _cDtM60  := dtos(dDataBase - _nPrzBlq)

        // Carrega clientes para possivel bloqueio
        _cAlias := GetNextAlias() 
        BeginSql Alias _cAlias 

            SELECT 
                A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_DTCAD, A1_DATALIB, A.R_E_C_N_O_ REGISTRO
            FROM
                %Table:SA1% A  
            WHERE
                A1_FILIAL 	     = %xFilial:SA1%  
                AND ( A1_MSBLQL  = '2' OR A1_MSBLQL  = ' '  )
                AND A1_ULTCOM <= %exp:_cDtM60%  
                AND A.%notDel% 

        Endsql

        //GetLastQuery()[02] --> Últ Query
        TcSetField( (_cAlias), "A1_DTCAD" , "D" , 10,0 )
        TcSetField( (_cAlias), "A1_DATALIB", "D" , 10,0 )

        (_cAlias)->( DbGotop() )
        While !(_cAlias)->( Eof() )

            if  ( dtos((_cAlias)->A1_DTCAD)   <= _cDtM60 .and. dtos((_cAlias)->A1_DATALIB) = ' ' ).or.;
                ( dtos((_cAlias)->A1_DATALIB) <> ' '     .and. dtos((_cAlias)->A1_DATALIB)  <= _cDtM60 )
            

                // Itens a gerar e-mail notificação.
                aadd(_aNotif, { (_cAlias)->A1_COD, (_cAlias)->A1_LOJA, (_cAlias)->A1_NOME,;
                                Transform( (_cAlias)->A1_CGC, "@R 99.999.999/9999-99" ),;
                                Dtoc(date()) + '-' + Time() })

                // Bloqueio do registro
                SA1->(DbGoto((_cAlias)->REGISTRO)) 
                SA1->( RecLock( "SA1" , .F. ) ) 

                    SA1->A1_MSBLQL := '1'

                MsUnlock()

            Endif

            (_cAlias)->(DbSkip()) 

        Enddo

        (_cAlias)->(DbCloseArea()) 

        // Enviar Notificação caso parametrizado.
        if !empty(_cMailNT) .and. IsEmail(_cMailNT) .and. !Empty(_aNotif)

            _EnvNotif(_aNotif,_cMailNT)

        Endif

    Endif

Endif

// Se for processo Scheduller
if _lSchedule

    Reset ENVIRONMENT

else 

    if len(_aNotif) > 0

        MsgInfo ('Foram bloqueados: ' + cValToChar(len(_aNotif)) + ' clientes com sucesso.', 'Atenção')
        
    else

        MsgAlert('Nenhum cliente foi encontrado para bloqueio.', 'Atenção')
        
    Endif
    

Endif

Return

/*{Protheus.doc} CRIAPAR
			Cria Parâmetro
@author 	iVan de Oliveira - EthosX
@since 		18/02/2020
@version 	P12
@param  	_aParam	, Array    , {Código Parâmetro, tipo, Descrição, Descrição 1, Descrição 2, Conteúdo }
@param  	_cMailNT, Caractere, Endereço e-mail notificação
@return 	_lRet, Lógico, Retorno da Função --> Sucesso .T. / Falha .f.
*/
Static Function CRIAPAR(_aParam, _cMailNT )

Local _nIt := 0   
Local _lRet:= .T.
  
DeFault _aParam := {}

// Incluindo os Parâmetros.
DbSelectArea("SX6")
DbSetOrder(1)
SX6->(DbGoTop())  
for _nIt := 1 to len(_aParam)

	If !(SX6->(DbSeek( FwXFilial("SX6") + _aParam[_nIt][01] )))
            
		RecLock("SX6",.T.)
             
  			SX6->X6_FIL  	:=  FwXFilial("SX6") 
	    	SX6->X6_VAR     := _aParam[_nIt][01]
			SX6->X6_TIPO 	:= _aParam[_nIt][02]
			SX6->X6_PROPRI  :=  "U"
		
			//Descrição
			SX6->X6_DESCRIC :=  _aParam[_nIt][03]
			SX6->X6_DESC1   :=  _aParam[_nIt][04]
			SX6->X6_DESC2   :=  _aParam[_nIt][05]
			
			//Conteúdo
			SX6->X6_CONTEUD :=  _aParam[_nIt][06]
			SX6->X6_CONTSPA :=  _aParam[_nIt][06]
			SX6->X6_CONTENG :=  _aParam[_nIt][06]
			
   		SX6->(MsUnlock())
   		
   	Endif
   	
Next 

Return _lRet  

/*{Protheus.doc} _EnvNotif
			Cria Parâmetro
@author 	iVan de Oliveira - EthosX
@since 		18/02/2020
@version 	P12
@param  	_aItens	, Array, {Código Cliente, Loja, Nome, CNPJ }
@return 	_lRet, Lógico, Retorno da Função --> Sucesso .T. / Falha .f.
*/
Static Function _EnvNotif(_aItens, _cMailTo)

Local _cTxtHtm := ''
Local _lRet    := .T.
Local _nIt     := 0
 
// Corpo E-mail
_cTxtHtm := '<table style="width: 143.1%; border-collapse: collapse; background-color: #696969; height: 23px;" border="1">'
_cTxtHtm += '<tbody>'
_cTxtHtm += '<tr>'
_cTxtHtm += '<td style="width: 100%; text-align: center;">ENVIO NOTIFICA&Ccedil;&Atilde;O BLOQUEIO DE CLIENTES</td>'
_cTxtHtm += '</tr>'
_cTxtHtm += '</tbody>'
_cTxtHtm += '</table>'
_cTxtHtm += '<table style="height: 24px; width: 142.886%; border-collapse: collapse; background-color: #add8e6;" border="1">'
_cTxtHtm += '<tbody>'
_cTxtHtm += '<tr style="height: 18px;">'
_cTxtHtm += '<td style="width: 12.0761%; height: 18px;">C<strong>&oacute;digo</strong></td>'
_cTxtHtm += '<td style="width: 9.3819%; height: 18px;"><strong>Loja</strong></td>'
_cTxtHtm += '<td style="width: 39.5246%; height: 18px;"><strong>Nome</strong></td>'
_cTxtHtm += '<td style="width: 22.7189%; height: 18px;"><strong>CNPJ</strong></td>'
_cTxtHtm += '<td style="width: 16.895%; text-align: center; height: 18px;"><strong>Dt.Bloqueio</strong></td>'
_cTxtHtm += '</tr>'
_cTxtHtm += '</tbody>'
_cTxtHtm += '</table>'
_cTxtHtm += '<table style="border-collapse: collapse; width: 143.081%; height: 22px;" border="1">'
_cTxtHtm += '<tbody>'

for _nIt := 1  to len(_aItens)

    // Inserir Dados Cliente
    _cTxtHtm += '<tr>'
    _cTxtHtm += '<td style="width: 12.1618%;">' + _aItens[_nIt][01] + '</td>'
    _cTxtHtm += '<td style="width: 9.31546%;">' + _aItens[_nIt][02] + '</td>'
    _cTxtHtm += '<td style="width: 39.4901%;">' + _aItens[_nIt][03] + '</td>'
    _cTxtHtm += '<td style="width: 22.5829%;">' + _aItens[_nIt][04] + '</td>'
    _cTxtHtm += '<td style="width: 16.5883%;">' + _aItens[_nIt][05] + '</td>'
    _cTxtHtm += '</tr>'
    // Final Dados Cliente
Next

_cTxtHtm += '</tbody>'
_cTxtHtm += '</table>'
_cTxtHtm += '<p>&nbsp;</p>'

// Rotina de Envio.
FINXRESEMa(_cTxtHtm, "","","", _cMailTo, "Rotina Automatizada Bloqueio Clientes") 


Return _lRet
