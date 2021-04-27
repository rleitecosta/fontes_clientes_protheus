#include "totvs.ch"
#include "tbiconn.ch"
#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "FWMVCDef.ch"

user function RegTit(cFil,cCliente,cLoja,cPrefixo,cNum,cParcela,cTipo) //parâmetros de SE1

    Local lRes          := .F.
    local cJSON         := ""
    Local cToken        := ""
    Local oBoleto 
    Local cHeadRet      := ""
    Local sPostRet      := ""
    Local aHeadOut      := {}
    Local aResConect    := {}
    Local oResJSON      := JSonObject():New()
    Local oResJSON2     := JSonObject():New()

    DBSelectArea("SE1")
    SE1->(dbSetOrder(2))
    SE1->(DBSeek(cFil+cCliente+cLoja+cPrefixo+cNum+cParcela+cTipo))

    if SE1->E1_XSTITAU == "1"           //Caso já registrado
        return .T.
    endif

    if SE1->(DBSeek(cFil+cCliente+cLoja+cPrefixo+cNum+cParcela+cTipo))
    
        cJSON               := GeraJSON1(cFil,cCliente,cLoja,cPrefixo,cNum,cParcela,cTipo)      //Gera JSON
        cJSON               := EncodeUTF8(cJSON, "cp1252")                                      //Codifica em UTF8
        aResConect          := BuscaToken()

        if aT('OK',aResConect[1]) > 0
            oResJSON:fromJson(aResConect[2])                                                    //cria JSON com filhos: token_type, access_token e expires_in
            cToken := oResJSON:GetJSonObject('access_token')
            
            aadd(aHeadOut,'Accept: application/vnd.itau')
            aadd(aHeadOut,'access_token: ' + cToken)
            aadd(aHeadOut,'itau-chave: 9a6a013b-54df-49a5-bf99-f674761f5775')   
            aadd(aHeadOut,'Content-Type: text/plain')
            
            oBoleto := FwRest():New("https://gerador-boletos.itau.com.br/router-gateway-app/public/codigo_barras/registro")
            oBoleto:SetPath("")
            oBoleto:SetPostParams(cJSON)    
            oBoleto:Post(aHeadOut)

            cHeadRet	:= oBoleto:GetLastError()
            sPostRet 	:= oBoleto:GetResult()                                                  //Recebe resposta da API
            sPostRet 	:= DecodeUTF8(sPostRet, "cp1252")                                       //Decodifica resposta da API

            // sPostRet = "{"beneficiario":{"codigo_banco_beneficiario":"341","digito_verificador_banco_beneficiario":"7","agencia_beneficiario":"5607","conta_beneficiario":"01575","digito_verificador_conta_beneficiario":"6","cpf_cnpj_beneficiario":"53234274000101","nome_razao_social_beneficiario":"PLASTIREAL IND COM PLAST LTDA","logradouro_beneficiario":"RUA FREDERICO ESTEBAN JUNIOR","bairro_beneficiario":"TREMEMBE","complemento_beneficiario":"","cidade_beneficiario":"SAO PAULO","uf_beneficiario":"SP","cep_beneficiario":"02357080"},"pagador":{"cpf_cnpj_pagador":"08289685000140","nome_razao_social_pagador":"INTERLASER IND COM DE PECAS E","logradouro_pagador":"R ARATIBA (COND C IND LIMEIRA), 448","complemento_pagador":"","bairro_pagador":"","cidade_pagador":"LIMEIRA","uf_pagador":"","cep_pagador":"13481208"},"sacador_avalista":{"cpf_cnpj_sacador_avalista":"00000000000000","nome_razao_social_sacador_avalista":""},"moeda":{"sigla_moeda":"R$","quantidade_moeda":0,"cotacao_moeda":0},"especie_documento":"DM","vencimento_titulo":"2020-10-22","tipo_carteira_titulo":"109","nosso_numero":"002867462","seu_numero":"","codigo_barras":"34194841600000081681090028674625607015756000","numero_linha_digitavel":"34191090082867462560470157560007484160000008168","local_pagamento":"ATE O VENCIMENTO PAGUE EM QUALQUER BANCO OU CORRESPONDENTE NAO BANCARIO. APOS O VENCIMENTO, ACESSE ITAU.COM.BR/BOLETOS E PAGUE EM QUALQUER BANCO OU CORRESPONDENTE NAO BANCARIO.","data_processamento":"2020-11-18","data_emissao":"2020-09-24","uso_banco":"","valor_titulo":81.68,"valor_desconto":0,"valor_outra_deducao":0,"valor_juro_multa":0,"valor_outro_acrescimo":0,"valor_total_cobrado":0,"lista_texto_informacao_cliente_beneficiario":[{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""},{"texto_informacao_cliente_beneficiario":""}]}"

            oResJSON2:fromJson(sPostRet)  
            cCodBar := oResJSON2:GetJsonObject("codigo_barras")
            cCodDig := oResJSON2:GetJsonObject("numero_linha_digitavel")

            if aT('OK',cHeadRet) > 0
                //Criar um campo E1_XSTITAU para armazenar se título está na cobrança
                RecLock("SE1",.F.)
                SE1->E1_XSTITAU := "1"                                                          //Grava situação do boleto (0=não registrado, 1=registrado)
                SE1->E1_PORTADO := "341"
                SE1->E1_AGEDEP := "5607"
                SE1->E1_CONTA := "01575"
                MsUnlock()
                lRes := .T.                                                                     //Flag de boleto registrado
                //armazenar dados de sPostRet
            else
                ConOut( "Não foi possível conectar com a API de registro de cobrança: "+cHeadRet+" "+sPostRet)
            endif

        else
            ConOut( "Não foi possível conectar com o Autorizador: "+aResConect[1]+" "+aResConect[2])
        endif
    endif

