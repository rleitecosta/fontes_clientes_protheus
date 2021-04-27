#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH" 
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"   

/*/{Protheus.doc} FATA010             
//	        Processo de desmembramento do pedido de venda de uma empresa a outra
@author 	iVan de Oliveira - EthosX	
@since 		12/11/2020
@uso        Especifico TC
@version 	1.0
@param		_cNumPed , Caractere, N�mero do Pedido a ser verificado
@param		_cRetorno, Caractere, Tipo de retorno esperado.
@param		_aLOG	 , Array	, Array com Informa��o dos Pedigos Gerados.
@return 	_uRET, Qualquer, Retorno da fun��o conforme solictado: L�gico, caractere.
@type 		User function
/*/ 
User function FATA010(_cNumPed, _cRetorno, _aLOG )

Local _aParamF 	:= {}
Local _nIt      := 0
Local _lRet     := .T.
Local _nRet 	:= 1
Local nRecSC9   := 0
 
Default _cRetorno := 'L'

// Criando os Par�metros
Aadd(_aParamF, {'FS_TCEMPTR', 'C', 'C�digo das Empresas que 	 ', 'servir�o de refer�ncia destino '	  , 'para transfer�ncia de itens pedido.', '040101|' })
Aadd(_aParamF, {'FS_TCGRPRD', 'C', 'C�digo de Grupos de Produtos ', 'para transfer�ncia de itens pedido. ', ' Destino contido em <FS_TCEMPTR> ',  ' '})

