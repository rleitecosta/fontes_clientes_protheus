//Bibliotecas
#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch" 
#include "topconn.ch" 
#include "fileio.ch"
#include "rptdef.ch"
#include "fwprintsetup.ch"
#include "tbiconn.ch"
#include "ap5mail.ch" 

/*/{Protheus.doc} FATM001
// 				Rotina para alteração de LIMITE DE CREDITO(A1_LC) no Cadastro de Clientes (MATA030).
@author 		iVan de Oliveira
@since 			04/09/2020
@version 		1.0
@type 			User Function
@example		u_FATM001()
@param  		Null, Null, Null
@obs 			Exclusivo Plastireal
 /*/
User Function FATM001(_aParSch)

Local _cMensErr  := ''
Local _bError 	 := ErrorBlock( {|x| Notifalha(x, @_cMensErr ) } ) // CodeBlock de Erro 
Local _lSetAmb   := .T.
Local _aParam    := {}

Private _lSche   := !(Type("oMainWnd")=="O") 
Private _aErrExec:= {}
Private _aAcLimCr:= {}

Default _aParSch := {'', '','','01','0101','',''}//Array(07)

// Inicio controle de falhas
Begin Sequence 

    // Processo via Schedule
    if _lSche 

        _cEmp := _aParSch[04]
        _cFil := _aParSch[05]

        // Prepara ambiente  
        RpcSetType(3)
        _lSetAmb := RPCSetEnv(_cEmp , _cFil,,,"FAT","FATM001",,,,,)

    Endif

    // ambiente setado.
    if _lSetAmb

        // Criando parâmetros necessários à rotina.
        Aadd(_aParam, {'FS_ATCRERR', 'C', 'E-mail para Notificação' , 'de falha na atualização '	, 'Clientes-Limite Crédito'	, ' ' })
		Aadd(_aParam, {'FS_ATCRALT', 'C', 'E-mail para Notificação' , 'de sucesso na importação de ', 'Clientes-Limite Crédito'	, ' ' })
			
        // Se criou os parâmetros
		if CriaPar(_aParam) 

            // Parâmetros para rotina
            //_cBlqCred := ''
            //_nValAv   := 1.00
            _cTipos := MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM

            //Unifico os separadores 
            _cTipos	:=	StrTran(_cTipos,',','/')
            _cTipos	:=	StrTran(_cTipos,';','/')
            _cTipos	:=	StrTran(_cTipos,'|','/')
            _cTipos	:=	StrTran(_cTipos,'\','/')

            // Condição para títulos provisórios
            _cCondWhere:= '%SE1.E1_TIPO NOT IN ' + FormatIn(_cTipos,'/') + '%'

            // Seleciona os clientes
            //AND A1_COD    = '009881'
            //AND A1_LOJA   = '01'
            
            _cTmpCli := GetNextAlias() 
            BeginSql Alias _cTmpCli    

                %noParser%
                SELECT  A1_FILIAL, R_E_C_N_O_ REGIS, A1_COD, A1_LOJA, RTRIM(UPPER(A1_NOME)) RAZAO
                FROM %table:SA1% A   
                WHERE   A1_FILIAL      = %xfilial:SA1%
                        AND A1_MSBLQL <> '1' 
                        AND A.%notdel%	

            Endsql

            (_cTmpCli)->( DbGotop() ) 
            While !(_cTmpCli)->( Eof() )	

                // Verifica se esta adimplente
                //_lCredito := MaAvalCred( (_cTmpCli)->A1_COD, (_cTmpCli)->A1_LOJA,_nValAv,1,.T.,@_cBlqCred)
                _cCodCli := (_cTmpCli)->A1_COD
                _cLojCli := (_cTmpCli)->A1_LOJA
                _cRazao  := (_cTmpCli)->RAZAO
                _nRegSA1 := (_cTmpCli)->REGIS

                _cAliasSE1 := GetNextAlias()
                BeginSql Alias _cAliasSE1

                    %noParser%
                    SELECT 
                            COUNT(1) QTDATR
                    FROM 
                            %Table:SE1% SE1
                    WHERE 
                            SE1.E1_FILIAL       = %xFilial:SE1%
                            AND SE1.E1_CLIENTE  = %Exp:_cCodCli%
                            AND SE1.E1_LOJA     = %Exp:_cLojCli%
                            AND SE1.E1_VENCREA  < %Exp:DtoS(dDataBase)%
                            AND SE1.E1_STATUS   = 'A'
                            AND %Exp:_cCondWhere% 
                            AND SE1.%NotDel%
                EndSql

                (_cAliasSE1)->(DbGoTop())

                if  !(_cAliasSE1)->(Eof())

                    _lCredito := (_cAliasSE1)->QTDATR == 0

                Endif

                 //Fecha temporária.
                (_cAliasSE1)->(DbCloseArea())

                if  _lCredito

                    // Calcula a média 06 meses
                    /*
                    _cQuery :=  " SELECT "
                    _cQuery +=          "SE5.E5_FILIAL, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPODOC, SE5.E5_NATUREZ, SE5.E5_RECPAG, SE5.E5_DTDIGIT," 
                    _cQuery +=          "SE5.E5_DATA, SE5.E5_MOTBX, SE5.E5_BANCO, SE5.E5_HISTOR, SE5.E5_VALOR, SE5.E5_VLMOED2, SE5.E5_PRETPIS, SE5.E5_PRETCOF, SE5.E5_PRETCSL, SE5.E5_VRETPIS, SE5.E5_VRETCOF " 
                    _cQuery += " FROM " + RetSqlName("SE5") + " SE5 " 

                    _cQuery += " WHERE "
                    _cQuery +=          " E5_FILIAL <> ' ' "
                    _cQuery +=          " AND SE5.E5_NUMERO != '" +space(6)+"'"
                    _cQuery +=          " AND SE5.E5_SITUACA != 'C'"
                    _cQuery +=          " AND SE5.E5_SITUACA != 'X'"
                    _cQuery +=          " AND NOT ( SE5.E5_TIPODOC = 'BA' AND SE5.E5_MOTBX = 'DSD' ) "
                    _cQuery +=          " AND SE5.E5_CLIFOR = '" + _cCodCli + "' "
                    _cQuery +=          " AND SE5.E5_LOJA   = '" + _cLojCli + "' "
                    _cQuery +=          " AND SE5.E5_TIPO NOT IN " + FormatIn( MVPROVIS, "/" )
                    _cQuery +=          " AND SE5.E5_TIPODOC IN ('VL','VM','BA','CP','LJ','V2','ES')" 
                    _cQuery +=          " AND ((SE5.E5_RECPAG = 'R' AND SE5.E5_TIPODOC <> 'ES')"
	                _cQuery +=          " OR (SE5.E5_TIPODOC = 'ES' AND SE5.E5_RECPAG = 'P')"
	                _cQuery +=          " OR (SE5.E5_TIPO IN ('"+MV_CRNEG+"','"+MVRECANT+"')))"
                    
                    // Baixa de adiantamentos
	                _cQuery +=          " AND NOT "
	                _cQuery +=          "( SE5.E5_RECPAG = 'R' AND SE5.E5_TIPO IN " + FormatIn( MV_CPNEG + "|" + MVPAGANT, "|" )
	                _cQuery +=          " AND SE5.E5_TIPODOC IN " + FormatIn( "VL/BA/DC/D2/MT/JR/J2/M2/CM/C2/CX", "/" ) + " ) "
                    _cQuery +=          " AND SE5.D_E_L_E_T_ = ' ' "

                    DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), 'TRBSE5', .F., .T.)
                    dbSelectArea( "TRBSE5" )
                    */
                    // Cálculo do período 06 meses
                    _dDtUltPer := Lastday(DDATABASE - 30)
                    _dDt06Mese := FirstDate(_dDtUltPer - 180)

                    _cAliasSE1 := GetNextAlias()
                    BeginSql Alias _cAliasSE1

                        %noParser%
                        SELECT 
                                SUM(E1_VALOR) VLRFAT
                        FROM 
                                %Table:SE1% SE1
                        WHERE 
                                SE1.E1_FILIAL       = %xFilial:SE1%
                                AND SE1.E1_CLIENTE  = %Exp:_cCodCli%
                                AND SE1.E1_LOJA     = %Exp:_cLojCli%
                                AND SE1.E1_VENCREA  BETWEEN %Exp:DtoS(_dDt06Mese)% and %Exp:DtoS(_dDtUltPer)%
                                AND SE1.E1_STATUS   <>'A'
                                AND %Exp:_cCondWhere% 
                                AND SE1.%NotDel%
                    EndSql

                    (_cAliasSE1)->(DbGoTop())
                    if  !(_cAliasSE1)->(Eof())

                        // Somente valores superiores a 0
                        if (_cAliasSE1)->VLRFAT>0

                            // Regra: cliente adimplente aplicar como limite a média de compras dos últimos 6 meses acrescida de 50%
                            _nVlrMed := Round(((_cAliasSE1)->VLRFAT / 6),2)
                            _nVlrAcr := Round(((_nVlrMed * 50) / 100),2)

                            // Atualiza cadastro clientes.
                            dbSelectArea("SA1")
                            dbGoto(_nRegSA1)
                            _nLimAnt := SA1->A1_LC

                            RecLock("SA1", .F.)

                                SA1->A1_LC := _nVlrMed + _nVlrAcr

                            //Confirma e finaliza a operação
                             MsUnLock() 
                            
                            // Marcado como concluído para envio de notificação
                            AAdd(_aAcLimCr, { Alltrim(_cCodCli) + '-' + _cLojCli ,;
                                             _cRazao,;
                                              Transform((_cAliasSE1)->VLRFAT, "@E 9,999,999.99") ,;
                                              Transform(_nLimAnt, "@E 9,999,999.99"),;
                                              Transform(_nVlrMed + _nVlrAcr, "@E 9,999,999.99") } )
                            
                        Endif

                     Endif

                    //Fecha temporária.
                    (_cAliasSE1)->(DbCloseArea())
       
                Endif

                // Próximo cliente.
                (_cTmpCli)->(DBSkip())
	             
            Enddo

            //Fecha temporária.
            (_cTmpCli)->(DbCloseArea())

        elseIf !_lSche

            MsgStop( "Ocorreu um erro na criação parâmetros:FS_ATCRERR|FS_ATCRALT. Informe ao suporte esta ocorrência e tente novamente !" ,'Atenção' )
            
        Endif

    Endif

//final do bloco.
End Sequence

 // Restaura rotina de erro anterior
ErrorBlock( _bError ) 
  
// Envio de Nofiticação por Falha de processo.
if !Empty(_cMensErr) .or. !empty( _aErrExec)  .or. !empty( _aAcLimCr) 

	if !Empty(_cMensErr) 

		AAdd(_aErrExec, { Funname(), _cMensErr, DToC(date()) + '-' + Time() } )
		Aviso( "Notificação de falha no processo: " + Funname(), _cMensErr, {}, 3)
		
	Endif
	
	// Envios de Notificações de falha
	_EnviNotif()
			
Endif

// Encerra o Schedule 
if _lSche
    
    RPCClearEnv() 
    
        
Endif


Return

/*{Protheus.doc} _EnviNotif
			Envio de Notificações
@author 	iVan de Oliveira
@since 		07/09/2020
@version 	P12
@param  	_aParam	, Array, {Código Parâmetro, tipo, Descrição, Descrição 1, Descrição 2, Conteúdo }
@return 	_lRet, Lógico, Retorno da Função --> Sucesso .T. / Falha .f.
*/
Static Function _EnviNotif

Local _nIt := 0

// Leiaute dos Erros técnicos.	
If !empty(_aErrExec)

	_cAssunto  := 'Notificação de Falha de Processo Automatizado: ' + Funname()
	_cTo	   := GetMv("FS_ATCRERR")

    _cMensagem := '<p><img src="https://www.plastireal.com.br/imagens/logo.png" alt="" width="102" height="52" /></p>'
    _cMensagem += '<table style="height: 28px; background-color: #c0c0c0; width: 800px;">'
    _cMensagem += '<tbody>'
    _cMensagem += '<tr>'
    _cMensagem += '<td style="text-align: center; width: 800px;">Falha Atualiza&ccedil;&atilde;o Limite Cr&eacute;dito para Cliente Adimplente</td>'
    _cMensagem += '</tr>'
    _cMensagem += '</tbody>'
    _cMensagem += '</table>'
    _cMensagem += '<table style="height: 34px; width: 800px;">'
    _cMensagem += '<tbody>'
    _cMensagem += '<tr>'
    _cMensagem += '<td style="width: 159px;">Nome do processo</td>'
    _cMensagem += '<td style="width: 500px;">Descri&ccedil;&atilde;o do erro</td>'
    _cMensagem += '<td style="width: 150px;">Data Ocorr&ecirc;ncia</td>'
    _cMensagem += '</tr>'
    _cMensagem += '<tr>'

    // Enviando itens do erro.
    for _nIt := 1 to len(_aErrExec)

        // Itens do Corpo
        _cMensagem += '<td style="width: 159px;">' + _aErrExec[_nIt][01] + '</td>'
        _cMensagem += '<td style="width: 500px;">' + _aErrExec[_nIt][02] + '</td>'
        _cMensagem += '<td style="width: 150px;">' + _aErrExec[_nIt][03] + '</td>'
        // Final Itens do Corpo

    Next

    _cMensagem += '</tr>'
    _cMensagem += '</tbody>'
    _cMensagem += '</table>'

Endif

If !empty(_aAcLimCr)

    _cAssunto := 'Cliente(s) adimplente com atualização do Limite Crédito'
    _cTo	  := GetMv("FS_ATCRALT")

    _cMensagem := '<p><img src="https://www.plastireal.com.br/imagens/logo.png" alt="" width="102" height="52" /></p>'
    _cMensagem += '<table style="height: 28px; background-color: #c0c0c0; width: 1000px;">'
    _cMensagem += '<tbody>'
    _cMensagem += '<tr>'
    _cMensagem += '<td style="text-align: center; width: 1000px;">Atualiza&ccedil;&atilde;o Limite Cr&eacute;dito para Cliente Adimplente</td>'
    _cMensagem += '</tr>'
    _cMensagem += '</tbody>'
    _cMensagem += '</table>'
    _cMensagem += '<table style="height: 34px; width: 1000px;">'
    _cMensagem += '<tbody>'
    _cMensagem += '<tr>'
    _cMensagem += '<td style="width: 80px;">C&oacute;digo</td>'
    _cMensagem += '<td style="width: 150px;">Raz&atilde;o social</td>'
    _cMensagem += '<td style="width: 100px;text-align: right;">Faturamento Per&iacute;odo</td>'
    _cMensagem += '<td style="width: 100px;text-align: right;">Limite Anterior</td>'
    _cMensagem += '<td style="width: 100px;text-align: right;">Limite Atual</td>'
    _cMensagem += '</tr>'
    _cMensagem += '<tr>'

        // Enviando itens corrigidos.
    for _nIt := 1 to len(_aAcLimCr)
    
        // Itens do Corpo
        _cMensagem += '<td style="width:  80px;text-align:  left;">'  + _aAcLimCr[_nIt][01] + '</td>'
        _cMensagem += '<td style="width: 150px;text-align:  left;">'  + _aAcLimCr[_nIt][02] + '</td>'
        _cMensagem += '<td style="width: 100px;text-align: right;">'  + _aAcLimCr[_nIt][03] + '</td>'
        _cMensagem += '<td style="width: 100px;text-align: right;">'  + _aAcLimCr[_nIt][04] + '</td>'
        _cMensagem += '<td style="width: 100px;text-align: right;">'  + _aAcLimCr[_nIt][05] + '</td>'
        // Final Itens do Corpo

    Next

    _cMensagem += '</tr>'
    _cMensagem += '</tbody>'
    _cMensagem += '</table>'

Endif

// Envio da Notificação Acerto ou Falha
if !empty(_cTo)

    // Validação e-mail parametrizado.
    if IsEmail(_cTo)

        EnviaMail(_cTo,_cAssunto,_cMensagem)

    elseIf !_lSche

        MsgAlert( "O(s) e-mail(s) cadastrados nos parâmetros : FS_ATCRERR|FS_ATCRALT, são inválidos, favor verificar !" ,'Atenção' )

    Endif

Endif

If !_lSche

    MsgInfo('Processo concluído. Foram alterados: ' + cValToChar(len(_aAcLimCr)) + ' Clientes.','Atenção')

Endif

Return

/*{Protheus.doc} CriaPar
			Cria Parâmetro
@author 	iVan de Oliveira
@since 		04/09/2019
@version 	P12
@param  	_aParam	, Array, {Código Parâmetro, tipo, Descrição, Descrição 1, Descrição 2, Conteúdo }
@return 	_lRet, Lógico, Retorno da Função --> Sucesso .T. / Falha .f.
*/
Static Function CriaPar(_aParam)

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
		
			SX6->X6_DSCSPA	:= SX6->X6_DESCRIC
			SX6->X6_DSCENG	:= SX6->X6_DESCRIC
			SX6->X6_DSCSPA1 := SX6->X6_DESC1
			SX6->X6_DSCENG1 := SX6->X6_DESC1
			SX6->X6_DSCSPA2 := SX6->X6_DESC2 
			SX6->X6_DSCENG2 := SX6->X6_DESC2 
			
			//Conteúdo
			SX6->X6_CONTEUD :=  _aParam[_nIt][06]
			SX6->X6_CONTSPA :=  _aParam[_nIt][06]
			SX6->X6_CONTENG :=  _aParam[_nIt][06]
			
		 
		SX6->(MsUnlock())
   		
   	Endif
   	
Next 

Return _lRet   

/*{Protheus.doc} Notifalha
			Envio de Notificações
@author 	iVan de Oliveira
@since 		07/09/2020
@version 	P12
@param  	_aParam	, Array, {Código Parâmetro, tipo, Descrição, Descrição 1, Descrição 2, Conteúdo }
@return 	_lRet, Lógico, Retorno da Função --> Sucesso .T. / Falha .f.
*/
Static Function Notifalha(_oErro, _cMens )

Local _lRet    := .F.

Default _cMens := ''
 
If _oErro:Gencode > 0   
  
    _cMens := "Processo: " + FunName() + CRLF
    _cMens += "Descrição do erro em tempo de execução: " + _oErro:DESCRIPTION + CRLF
    _cMens += "Errorstack:"  	  + CRLF
    _cMens +=  _oErro:ERRORSTACK  + CRLF
    
    _lRet  := .T.
 
Endif

Return _lRet  

/*/{Protheus.doc} ENVIAMAIL
// 			Envio de Nofiticações na Importação de Pedidos Leroy		
@author 	iVan de Oliveira	
@since 		18/02/2020
@version 	1.0
@return 	Null, Null, Null
@param		_cPara, Caractere, E-mail para envio
@param		_cAss , Caractere, Assunto do e-mail
@param		_cMens, Caractere, mensagem do corpo -email
@return 	Null, Null, Null
@type 		Static function
 /*/
Static Function EnviaMail(_cPara, _cAss, _cMens)

Local _cSMTPServer:= GETMV("MV_RELSERV") 
Local _cSMTPUser  := GETMV("MV_RELACNT")  
Local _cSMTPPass  := GETMV("MV_RELPSW") 
Local _lRelAuth   := GetMv("MV_RELAUTH",,.F.)

// Se o parâmetro estiver em branco não enviar notificação
if !Empty(_cPara)
 
	CONNECT SMTP SERVER _cSMTPServer ACCOUNT _cSMTPUser PASSWORD _cSMTPPass RESULT _lResult

	// Se a conexao com o SMPT esta ok
	If _lResult
	
		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If _lRelAuth
	
			_lResult := Mailauth( _cSMTPUser, _cSMTPPass )
			
		Endif
		
		// Se foi autenticado, enviar notificação
		If _lResult
	
			SEND MAIL;
			FROM 		_cSMTPUser;
			TO      	_cPara;
			SUBJECT 	_cAss;
			BODY    	_cMens;
			RESULT 		_lResult
		
			If !_lResult
			
				//Erro no envio do email
				GET MAIL ERROR _cError
				Aviso( "Notificação de falha envio e-mail: " + Funname(), "Erro na tentativa de envio: " + _cError, {}, 3)
				
			Endif
			
		Else
		
			//Erro De Acesso ao autenticação
			GET MAIL ERROR _cError
			Aviso( "Notificação de falha envio e-mail: " + Funname(), "Erro na tentativa de autenticação: " + _cError, {}, 3)
		
		Endif
		
	Else
	
		//Erro De Acesso ao SMTP
		GET MAIL ERROR _cError
		Aviso( "Notificação de falha envio e-mail: " + Funname(), "Erro na tentativa conexão SMTP: " + _cError, {}, 3)
				
	Endif
	
	DISCONNECT SMTP SERVER
 
Endif

Return
