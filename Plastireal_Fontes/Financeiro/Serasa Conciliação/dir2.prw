
User function dir2()

    Local cMascara  := "Arquivos de texto|*.txt"
    Local cTitulo   := "Salvar o arquivo"
    Local nMascpad  := nil
    Local cDirini   := nil
    Local lSalvar   := .F.                  /*.T. = Salva || .F. = Abre*/
    Local nOpcoes   := GETF_NETWORKDRIVE+GETF_LOCALHARD
    Local lArvore   := .F.                  /*.T. = apresenta o �rvore do servidor || .F. = n�o apresenta*/
    public cTargetDir := ""
 
    cTargetDir := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

Return !Empty(cTargetDir)

user Function retdir2()

Return(cTargetDir)