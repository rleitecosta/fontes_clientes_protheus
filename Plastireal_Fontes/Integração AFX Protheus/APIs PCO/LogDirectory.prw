#INCLUDE 'TOTVS.CH'

#DEFINE FAIL_MESSAGE    'Directory creation fail - Error:'    
#DEFINE FAIL_CREATEFILE 'File creation fail - Error:'

/*/{Protheus.doc} LogDirectory
    Montagem dos niveis para gravação de log
    @type function
    @author Rodrigo dos Santos
    @since 06/11/2020
    @version P12
    @param cDir, caracter, primeiro nivel do diretorio
    @param cOperation, caracter, operação
    @param cFile, caracter, arquivo gerado
    @param cContent, caracter, conteudo do arquivo
    @param cFunction, caracter, nome da função que realizou a chamada
    @param cProcess, caracter, nome da processo que realizou a chamada
    @param cType, caracter, tipo de integração
    @return nil
    @obs github.com/rodrigomicrosiga
    @obs roana devops
    @obs javb code
    @obs www.blacktdn.com.br
/*/

User Function LogDirectory(cDir As Character, lOperation As Logical, cFile As Character, cContent As Character, cFunction As Character, cProcess As Character, cType As Character)
    Local nOK As Numeric

    Local lOK As Logical
    
    Default cDir        := ''
    Default lOperation  := .F.
    Default cFile       := ''
    Default cContent    := ''
    Default cFunction   := ''
    Default cProcess    := ''

    nOK   := 0

    lOK   := .F.           

    IF .NOT. lOperation
        IF .NOT. ExistDir(cDir)
            nOK := MakeDir(cDir)
            IF nOK <> 0
                conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
            ELSE
                nOK := MakeDir(cDir+cType+'\')
                IF nOK <> 0
                    conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
                ELSE
                    nOK := MakeDir(cDir+cType+'\'+'error\')
                    IF nOK <> 0
                        conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
                    ELSE
                        cDir := cDir+cType+'\error\'
                        lOK := MemoWrite(cDir+cFile,cContent)
                        IF .NOT. lOK
                            conout(cFunction+'-'+cProcess+'-'+FAIL_CREATEFILE+'-'+cValToChar(fError()))
                        EndIF
                    EndIF
                EndIF    
            EndIF
        ELSE
            cDir := cDir+cType+'\error\'
            IF .NOT. ExistDir(cDir)
                nOK := MakeDir(cDir)
                IF nOK <> 0
                    conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
                ELSE
                    lOK := MemoWrite(cDir+cFile,cContent)
                    IF .NOT. lOK
                        conout(cFunction+'-'+cProcess+'-'+FAIL_CREATEFILE+'-'+cValToChar(fError()))
                    EndIF
                EndIF
            ELSE
                lOK := MemoWrite(cDir+cFile,cContent)
                IF .NOT. lOK
                    conout(cFunction+'-'+cProcess+'-'+FAIL_CREATEFILE+'-'+cValToChar(fError()))
                EndIF
            EndIF
        EndIF
    ELSE
        IF .NOT. ExistDir(cDir)
            nOK := MakeDir(cDir)
            IF nOK <> 0
                conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
            ELSE
                nOK := MakeDir(cDir+cType+'\')
                IF nOK <> 0
                    conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
                ELSE
                    nOK := MakeDir(cDir+cType+'\'+'sucess\')
                    IF nOK <> 0
                        conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
                    ELSE
                        cDir := cDir+cType+'\sucess\'
                        lOK := MemoWrite(cDir+cFile,cContent)
                        IF .NOT. lOK
                            conout(cFunction+'-'+cProcess+'-'+FAIL_CREATEFILE+'-'+cValToChar(fError()))
                        EndIF
                    EndIF
                EndIF    
            EndIF
        ELSE
            cDir := cDir+cType+'\sucess\'
            IF .NOT. ExistDir(cDir)
                nOK := MakeDir(cDir)
                IF nOK <> 0
                    conout(cFunction+'-'+cProcess+'-'+FAIL_MESSAGE+'-'+cValToChar(fError()))
                ELSE
                    lOK := MemoWrite(cDir+cFile,cContent)
                    IF .NOT. lOK
                        conout(cFunction+'-'+cProcess+'-'+FAIL_CREATEFILE+'-'+cValToChar(fError()))
                    EndIF
                EndIF
            ELSE
                lOK := MemoWrite(cDir+cFile,cContent)
                IF .NOT. lOK
                    conout(cFunction+'-'+cProcess+'-'+FAIL_CREATEFILE+'-'+cValToChar(fError()))
                EndIF
            EndIF
        EndIF
    EndIF
Return()
