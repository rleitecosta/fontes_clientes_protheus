#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "FWEditPanel.CH"

	
#Define ALIAS_FORM0 			"SF2" 
#Define MODELO					"PLRC001"
#Define ID_MODEL				"PLRCOD01"
#Define TITULO_MODEL			"Análise Integrações"
#Define TITULO_VIEW				TITULO_MODEL
#Define ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#Define ID_VIEW_FORM0			"VIEW_FORM0"
#Define PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,02)

#DEFINE TYPE_HEADER				1
#DEFINE TYPE_ITEMS				2

/*/{Protheus.doc} PLRC001

MVC - Interface de Integrações de Notas Fiscais

@type function
@author Leandro Schumann Thomaz
@since 09/03/2021
@version P12
@database MSSQL,Oracle
@uso Plastireal 

/*/ 
User Function PLRC001()
	Local oFwMBrowse		:= Nil
	Local cAliasForm 		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_MODEL
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }
	
		
	Private aRotina		:= MenuDef()

	oFwMBrowse:= FWMBrowse():New()
	oFwMBrowse:SetAlias(cAliasForm)
	oFwMBrowse:SetDescription(cTitulo)
	oFwMBrowse:SetMenuDef(cModelo)
	
	oFwMBrowse:SetLocate()	
	oFwMBrowse:SetAmbiente(.F.)
	oFwMBrowse:SetWalkthru(.T.)		
	oFwMBrowse:SetDetails(.T.)
	oFwMBrowse:SetSizeDetails(60)
	oFwMBrowse:SetSizeBrowse(40)

	oFwMBrowse:SetCacheView(.T.)
	
	oFwMBrowse:AddLegend( PREFIXO_ALIAS_FORM0+"_XAFXSTA = 'I' " 					  , "BR_VERDE" , "Integrado" )
	oFwMBrowse:AddLegend( PREFIXO_ALIAS_FORM0+"_XAFXSTA = ' ' .OR. F2_XAFXSTA = 'N' " , "BR_BRANCO", "Não integrado" )
	oFwMBrowse:AddLegend( PREFIXO_ALIAS_FORM0+"_XAFXSTA = 'E' " 					  , "BR_PRETO" , "Erro na Integração" )
	
	oFwMBrowse:SetAttach( .T. )
	oFwMBrowse:SetOpenChart( .T. )	
	
	bKeyCTRL_X	:= SetKey( K_CTRL_X, bFecharEdicao )
			
	oFwMBrowse:Activate()
	
	SetKey( K_CTRL_X, bKeyCTRL_X )
	
	
Return

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	
	Local cIDModel			:= ID_MODEL
	Local cTitulo			:= TITULO_MODEL
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local cAliasForm 		:= ALIAS_FORM0
	Local oStructForm 		:= Nil
	Local oModel 			:= Nil							 
	Local bActivate			:= {|oModel| activeForm(oModel) }
	Local bPreValidacao		:= {|oModel| preValid(oModel)}
	Local bPosValidacao		:= {|oModel| posValid(oModel)} 
	
	Local cPrefForm			:= PREFIXO_ALIAS_FORM0
	Local cCpoFilial		:= cPrefForm+"_FILIAL"
	Local cCpoCodigo		:= cPrefForm+"_DOC"
	
	oStructForm	:= FWFormStruct( 1, cAliasForm )	

	oModel	:= MPFormModel():New(cIdModel,bPreValidacao,bPosValidacao,/*bCommit*/,/*bCancel*/)
	
	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)	
	
	oModel:SetPrimaryKey( { cCpoFilial, cCpoCodigo } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)	
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)

Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cModelo			:= MODELO
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local cIDViewForm		:= ID_VIEW_FORM0
	Local cAliasForm 		:= ALIAS_FORM0
	Local oModel 			:= Nil
	Local oStructForm		:= Nil
	Local oView				:= Nil	
	Local cPrefForm			:= PREFIXO_ALIAS_FORM0
	Local cCpoFilial		:= cPrefForm+"_FILIAL"
	Local cCpoCodigo		:= cPrefForm+"_DOC"
	Local cCpoStats			:= cPrefForm+"_XAFXSTA"
	Local cCpoMsg			:= cPrefForm+"_XAFXMSG"
	
	Local cCamposCab		:= cCpoFilial+"|"+cCpoCodigo+"|"+cCpoStats+"|"+cCpoMsg+"|"

	oModel 		:= FWLoadModel( cModelo )
	nOperacao	:= oModel:GetOperation()
	
	//oStructForm	:= FWFormStruct( 2, cAliasForm )
	oStructForm	:= FWFormStruct( 2, cAliasForm , {|cCampo| AllTrim(cCampo)+"|" $ cCamposCab })


	oView 		:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField(cIDViewForm,oStructForm,cIDModelForm)
	
	
	oView:SetViewProperty(cIDViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )	
	
	oView:CreateHorizontalBox('TOTAL',100)
	
	oView:SetOwnerView( cIDViewForm,'TOTAL' )
	
Return oView



/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local cModelo	:= MODELO 
	Local aRotina 	:= {}
	
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.' + cModelo    OPERATION 2 ACCESS 0


Return aRotina

/*
	Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
*/
Static Function preValid(oModel)
	Local lRet			:= .T.

	
Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)

	Local lRet				:= .T.

	
Return lRet