if CriaPar(_aParamF)

	// Transfer�ncia somente de filiais diferente do conte�do: FS_TCEMPTR
	_nTamFil := len( FWCodFil())
	_cFilExec:= left(alltrim(Upper(SuperGetMv("FS_TCEMPTR",,"040101"))),_nTamFil)

	if alltrim(Upper(FWCodFil())) # alltrim(Upper(_cFilExec)) 

		_cGrupos := alltrim(Upper(SuperGetMv("FS_TCGRPRD",,"")))
		_aItens  := {}
		
		// Se estiver preenchido grupos
		if !Empty(_cGrupos)

			// Verificando se j� existe Pedido com a numera��o no destino.
			_nRegAtu := SC5->(Recno())

			dbSelectArea("SC5")
			dbSetOrder(1)

			if !dbSeek( _cFilExec + _cNumPed )

				// Retorna registro atual
				SC5->(DbGoto(_nRegAtu))

				// Efetuando verifica��o transfer�ncia
				_aItDel := {}
				
				dbSelectArea("SC6")
				dbSetOrder(1)
				MsSeek(xFilial("SC6")+_cNumPed)
					
				While !Eof() .And. SC6->C6_FILIAL == FwxFilial("SC6") .And.;
								SC6->C6_NUM == _cNumPed

					// Informa��o do Grupo Produto
					_aInfoPr := GetAdvFVal("SB1", {"B1_GRUPO"}, FwxFilial("SB1") + SC6->C6_PRODUTO, 1, {''} )

					if !Empty(_aInfoPr[01])

						if alltrim(Upper(_aInfoPr[01])) $ _cGrupos

							// Incluindo o Item a ser Desmembrado.
							_aLinha := {}
							aadd( _aLinha,{"C6_ITEM"	, SC6->C6_ITEM		, Nil})
							aadd( _aLinha,{"C6_PRODUTO"	, SC6->C6_PRODUTO	, Nil})
							aadd( _aLinha,{"C6_LOCAL"  	, SC6->C6_LOCAL		, Nil})
							aadd( _aLinha,{"C6_QTDVEN"	, SC6->C6_QTDVEN	, Nil})
							aadd( _aLinha,{"C6_PRCVEN"	, SC6->C6_PRCVEN 	, Nil})
							aadd( _aLinha,{"C6_PRUNIT"	, SC6->C6_PRUNIT  	, Nil})
							aadd( _aLinha,{"C6_VALOR"	, SC6->C6_VALOR   	, Nil})
							aadd( _aLinha,{"C6_TES"		, SC6->C6_TES   	, Nil})
							aadd( _aLinha,{"C6_LOTECTL"	, SC6->C6_LOTECTL	, Nil})
							aadd( _aLinha,{"C6_DTVALID"	, SC6->C6_DTVALID	, Nil})
							aadd( _aLinha,{"C6_LOTECTL"	, SC6->C6_LOTECTL	, Nil})
							aadd( _aLinha,{"C6_NUMLOTE"	, SC6->C6_NUMLOTE	, Nil})
							aadd( _aLinha,{"C6_REVPROD"	, SC6->C6_REVPROD	, Nil})
							aadd( _aLinha,{"C6_SERVIC"	, SC6->C6_SERVIC	, Nil})
							aadd( _aLinha,{"C6_ENDPAD"	, SC6->C6_ENDPAD	, Nil})
							aadd( _aLinha,{"C6_CC"		, SC6->C6_CC		, Nil})
							aadd( _aLinha,{"C6_CONTA"	, SC6->C6_CONTA		, Nil})
							aadd( _aLinha,{"C6_ITEMCTA"	, SC6->C6_ITEMCTA	, Nil})
							aadd( _aLinha,{"C6_CLVL"	, SC6->C6_CLVL		, Nil})
							aadd( _aLinha,{"C6_OPER"	, SC6->C6_OPER		, Nil})

							aadd(_aItens, _aLinha)
							
							dbSelectArea("SC9")
							dbSetorder(2)//C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM                                                                                                                  
							If dbSeek(FwxFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM)
								nRecSC9 := SC9->(Recno())					
						   		//cWHERE :=  "C9_FILIAL = '"+FwxFilial("SC6")+"' AND C9_PEDIDO = '"+ SC6->C6_NUM+"' AND C9_ITEM = '"+SC6->C6_ITEM+"' AND C9_CLIENTE = '"+SC6->C6_CLI+"' AND C9_LOJA = '"+SC6->C6_LOJA+"' AND C9_PRODUTO = '"+SC6->C6_PRODUTO+"' AND C9_NFISCAL = ''"
							Endif

							// Guarda o Registro para posterior exclus�o do item transferido.
							dbSelectArea("SC6")
							aadd(_aItDel,{SC6->(Recno()),nRecSC9})

						Endif

					Endif

					SC6->(dbSkip())

				Enddo

				// Se houver algum item a transferir
				if !Empty(_aItens)

					_aCabec   := {}
					aadd(_aCabec, {"C5_NUM",     SC5->C5_NUM	,  Nil})
					aadd(_aCabec, {"C5_TIPO",    SC5->C5_TIPO	,  Nil})
					aadd(_aCabec, {"C5_CLIENTE", SC5->C5_CLIENTE,  Nil})
					aadd(_aCabec, {"C5_LOJACLI", SC5->C5_LOJACLI,  Nil})
					aadd(_aCabec, {"C5_LOJAENT", SC5->C5_LOJAENT,  Nil})
					aadd(_aCabec, {"C5_CONDPAG", SC5->C5_CONDPAG,  Nil})
					aadd(_aCabec, {"C5_XRETIRA", SC5->C5_XRETIRA,  Nil})
					aadd(_aCabec, {"C5_FECENT",  SC5->C5_FECENT ,  Nil})
					aadd(_aCabec, {"C5_VDESCRI", SC5->C5_VDESCRI,  Nil})
					aadd(_aCabec, {"C5_TABELA" , SC5->C5_TABELA ,  Nil})
					aadd(_aCabec, {"C5_VEND1"  , SC5->C5_VEND1  ,  Nil})
					aadd(_aCabec, {"C5_VEND2"  , SC5->C5_VEND2  ,  Nil})
					aadd(_aCabec, {"C5_VEND3"  , SC5->C5_VEND3  ,  Nil})
					aadd(_aCabec, {"C5_VEND4"  , SC5->C5_VEND4  ,  Nil})
					aadd(_aCabec, {"C5_VEND5"  , SC5->C5_VEND5  ,  Nil})
					aadd(_aCabec, {"C5_FRETE"  , SC5->C5_FRETE  ,  Nil})
					aadd(_aCabec, {"C5_TPFRETE", SC5->C5_TPFRETE,  Nil})
					aadd(_aCabec, {"C5_FRETAUT", SC5->C5_FRETAUT,  Nil})
					aadd(_aCabec, {"C5_COTACAO", SC5->C5_COTACAO,  Nil})
					aadd(_aCabec, {"C5_VLR_FRT", SC5->C5_VLR_FRT,  Nil})
					aadd(_aCabec, {"C5_REDESP" , SC5->C5_REDESP ,  Nil})
					aadd(_aCabec, {"C5_VEICULO", SC5->C5_VEICULO,  Nil})
					aadd(_aCabec, {"C5_RECFAUT", SC5->C5_RECFAUT,  Nil})
					aadd(_aCabec, {"C5_XOBSERV", SC5->C5_XOBSERV,  Nil})
					aadd(_aCabec, {"C5_TRANSP" , SC5->C5_TRANSP ,  Nil})
					aadd(_aCabec, {"C5_TPCARGA", SC5->C5_TPCARGA,  Nil})
					aadd(_aCabec, {"C5_FORNISS", SC5->C5_FORNISS,  Nil})
					aadd(_aCabec, {"C5_VEICULO", SC5->C5_VEICULO,  Nil})
					aadd(_aCabec, {"C5_CODMOT" , SC5->C5_CODMOT ,  Nil})
					aadd(_aCabec, {"C5_PLACA1" , SC5->C5_PLACA1 ,  Nil})
					aadd(_aCabec, {"C5_PLACA2" , SC5->C5_PLACA2 ,  Nil})
					aadd(_aCabec, {"C5_MENNOTA", SC5->C5_MENNOTA,  Nil})
					
					//Nome arquivo LOG
					_cNArqLOG := Dtos(date())+StrTran(Time(),':','') + ".log"

					// Executa a inclus�o na filial indicada par�metro FS_TCEMPTR
					_aRet := StartJob("u_fata011",GetEnvserver(),.T.,_aCabec,_aItens, cEmpAnt, _cFilExec, _cNArqLOG )
	
					// Verificando se ocorreu erro
					if !_aRet[01] .and. !Empty(_aRet[02])

						// Adiciona ao Array retorno					
						Aadd(_aLOG, {_cFilExec, _aCabec[01][02], "*** N�o Gerado ***", _aRet[02] })

						_lRet := .F.
						_nRet := 0

					else

						// Se foi bloqueado, enviar mensagem de alerta.
						_cMensErro := "Gerado/Liberado com Sucesso."
						if !_aRet[01]

							_cMensErro := "Pedido gerado com sucesso, por�m houve falha de libera��o. Favor realizar LIBERA��O manualmente !"
						
						Endif

						// Adiciona ao Array retorno					
						Aadd(_aLOG, {_cFilExec, _aCabec[01][02], _aCabec[01][02] ,  _cMensErro })

						_lRet := .T.
						_nRet := 1

					Endif
				
					// Se retornou sucesso, apagar os registros transferidos.
					if _lRet 

						ProcRegua(len(_aItDel))

						dbSelectArea("SC6")
						dbSetOrder(1)

						dbSelectArea("SC9")
						dbSetOrder(1)


						For _nIt := 1 to len(_aItDel)  

							IncProc() 

							// Posicionando item que foi transferido.
							SC6->( dbGoto(_aItDel[_nIt][1]) )

							Reclock("SC6",.F.,.T.)
								dbDelete()
							FkCommit()
							
							If _aItDel[_nIt][2] > 0
							SC9->( dbGoto(_aItDel[_nIt][2]) )
							  Reclock("SC9",.F.,.T.)
								dbDelete()
							  FkCommit()
							EndIf

						Next

					Endif

				Endif

			else

				// Adiciona ao Array retorno					
				//Aadd(_aLOG, {_cFilExec, _cNumPed, "*** N�o Gerado ***", 'N�mero de Pedido j� existe no destino. Exclua o mesmo e refa�a opera��o.' })

				MsgAlert ( 'Pedido j� foi transferido para filial: ' + _cFilExec )

				_lRet := .T.
				_nRet := 1

			Endif

		Endif

	Endif