return lRes

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Função que busca o token da API
//------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function BuscaToken()
    Local oToken 
    Local cclient_id    := "GGNaUyV6kkJq0"  
    Local cclient_secret:= "68PIUzXHsmdHrn0TjdupKJ8HaYTQHtUpkv8Vjka-TQDsdED8t5_50yQxynyOhMBZ1VOtupKrhL0lm9maGuP_Eg2"
    Local cHeadRet      := ""
    Local sPostRet      := ""
    Local cAutentic     := Encode64(cclient_id + ":" + cclient_secret)      // formato client_id:client_secret codificados em Base64
    Local aHeadOut      := {}
    Local aRet

    aadd(aHeadOut,'Authorization: Basic ' + cAutentic)
    aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded')
    
    oToken := FwRest():New("https://oauth.itau.com.br/identity/connect/token")
    oToken:SetPath("")
    oToken:SetPostParams("scope=readonly&grant_type=client_credentials")    //formato do x-www-form-urlencoded: string com key=value separado por & . Exemplo: "scope=readonly&grant_type=client_credentials"
    oToken:Post(aHeadOut)

    cHeadRet	:= oToken:GetLastError()
    sPostRet 	:= oToken:GetResult()
    aRet        := {cHeadRet,sPostRet}

Return aRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Função que gera o JSON reduzido da API
//------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GeraJSON1(cFil,cCliente,cLoja,cPrefixo,cNum,cParcela,cTipo) //fil 0101 cliente 19381564 loja 0001 pref FAT Num 13436 Tipo NF
    Local aArea := GetArea()
	Local cJson := ''
    Local cCodigo
    Local cLojaCli
    Local cAgencia      := SUPERGETMV("FS_AGENBI",.F.)                              //Agência formato 9999                      "5607"
    Local cContaD       := SUPERGETMV("FS_CONTBI",.F.)                              //Conta formato 99999-9                     "01575-6"
    Local cConta        := StrZero(Val(SubStr(cContaD,1,AT("-",cContaD)-1)),7)      //                                          "01575"      tamanho 7 (zeros a esquerda)
    Local cDigVer       := SubStr(cContaD,AT("-",cContaD)+1)                        //                                          "6"        
    Local cCPF          := SUPERGETMV("FS_CNPJBI",.F.)                              //CPF formato 99999999999999                "53234274000101"
    Local cCarteira     := SUPERGETMV("FS_CARITAU",.F.)                             //Carteira                                  "109"
    Local cEspecie      := SUPERGETMV("FS_ESPITAU",.F.)                             //Espécie                                   "01" 

    Local cTPag         := SUPERGETMV("FS_TPITAU",.F.)                              //FS_TPITAU                                 3=Com data de vencimento
    Local cIPP          := SUPERGETMV("FS_IPPITAU",.F.)                             //FS_IPPITAU                                true=aceita false=não aceita
    Local cJuros        := SUPERGETMV("FS_JURITAU",.F.)                             //FS_JURITAU                                5
    Local cMulta        := SUPERGETMV("FS_MULITAU",.F.)                             //FS_MULITAU                                3
    Local cDesconto     := SUPERGETMV("FS_TDEITAU",.F.)                             //FS_TDEITAU                                0
    Local cTAR          := SUPERGETMV("FS_TARITAU",.F.)                             //FS_TARITAU                                1
    Local cNosNu8P             //1128 05661207   
    
    cNosNu8P      := "1"+RIGHT(SE1->E1_NUM,7) 

    DBSelectArea("SE1")
    DBSetOrder(2)
    DBSeek(xFilial("SE1")+cCliente+cLoja+cPrefixo+cNum+cParcela+cTipo)     //E1_NUM = 13430 - E1_NUMBCO = 318

    cCodigo := SE1->E1_CLIENTE
    cLojaCli   := SE1->E1_LOJA

    DBSelectArea("SA1")
    DBSetOrder(1)
    DBSeek(xFilial("SA1")+cCodigo+cLojaCli)            //cpath agenda

    cJson += '{'+CRLF
    cJson += '    "tipo_ambiente": 2,'+CRLF                                                                     //1=teste 2=produção Fixo
    cJson += '    "tipo_registro": 1,'+CRLF                                                                     //cadastro Fixo
    cJson += '    "tipo_cobranca": 1,'+CRLF                                                                     //boleto Fixo
    cJson += '    "tipo_produto": "00006",'+CRLF                                                                //cliente Fixo
    cJson += '    "subproduto": "00008",'+CRLF                                                                  //cliente Fixo
    cJson += '    "beneficiario": {'+CRLF                       
    cJson += '                    "cpf_cnpj_beneficiario": "' +cCPF+ '",'+CRLF                                  //Fixo 
    cJson += '                    "agencia_beneficiario": "' +cAgencia+ '",'+CRLF                               //Fixo
    cJson += '                    "conta_beneficiario": "' +cConta+ '",'+CRLF                                   //Fixo
    cJson += '                    "digito_verificador_conta_beneficiario": "' +cDigVer+ '"'+CRLF                //Fixo
    cJson += '                    },'+CRLF                      
    cJson += '    "titulo_aceite": "S",'+CRLF                                                                   //S=Cobrança N=Proposta
    cJson += '    "pagador":      {'
    if SA1->A1_PESSOA == 'F'                        
        cJson += '                    "cpf_cnpj_pagador": "' +Padr(SA1->A1_CGC,11)+ '",'+CRLF                   // SA1->A1_CGC (CPF)
    else
        cJson += '                    "cpf_cnpj_pagador": "' +Padr(SA1->A1_CGC,14)+ '",'+CRLF                   // SA1->A1_CGC (CNPJ)
    endif
    cJson += '                    "nome_pagador": "' +Padr(SA1->A1_NOME,30)+ '",'+CRLF                          //E1_NOMCLI
    cJson += '                    "logradouro_pagador": "' +Padr(SA1->A1_END,40)+ '",'+CRLF                     //A1_END
    cJson += '                    "cidade_pagador": "' +Padr(SA1->A1_MUN,20)+ '",'+CRLF                         //A1_MUN
    cJson += '                    "uf_pagador": "' +SA1->A1_EST+ '",'+CRLF                                      //A1_EST
    cJson += '                    "cep_pagador": "' +SA1->A1_CEP+ '"'+CRLF                                      //A1_CEP
    cJson += '                    },'+CRLF
    cJson += '    "tipo_carteira_titulo": "' +cCarteira+ '",'+CRLF                                              //definida pela Alper
    cJson += '    "moeda":        {'+CRLF                       
    cJson += '                    "codigo_moeda_cnab": "09"'+CRLF                                               //Real fixo
    cJson += '                    },'+CRLF 
    cJson += '    "nosso_numero": "' +cNosNu8P+ '",'+CRLF                                                       //Nosso número = SE1_E1NUMBCO
    cJson += '    "digito_verificador_nosso_numero": "' +DigVeri(cAgencia,cConta,cCarteira,cNosNu8P)+ '",'+CRLF //????
    cJson += '    "data_vencimento": "' +StrZero(Year(SE1->E1_VENCREA),4)+ '-' +StrZero(Month(SE1->E1_VENCREA),2)+ '-' +StrZero(Day(SE1->E1_VENCREA),2)+ '",'+CRLF //E1_VENCREA convertido para YYYY-MM-DD
    cJson += '    "valor_cobrado": "' +StrTran(strzero(SE1->E1_VALOR,18,2),'.','')+ '",'+CRLF                   //E1_VALOR convertido para 99999999999999900 (9=Digito inteiro 0=Casa decimal)
    cJson += '    "seu_numero": "'alert(val(alltrim(cNum)))'",' +CRLF                                           //número do título
    cJson += '    "especie": "' +cEspecie+ '",'+CRLF                                                                        //Algumas opções
    cJson += '    "data_emissao": "' +StrZero(Year(SE1->E1_EMISSAO),4)+ '-' +StrZero(Month(SE1->E1_EMISSAO),2)+ '-' +StrZero(Day(SE1->E1_EMISSAO),2)+ '",'+CRLF     //E1_EMISSAO convertido para YYYY-MM-DD
    cJson += '    "tipo_pagamento": ' +cTPag+','+CRLF                                                           //FS_TPITAU                                         //3=Com data de vencimento
    cJson += '    "indicador_pagamento_parcial": "' +cIPP+ '",' +CRLF                                           //FS_IPPITAU                                        //true=aceita false=não aceita
    cJson += '    "juros":        {'+CRLF                       
    cJson += '                    "tipo_juros": ' +cJuros+CRLF                                                  //FS_JURITAU                                        //5
    cJson += '                    },'+CRLF                      
    cJson += '    "multa":        {'+CRLF                       
    cJson += '                    "tipo_multa": ' +cMulta+CRLF                                                  //FS_MULITAU                                        //3
    cJson += '                    },'+CRLF                      
    cJson += '    "grupo_desconto":   [{'+CRLF                      
    cJson += '                        "tipo_desconto": ' +cDesconto+CRLF                                        //FS_TDEITAU                                        //0
    cJson += '                        }],'+CRLF                     
    cJson += '    "recebimento_divergente":   {'+CRLF                       
    cJson += '                                "tipo_autorizacao_recebimento": "' +cTAR+ '"'+CRLF                //FS_TARITAU                      //vários tipos parâmetro?
    cJson += '                                }'+CRLF
    cJson += '}'

    RestArea(aArea)
