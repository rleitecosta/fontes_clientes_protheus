#INCLUDE "TOTVS.CH"

/*-------------------------------------------------------------------------------------------------
{Protheus.doc} MT410INC
Rotina para validar todos os itens do PV 
Esse fonte é chamado pela inclusão automática de PV, MsGetDAuto()
@author  Mário A. Cavenaghi - EthosX
@since   15/09/2020
@release P12.1.25
@return  nil
-------------------------------------------------------------------------------------------------*/
User Function MT410INC()

   Local lRet := .T.

   If l410Auto
      lRet := U_CALCTES()
   Endif

Return(lRet)