Endif

_uRET := if(_cRetorno == 'L', _lRet, _nRet )

Return _uRET

/*{Protheus.doc} FATA011
			Executa Inclus�o de Pedido noutra Empresa
@author 	iVan de Oliveira - EthosX
@since 		12/11/2020
@version 	P12
@type 		function
param  		_aCabPed , Array, Cabe�alho do Pedido de Vendas.
param  		_aItPed  , Array, Itens do Pedido de Vendas.
param		_cEmpExec, Caracter, Empresa onde ser� realizado a inclus�o
param		_cFilEx	 , Caracter, Filial onde ser� realizado a inclus�o
param		_cNomArq , Caracter, Nome do arquivo reservado para ger��o do LOG, caso haja erro.
return 	_lRet, L�gico, Retorno da Fun��o --> Sucesso .T. / Falha .f.

*/
User Function FATA011(_aCabPed, _aItPed, _cEmpExec, _cFilEx, _cNomArq )

Local _aPvlNfs  := {}
Local _aBloqueio:= {}
Local _aRet		:= {.F., '' }
Local _nCntFor  := 0
Local _lCont	:= .F.


Private lMsErroAuto:= .F.

// Preparando ambiente a ser realizado a transfer�ncia.
PREPARE ENVIRONMENT EMPRESA _cEmpExec FILIAL _cFilEx MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"

	 // Substituindo pela TES inteligente
	 _nPosCli := AsCan(_aCabPed,    {|x| AllTrim(x[01]) == "C5_CLIENTE"}) 
	 _nPosLj  := AsCan(_aCabPed,    {|x| AllTrim(x[01]) == "C5_LOJACLI"}) 
	 _nPosTes := AsCan(_aItPed[01], {|x| AllTrim(x[01]) == "C6_TES"}) 
	 _nPosPrd := AsCan(_aItPed[01], {|x| AllTrim(x[01]) == "C6_PRODUTO"}) 

	 // Se os posicionamentos foram encontrados.
	 if _nPosCli >0 .and. _nPosLj>0 .and._nPosTes > 0 .and. _nPosPrd > 0

		_cCliente:= _aCabPed[_nPosCli][02]
	 	_cLjCli  := _aCabPed[_nPosLj][02]
	 	_cTpOper := SuperGetMV("MV_LJLPTIV",,"01")	

		// Substituindo as TES
		For _nCntFor:= 1 To Len(_aItPed)
 
			// Sele��o TES Inteligente
			_cProd   := _aItPed[_nCntFor][_nPosPrd][02] 
			_cTesInt := MaTESInt( 2, _cTpOper, _cCliente, _cLjCli,"C", _cProd)

			if !Empty(_cTesInt)

				_aItPed[_nCntFor][_nPosTes][02]  := _cTesInt

			Else

				// Sair do la�o pois n�o encontrou a TES Inteligente
				Exit

			Endif

			// �ltima ocorr�ncia liberar inclus�o.
			if _nCntFor == Len(_aItPed)

				_lCont	:= .T.

			Endif

		Next

	EndIf

	// Continuar a incluir
	if _lCont 
 
		// Inclusao do pedido
		MATA410(_aCabPed,_aItPed,3)

		// Checa erro de rotina automatica
		If lMsErroAuto

			_cArqMErr := Mostraerro( "\spool\" , _cNomArq )
			_cMensErro := _VerErr(_cArqMErr)

			_aRet[02] := 'Ocorreu erro de processamento inv�lido(campo/conte�do): ' + _cMensErro + '. Favor verificar o campo indicado na filial destino e tente novamente.'
								
		Else
					
			// Liberacao de pedido
			Ma410LbNfs(2,@_aPvlNfs,@_aBloqueio)

			// Checa itens liberados
			Ma410LbNfs(1,@_aPvlNfs,@_aBloqueio)

		Endif

		_aRet[01] :=  !lMsErroAuto

	Else

		_aRet[02] := 'N�o foi poss�vel localizar a TES Inteligente para este pedido na filial: ' + _cFilEx + '. Favor verificar com suporte esta ocorr�ncia tente novamente.'
		
	Endif

RESET ENVIRONMENT

Return _aRet

/*/{Protheus.doc} _VerErr
Retornar Campo com Erro de Error.LOG(ExecAuto)
@type 	Static function
@author iVan de Oliveira - EthosX
@since 	12/11/2020
@version 1.0

@Param  ${Caractere},${_cArqMErr}, Local e nome do arquivo de LOG
@return ${Caractere},${_cCampo}  , Nome do campo e seu conte�do com erros.

@example 
_VerErr(_cArqMErr)
 /*/
Static Function _VerErr(_cArqMErr)

_nLinhas:=MLCount(_cArqMErr) 
_cBuffer:="" 
_cCampo:="" 
_nErrLin:=1 
_cBuffer:=RTrim(MemoLine(_cArqMErr,,_nErrLin))      
          
//Carrega o nome do campo 
While (_nErrLin <= _nLinhas) 

	 _nErrLin++ 
	 _cBuffer:=RTrim(MemoLine(_cArqMErr,,_nErrLin)) 
	 
	 // Procura a linha com a Mensage de Inv�lido
     If (Upper(SubStr(_cBuffer,Len(_cBuffer)-7,Len(_cBuffer))) == "INVALIDO") 
     
     	_cCampo	:= _cBuffer 
      	_xTemp	:= AT("-",_cBuffer) 
      	_cCampo	:= AllTrim(SubStr(_cBuffer,_xTemp+1,AT("<",_cBuffer)-_xTemp-2))
        _cCampo := StrTran(_cCampo, ":=","=") 
        Exit
         
     EndIf 
     
EndDo                
 
Return _cCampo

/*{Protheus.doc} CRIAPAR
			Cria Par�metro
@author 	iVan de Oliveira - EthosX
@since 		12/11/2020
@version 	P12
@param  	_aParam	, Array, {C�digo Par�metro, tipo, Descri��o, Descri��o 1, Descri��o 2, Conte�do }
@return 	_lRet, L�gico, Retorno da Fun��o --> Sucesso .T. / Falha .f.
*/
Static Function CRIAPAR(_aParam)

Local _nIt := 0   
Local _lRet:= .T.
  
DeFault _aParam := {}

// Incluindo os Par�metros.
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
		
			//Descri��o
			SX6->X6_DESCRIC :=  _aParam[_nIt][03]
			SX6->X6_DESC1   :=  _aParam[_nIt][04]
			SX6->X6_DESC2   :=  _aParam[_nIt][05]
			
			//Conte�do
			SX6->X6_CONTEUD :=  _aParam[_nIt][06]
			SX6->X6_CONTSPA :=  _aParam[_nIt][06]
			SX6->X6_CONTENG :=  _aParam[_nIt][06]
			
   		SX6->(MsUnlock())
   		
   	Endif
   	
Next 

Return _lRet   
