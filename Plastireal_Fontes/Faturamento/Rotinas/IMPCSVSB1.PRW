#include 'protheus.ch'
#define  CTRL_CAMPOS  1    // Cantidad de campos del regristo  count
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ Impcsv   ³ Autor ³  Marcio Torresson     ³ Data ³20/06/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Leitura de arquivo .CSV e importação de dados para o sis-  ³±±
±±³          ³ tema Microsiga, lenvando em conta parametros definidos pelo³±±
±±³          ³ cliente													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function ImpCSVSB1()

Private cEdit1	 := Space(15)
Private cEdit2	 := Space(02)
Private cEdit3	 := Space(25)
Private cEdit4	 := Space(25)
Private oEdit1
Private oEdit2
Private oEdit3
Private oEdit4
Private nPanel  := 1,;
oDlg, oBmp1, oBmp2, oGet,;
nOpca  := 0,;
cFile  := Space(255),;
cType  := "Todos Arquivos      | *.* ",;
dDatSvd:= dDataBase

DEFINE DIALOG oDlg FROM 000,000 TO 320,480 TITLE OemToAnsi('Importação de Série') PIXEL
@ 035, 050 TO 140, 230 OF oDlg PIXEL
@ 000, 050 BITMAP oBmp1 RESNAME "APLOGO" OF oDlg SIZE 100,200 NOBORDER  WHEN .F. PIXEL
@ 000, 000 BITMAP oBmp2 RESNAME "LOGIN"  OF oDlg SIZE 050,155 NOBORDER  WHEN .F. PIXEL

/*@ 040,070 Say "Produto" Size 020,008 COLOR CLR_BLACK PIXEL OF oDlg
@ 040,100 MsGet oEdit1 Var cEdit1 Size 089,009 COLOR CLR_BLACK PIXEL OF oDlg
@ 060,100 MsGet oEdit2 Var cEdit2 Size 021,009 COLOR CLR_BLACK PIXEL OF oDlg
@ 060,070 Say "Armazem" Size 023,008 COLOR CLR_BLACK PIXEL OF oDlg
@ 080,100 MsGet oEdit3 Var cEdit3 Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
@ 080,070 Say "Endereco" Size 025,008 COLOR CLR_BLACK PIXEL OF oDlg
@ 100,100 MsGet oEdit4 Var cEdit4 Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
@ 100,070 Say "Lote" Size 012,008 COLOR CLR_BLACK PIXEL OF oDlg */

@ 120,070 MSGET oGet VAR cFile SIZE 125,10 PIXEL OF oDlg
@ 120,200 BUTTON OemToAnsi("...") SIZE 15,10 PIXEL OF oDlg ACTION cFile := Padr( cGetFile(cType, OemToAnsi("Selecionando o arquivo "+Subs(cType,1,6)),0,,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE), 255 )

DEFINE SBUTTON FROM  145, 170 TYPE 1 ACTION (Iif(TudoOk(),oDlg:End(),.F.)) ENABLE PIXEL OF oDlg
DEFINE SBUTTON FROM  145, 200 TYPE 2 ACTION (nOpca := 0, oDlg:End()) ENABLE PIXEL OF oDlg
ACTIVATE DIALOG oDlg CENTERED

If nOpca == 1
	Processa( { || ProcCli( ) }, 'Procesando Arquivo...' )
	Aviso(OemToAnsi("Confirmação"),"Processo Finalizado",{"Ok"},1)
EndIf

dDataBase   := dDatSvd

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n     ³          ³ Autor ³                     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripci¢n ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcCli( )
Local cEOF      := Chr(13) + Chr(10),;
nByte     := 0,;
nX        := 0,;
nZ        := 0,;
nMaxLin   := 359,;
nTamFile  := 0,;
nHnd, cString,;
lOk       := .F.,;
lRet      := .F.,;
cFileLog  := "",;
cPath     := "",;
nReg      := 1,;
aVals     := {},;
aDocs     := {},;
nFila     := 0,;
aError    := {},;
xControle := 0,;
xCtrlGrava := 0,;
lgrava    := .t.,;
xReg      := 0,;
xgravado  := 0,;
cCodRelac := "",;
xGravaRel := 0


Local cArqTrab := "TRB"
Local aStruTRB := {}
Local nTamCod  := 0
Local nTamComp := 0
Local aVetor := {} 
private lMsErroAuto := .F. 


nHnd  := FOpen( Alltrim( Lower( cFile ) ) )
If nHnd == -1
	Aviso("Falha de Abertura", "Ouve uma falha na abertura do arquivo.", {"Ok"}, 1 )
	DbCloseArea("TRB")
	Return( .F. )
EndIf

cFile := Alltrim( Lower( cFile ) )

nTamFile := FSeek( nHnd, 0, 2 )
FSeek( nHnd, 0, 0 )

