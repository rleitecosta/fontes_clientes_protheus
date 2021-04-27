#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include 'protheus.ch'
#Include 'parmtype.ch'        
#Include "TopConn.Ch"

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Programa: WSRESTEFFFIN    Ultima Alteração: Carlos H Fernandes      Data: 29/01/2021  
//Descrição: API Cliente - Get para consulta financeira do cliente 
//Uso: Plastireal
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Modelo
{
    "resources": [
        {
            "models": [
                {
                    "fields": [
                        {
                            "id": "A1_LC",
                            "value": 123
                        },
                        {
                            "id": "A1_SALPEDL",
                            "value": 123
                        },
                        {
                            "id": "A1_SALDUP",
                            "value": 123
                        }
                    ]
                }
            ]
        }
    ]
}
*/

WSRESTFUL WSRESTEFFFIN DESCRIPTION "WEBSERVICE REST - CONSULTA FINANCEIRA" FORMAT APPLICATION_JSON

	WSDATA Emp  AS CHARACTER
	WSDATA Fil  AS CHARACTER
	WSDATA CGC  AS CHARACTER

	WSMETHOD GET GetConFin;
        DESCRIPTION 'Retorna consulta Financeira de Clientes';
        WSSYNTAX '/GetConFin';
        PATH 'GetConFin';
        PRODUCES APPLICATION_JSON
END WSRESTFUL

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------

WSMETHOD GET GetConFin WSRECEIVE Emp, Fil, CGC WSREST WSRESTEFFFIN

Local cRet
Local aParam 	:= {}
Local cValEmp	:= Self:Emp 	
Local cValFil 	:= Self:Fil
Local cValCGC	:= Self:CGC
Local lRes 		:= .T.
Local oObj
Local oJSON 	:= JsonObject():New()

::SetContentType("application/json") 
aParam 	:= ::aURLParms

If !Empty(cValEmp) .And. !Empty(cValFil)

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cValEmp,cValFil) 

	DbSelectArea("SA1")
	DbSetOrder(3)
	IF DbSeek(xFilial("SA1")+PADR(cValCGC,TAMSX3("A1_CGC")[1]))
		cRet := ' {"resources":[{"models":[{'
        cRet += ' "fields":[{"id":"A1_LC","value":"'+Alltrim(Str(SA1->A1_LC))+'"},'
        cRet += '           {"id":"A1_SALPEDL","value":"'+Alltrim(Str(SA1->A1_SALPEDL))+'"},'
        cRet += '           {"id":"A1_SALDUP","value":"'+Alltrim(Str(SA1->A1_SALDUP))+'"}]}]}]}'
	Else
		cRet := '{"found":"false"}'
	endif
	cRet := EncodeUTF8(cRet, "cp1252")
	::SetResponse(cRet)

Else
	
    lRes := .F.
	SetRestFault(400,EncodeUTF8("Inserir os parâmetros: Empresa e Filial", "cp1252"))	
	Return lRes

endif

Return lRes