Return cJson

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Função que gera o JSON completo da API
//------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static Function GeraJSON2()
	Local cJson := ''

    cJson += '     {'+CRLF
    cJson += '        "tipo_ambiente": 1,' +CRLF                                           //1=teste 2=produção
    cJson += '        "tipo_registro": 1,' +CRLF                                           //1=Para registro fixo
    cJson += '        "tipo_cobranca": 1,' +CRLF                                           //1=Para boletos fixo
    cJson += '        "tipo_produto": "00006",' +CRLF                                      //00006=Cliente
    cJson += '        "subproduto": "00008",' +CRLF                                        //00008=Cliente
    cJson += '        "beneficiario": {' +CRLF
    cJson += '            "cpf_cnpj_beneficiario": "12345678000100",' +CRLF
    cJson += '            "agencia_beneficiario": "1500",' +CRLF
    cJson += '            "conta_beneficiario": "0005206",' +CRLF
    cJson += '            "digito_verificador_conta_beneficiario": "1"' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "debito": {' +CRLF
    cJson += '            "agencia_debito": "",' +CRLF
    cJson += '            "conta_debito": "",' +CRLF
    cJson += '            "digito_verificador_conta_debito": ""' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "identificador_titulo_empresa": "",' +CRLF
    cJson += '        "uso_banco": "",' +CRLF
    cJson += '        "titulo_aceite": "S",' +CRLF
    cJson += '        "pagador": {' +CRLF
    cJson += '            "cpf_cnpj_pagador": "000012345678910",' +CRLF
    cJson += '            "nome_pagador": "PAGADORVIAAPI",' +CRLF
    cJson += '            "logradouro_pagador": "RUADOPAGADOR",' +CRLF
    cJson += '            "bairro_pagador": "BAIRRO",' +CRLF
    cJson += '            "cidade_pagador": "CIDADE",' +CRLF
    cJson += '            "uf_pagador": "SP",' +CRLF
    cJson += '            "cep_pagador": "00000000",' +CRLF
    cJson += '            "grupo_email_pagador": [' +CRLF
    cJson += '                                    {' +CRLF
    cJson += '                                        "email_pagador": ""' +CRLF
    cJson += '                                    }' +CRLF
    cJson += '            ]' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "sacador_avalista": {' +CRLF
    cJson += '            "cpf_cnpj_sacador_avalista": "000012345678900",' +CRLF
    cJson += '            "nome_sacador_avalista": "SACADORAVALISTA",' +CRLF
    cJson += '            "logradouro_sacador_avalista": "ENDERECOSACADORAVALISTA",' +CRLF
    cJson += '            "bairro_sacador_avalista": "BAIRRO",' +CRLF
    cJson += '            "cidade_sacador_avalista": "CIDADE",' +CRLF
    cJson += '            "uf_sacador_avalista": "SP",' +CRLF
    cJson += '            "cep_sacador_avalista": "00000000"' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "tipo_carteira_titulo": "109",' +CRLF
    cJson += '        "moeda": {' +CRLF
    cJson += '            "codigo_moeda_cnab": "09",' +CRLF
    cJson += '            "quantidade_moeda": ""' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "nosso_numero": "12345678",' +CRLF
    cJson += '        "digito_verificador_nosso_numero": "1",' +CRLF
    cJson += '        "codigo_barras": "02020202020202020202020202020202020202020202",' +CRLF
    cJson += '        "data_vencimento": "2016-12-31",' +CRLF
    cJson += '        "valor_cobrado": "00000000000015000",' +CRLF
    cJson += '        "seu_numero": "1234567890",' +CRLF
    cJson += '        "especie": "01",' +CRLF
    cJson += '        "data_emissao": "2016-11-21",' +CRLF
    cJson += '        "data_limite_pagamento": "2016-12-31",' +CRLF
    cJson += '        "tipo_pagamento": 3,' +CRLF
    cJson += '        "indicador_pagamento_parcial": "false",' +CRLF
    cJson += '        "quantidade_pagamento_parcial": "0",' +CRLF
    cJson += '        "quantidade_parcelas": "0",' +CRLF
    cJson += '        "instrucao_cobranca_1": "",' +CRLF
    cJson += '        "quantidade_dias_1": "",' +CRLF
    cJson += '        "data_instrucao_1": "",' +CRLF
    cJson += '        "instrucao_cobranca_2": "",' +CRLF
    cJson += '        "quantidade_dias_2": "",' +CRLF
    cJson += '        "data_instrucao_2": "",' +CRLF
    cJson += '        "instrucao_cobranca_3": "",' +CRLF
    cJson += '        "quantidade_dias_3": "",' +CRLF
    cJson += '        "data_instrucao_3": "",' +CRLF
    cJson += '        "valor_abatimento": "10",' +CRLF
    cJson += '        "juros": {' +CRLF
    cJson += '            "data_juros": "",' +CRLF
    cJson += '            "tipo_juros": 5,' +CRLF
    cJson += '            "valor_juros": "",' +CRLF
    cJson += '            "percentual_juros": ""' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "multa": {' +CRLF
    cJson += '            "data_multa": "",' +CRLF
    cJson += '            "tipo_multa": 3,' +CRLF
    cJson += '            "valor_multa": "",' +CRLF
    cJson += '            "percentual_multa": ""' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "grupo_desconto": [' +CRLF
    cJson += '                            {' +CRLF
    cJson += '                                "data_desconto": "2016-10-10",' +CRLF
    cJson += '                                "tipo_desconto": 2,' +CRLF
    cJson += '                                "valor_desconto": "",' +CRLF
    cJson += '                                "percentual_desconto": "10"' +CRLF
    cJson += '                            }' +CRLF
    cJson += '        ],' +CRLF
    cJson += '        "recebimento_divergente": {' +CRLF
    cJson += '            "tipo_autorizacao_recebimento": "3",' +CRLF
    cJson += '            "tipo_valor_percentual_recebimento": "",' +CRLF
    cJson += '            "valor_minimo_recebimento": "",' +CRLF
    cJson += '            "percentual_minimo_recebimento": "",' +CRLF
    cJson += '            "valor_maximo_recebimento": "",' +CRLF
    cJson += '            "percentual_maximo_recebimento": ""' +CRLF
    cJson += '        },' +CRLF
    cJson += '        "grupo_rateio": []' +CRLF
    cJson += '    }'
	
Return cJson

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Função que gera o dígito verificador do nosso número
//------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function DigVeri(cAgencia,cConta,cCarteira,cNosNu8P)  //5607 0001575 109 ********
Local cString := cAgencia+cConta+cCarteira+cNosNu8P
Local aPesos  := array(Len(cString))
Local aString := {}
Local i,j,k,l
Local cRes := ""
Local nRes := 0
Local nPeso := 1

for l=len(cString) to 1 step -1                                 //cosntroi o vetor de pesos : 121212121212
    if nPeso == 1
        nPeso := 2
        aPesos[l] :=  nPeso
    else
        nPeso := 1
        aPesos[l] :=  nPeso
    endif
    
next

for i=len(cString) to 1 step -1                                 //constroi o vetor de multiplicação do valor pelos pesos
    aadd(aString,val(SubStr(cString,i,1))*aPesos[i])
next

for j=1 to len(aString)                                         //transforma o vetor em string de novo
    cRes += Str(aString[j])
next

for k=1 to len(cRes)                                            //soma o os dígitos da string                                     
    nRes += val(SubStr(cRes,k,1))
next

if mod(nRes,10) == 0                                            //obtem 10 - resto
    cRes := "0"
else
    cRes := alltrim(str(10 - mod(nRes,10)))
endif

return cRes