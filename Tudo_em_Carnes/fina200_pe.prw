#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'

/*=====================================================================*
|| Func:  FINA200.prw                                                  ||
|| Autor: Leandro Procopio                                             ||
|| Data:  08 11 2018                                                   ||
|| Desc:  P.E para Baixa CNAB (Retorno)					               ||
|| Obs.:  .                                                            ||
 *=====================================================================*/
 
User Function FINA200()

//-----------------------------------------------------------------------
// Ponto de Entrada no retorno do arquivo bancario. 
// tratamento do valor de despesa de cobranca itau carteira 109. 
// O ponto de entrada FINA200 sera executado antes da gravacao dos dados dos títulos que serão baixados.
// Algumas variáveis poderão ter seu conteúdo alterado:
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Variaveis Globais: 
// cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
//Campos que podem ser alterados: 
// nValRec: Valor total recebido 
// nTotAbat: Valor total abatimento 
// dDataCred: Data do Crédito
//-----------------------------------------------------------------------

//MsgAlert("FINA200 : " )
//MsgAlert("Desconto : "        + STR( nDescont ) )
//MsgAlert("Multa : "           + STR( nMulta ) )
//MsgAlert("Despesas : "        + STR( nDespes ) )
//MsgAlert("Outros Despesas : " + STR( nOutroDesp ) )
//MsgAlert("Abatimento : "      + STR( nAbatim ) )
//MsgAlert("nValcc : "          + STR( nValCC ) )

	//Soma Juros no valor do titulo quando utilizado modelo ITAU CNAB.
	//Demais bancos a conta é feita automática. 
	If nJuros > 0 .AND. ALLTRIM(SE1->E1_PORTADO) == "341"  //ITAU
		nValRec := SE1->E1_VALOR + nJuros
	EndIf 
	
   /*
   // Se desconto = Despesa nao precisa somar
   IF ALLTRIM(SE1->E1_PORTADO) == "341" .AND. ALLTRIM(SE1->E1_AGEDEP) == "0001" .AND. ALLTRIM(SE1->E1_CONTA) == "xxxxxx" 
	   If SE1->E1_VALOR - nValRec = 1.99
	      nValRec := SE1->E1_VALOR
	   Endif
   Endif
   */

Return()