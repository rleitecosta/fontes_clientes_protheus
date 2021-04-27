#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function PagVal2()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALOR,")

_VALOR	:=	Replicate("0",15) 

//_VALOR	:=	StrZero((((SE2->E2_SALDO) - (SE2->E2_XDESCON)) + (SE2->E2_ACRESC))*100,15,0)  

_VALOR	:=	StrZero((((SE2->E2_SALDO) - (SE2->E2_XDESCON)) + (SE2->E2_ACRESC) + (SE2->E2_XJUROS))*100,15,0) //Incluído o campo E2_XJUROS - Cauê Poltronieri 08/05/2015   

Return(_VALOR)