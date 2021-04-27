#INCLUDE "TOTVS.CH"

/*-----------------------------------------------------------------------------------------------
{Protheus.doc} MT360GRV
Ponto de Entrada após a gravação da Condição de Pagamento
Usados para integrar com AFX / CODIT
@author  Mário A. Cavenaghi - EthosX
@since   14/10/2020
@release P12.1.25
-------------------------------------------------------------------------------------------------
*/
Static lDeletado := .F.

User Function MT360GRV

	Local lEnviarAFX := INCLUI	//	Registro Novo
	Local nExclui := 0	//	Registro a ser excluído

	If !lEnviarAFX
		If M->E4_DESCRI <> SE4->E4_DESCRI	//	.T. se alterou o nome
			lEnviarAFX := .T.
		Elseif lDeletado	//	Deletado
			lEnviarAFX := .T.
			nExclui := SE4->(Recno())
		Endif
	Endif
	If lEnviarAFX
		SE4->(RecLock("SE4"))
		SE4->E4_XCODIT := " "
		SE4->(msUnLock())
		U_FSFATM01("SE4", nExclui)
		lDeletado := .F.
	Endif

Return(.T.)


//-----------------------------------------------------------------------------------------------
//	Ponto de Entrada na validação da Exclusão
User Function MT360DEL

	lDeletado := .T.

Return(.T.)
