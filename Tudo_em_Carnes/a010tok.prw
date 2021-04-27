#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} A010TOK
@description Replica cadastro de produto para as demais filiais. 
@type function

@author Leandro Procopio	
@since 14 03 2019
@version 1.0
/*/
User Function A010TOK

Local aArea    := GetArea()
Local lRet 	   := .T.
Local cMsg 	   := "Deseja incluir este produto nas demais Filiais?"
Local cCaption := "Copiando..."

If INCLUI
	//mostra pergunta do parametro cMsg
	If ApMsgNoYes(cMsg, cCaption)
		//tabela com as informaçoes das filiais
		DbSelectArea("SM0")
		nRec := SM0->(Recno())
		SM0->(dbGoTop())
		
		While SM0->(!Eof())
			//Filial da tabela é dIferente da filial logada?
			//If ALLTRIM(SM0->M0_CODFIL) <> ALLTRIM(cfilant) 
			  If SM0->M0_CODFIL <> cfilant
				RecLock("SB1",.T.)
				AvReplace("M","SB1")
				//altero a filial do produto
				//Matriz 
				If ALLTRIM(SM0->M0_CODFIL) == "010101" 
					//SB1->B1_FILIAL = SM0->M0_CODFIL     
					SB1->B1_FILIAL := "01" 
				Endif
				//Filial 
				If ALLTRIM(SM0->M0_CODFIL) == "020101"      
					SB1->B1_FILIAL := "02" 
				Endif
				//Armazem 
				If ALLTRIM(SM0->M0_CODFIL) == "010103"          
					SB1->B1_FILIAL := "03" 
				Endif
				//demais
				If ALLTRIM(SM0->M0_CODFIL) <> "010101" .AND. ALLTRIM(SM0->M0_CODFIL) <> "020101" .and. ALLTRIM(SM0->M0_CODFIL) <> "010103"
					SB1->B1_FILIAL = SM0->M0_CODFIL 
				ENDIF 
				//libero registro
				SB1->(MsUnlock())
			EndIf
		
		//proximo registro
		SM0->(DbSkip())
		End Do
	
		//libero registro
		//SM0->(dbCloseArea()) COMENTA ESSA LINHA NÃO PODE FECHAR ESSA TABELA
		SM0->(dbGoTo(nRec))
	EndIf
EndIf

RestArea(aArea)
Return lRet 
