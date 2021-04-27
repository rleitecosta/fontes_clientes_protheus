#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MA020TDOK
@description Replica cadastro de fornecedor para as demais filiais. 
@type function

@author Leandro Procopio	
@since 18 03 2019
@version 1.0
/*/
user function MA020TDOK()
	

Local aArea    := GetArea()
Local lRet 	   := .T.
Local cMsg 	   := "Deseja incluir este fornecedor nas demais Filiais?"
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
				RecLock("SA2",.T.)
				AvReplace("M","SA2")
				//altero a filial do fornecedor
				//Matriz 
				If ALLTRIM(SM0->M0_CODFIL) == "010101" 
					//SA2->A2_FILIAL = SM0->M0_CODFIL     
					SA2->A2_FILIAL := "01" 
				Endif
				//Filial 
				If ALLTRIM(SM0->M0_CODFIL) == "020101"      
					SA2->A2_FILIAL := "02" 
				Endif
				//Armazem 
				If ALLTRIM(SM0->M0_CODFIL) == "010103"          
					SA2->A2_FILIAL := "03" 
				Endif
				//demais
				If ALLTRIM(SM0->M0_CODFIL) <> "010101" .AND. ALLTRIM(SM0->M0_CODFIL) <> "020101" .and. ALLTRIM(SM0->M0_CODFIL) <> "010103"
					SA2->A2_FILIAL = SM0->M0_CODFIL 
				ENDIF 
				//libero registro
				SA2->(MsUnlock())
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