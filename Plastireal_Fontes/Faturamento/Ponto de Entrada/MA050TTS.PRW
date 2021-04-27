#INCLUDE "TOTVS.CH"

/*-----------------------------------------------------------------------------------------------
{Protheus.doc} MA050TTS
Ponto de Entrada após a gravação da Transportadora
Usados para integrar com AFX / CODIT
@author  Mário A. Cavenaghi - EthosX
@since   07/10/2020
@release P12.1.25
-------------------------------------------------------------------------------------------------
*/
Static lDescricao := .F.
Static lDeletado := .F.

User Function MA050TTS

	Local lEnviarAFX := INCLUI	//	Registro Novo
	Local nExclui := 0	//	Registro a ser excluído

	If !lEnviarAFX
		If lDescricao 	//	Alteração da descrição
			lEnviarAFX := .T.
		Elseif lDeletado	//	Deletado
			lEnviarAFX := .T.
			nExclui := SA4->(Recno())
		Endif
	Endif
	If lEnviarAFX
		SA4->(RecLock("SA4"))
		SA4->A4_XCODIT := " "
		SA4->(msUnLock())
		U_FSFATM01("SA4", nExclui)
		lDescricao := .F.
		lDeletado := .F.
	Endif

Return(.T.)


//-----------------------------------------------------------------------------------------------
//	Ponto de Entrada na validação dos Dados
User Function M050TOK

	lDescricao := M->A4_NOME <> SA4->A4_NOME	//	.T. se alterou o nome

Return(.T.)


//-----------------------------------------------------------------------------------------------
//	Ponto de Entrada na validação da Exclusão
User Function MTA050E

	lDeletado := .T.

Return(.T.)
