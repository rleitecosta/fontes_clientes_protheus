#INCLUDE "PROTHEUS.CH"

/*-------------------------------------------------------------------------------------------------
{Protheus.doc} M460FIM
Ponto de Entrada após a Prepearação de Documento de Saída
@author  Mário A. Cavenaghi - EthosX
@since   14/09/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------*/
User Function M460FIM()

	Processa({|| U_GERDANFE()})

Return(.T.)
