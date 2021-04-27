#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "tbiconn.ch"
#Include "FWMVCDef.ch"

User Function ENVTITAPI()

	cEmp := "01"
	cFil := "0101"
	
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil	
    //u_RegTit(cFil,"013919","01","001","000286803",SPACE(TAMSX3("E1_PARCELA")[1]),"NF ") 

	u_RegTit(cFil,"001749","01","001","000301727",SPACE(TAMSX3("E1_PARCELA")[1]),"NF ")

Return