AutoGrLog( "Data Inicio.......: " + Dtoc(MsDate()) )
AutoGrLog( "Hora Inicio........: " + Time() )
AutoGrLog( "Environment........: " + GetEnvServer() )
AutoGrLog( "Usuario............: " + SubStr( cUsuario, 7, 15 ) )
AutoGrLog( "Arquivo............: " + Alltrim( Lower( cFile ) ) )
AutoGrLog( " " )

ProcRegua(400)

While nByte < nTamFile
	
	nFila += 1
	IncProc( 'Procesando ' + Alltrim(Str(nByte,12,0)) + ' de ' + Alltrim(Str(nTamFile,12,0))+' Fila: '+ alltrim(str(nFila,12,0)))
	
	cString  := Space( nMaxLin )
	nRead    := FRead( nHnd, @cString, nMaxLin )
	nPos     := At( cEOF, cString )
	If nPos != 0
		nByte += ( nPos + 1 )
		FSeek( nHnd, nByte, 0 )
		cResult  := SubStr( cString, 1, nPos - 1 )
	Else
		nByte := nTamFile
		cResult  := SubStr( cString, 1, nPos - 1 )
	EndIf
	
	aVals     := Str2Array( cResult, ';' )
	nLenField := Len( aVals )             
	if nLenField > 0 .and. nFila == 0
		nFila := 1                   
	endif
	
	lOk       := .T.
	
	If nLenField < CTRL_CAMPOS
		AutoGrLog( "ERROR Processando a fila: " + strzero( nFila, 4)+"-"+avals[1] )
		lgrava := .f.
		Loop
	EndIf
	
	if nFila > 1                                            

		if empty(avals[1])
			loop
		endif		    

//    	*** inclusão dos itens que não existem 
        dbselectarea("SB1")
        dbSetorder(1)
        If dbSeek(xFilial("SB1")+PADR(avals[1],TAMSX3("B1_COD")[1]))
        RecLock("SB1",.F.)
		
		 SB1->B1_POSIPI  := avals[2]
		/* 
            SB1->B1_DESC     := avals[2]
	        SB1->B1_CLASMAT  := avals[4]	    
            SB1->B1_PAD3     := avals[5]
            SB1->B1_ATIVO    := avals[7]
            SB1->B1_BASE3    := avals[9]
            SB1->B1_DESBSE3  := avals[10]
            SB1->B1_POSIPI   := avals[17]
            SB1->B1_ORIGEM   := avals[18]
            SB1->B1_GRTRIB   := avals[19]
            SB1->B1_IPI      := VAL(avals[20])
            */            
		SB1->(MsUnLock())
		Endif
		/*
        dbselectarea("SB5")
        dbSetorder(1)
        If dbSeek(xFilial("SB5")+PADR(avals[1],TAMSX3("B5_COD")[1]))
        RecLock("SB5",.F.)
        
		SB5->B5_CEME        := avals[2]
        SB5->B5_XCOR        := avals[11]
        SB5->B5_DIAEXT      := val(avals[12])
        SB5->B5_DIAINT      := val(avals[13])
        SB5->B5_ESPESS      := val(avals[14])
        SB5->B5_LARG        := val(avals[15])
        SB5->B5_COMPR       := val(substr(avals[16],1,6))
    
       	SB5->(MsUnLock())
	    EndIf
		*/            
		
	Endif   
 		
EndDo

FClose( nHnd )

AutoGrLog( "  " )
AutoGrLog( "Data Final..........: " + Dtoc(MsDate()) )
AutoGrLog( "Hora Final...........: " + Time() )

cFileLog := NomeAutoLog()

If cFileLog <> ""
	nX := 1
	While .t.
		If File( Lower( '\spool\' + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) ) // El directorio debe estar creado en el servidor bajo DATA
			nX++
			If nX == 999
				Exit
			EndIf
			Loop
		Else
			Exit
		EndIf
	EndDo
	__CopyFile( cPath + Alltrim( cFileLog ), Lower( '\spool\' + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) )
	MostraErro(cPath,cFileLog)
	FErase( cFileLog )
Endif

Return

/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n     ³          ³ Autor ³                     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripci¢n ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TudoOk()
Local nHnd

nOpca := 1

Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n     ³          ³ Autor ³                     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripci¢n ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Str2Array( cString, cSep )

Local aReturn := { },;
cAux    := cString,;
nPos    := 0,;
nVirg   := 0

While At( cSep, cAux ) > 0
	nPos  := At( cSep, cAux )
	cVal  := SubStr( cAux, 1, nPos-1 )
	nVirg := at(",",cVal)
	if nVirg > 0
		cVal := substr(cVal,1,nVirg-1)+"."+substr(cVal,nVirg+1,len(cVal))
	endif
	Aadd( aReturn,  cVal )
	cAux  := SubStr( cAux, nPos+1 )
EndDo   

nVirg := at(",",cAux)
if nVirg > 0
	cAux := substr(cAux,1,nVirg-1)+"."+substr(cAux,nVirg+1,len(cAux))
endif

Aadd( aReturn, cAux )

Return( aReturn )
