#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT410TOK
@description validacoes pedido de venda 
@type function

@author Leandro Procopio	 
@since 18 02 2019
@version 1.0
/*/
User Function MT410TOK()

Local lRet      := .T.			// Conteudo de retorno
Local cMsg      := ""			// Mensagem de alerta
Local nOpc      := PARAMIXB[1]	// Opcao de manutencao
Local aRecTiAdt := PARAMIXB[2]	// Array com registros de adiantamento
Local cIp		:= GetClientIP()
Local cIpname   := GetComputerName() //ShowIPClient(general) = 1 retorna ip senao nome maquina. 
Local cCPU		:= ComputerName()

M->C5_XIP :=  cCPU

Return(lRet)