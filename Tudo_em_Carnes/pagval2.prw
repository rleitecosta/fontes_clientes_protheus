#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function PagVal2()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_VALOR,")

_VALOR	:=	Replicate("0",15) 

//_VALOR	:=	StrZero((((SE2->E2_SALDO) - (SE2->E2_XDESCON)) + (SE2->E2_ACRESC))*100,15,0)  

_VALOR	:=	StrZero((((SE2->E2_SALDO) - (SE2->E2_XDESCON)) + (SE2->E2_ACRESC) + (SE2->E2_XJUROS))*100,15,0) //Inclu�do o campo E2_XJUROS - Cau� Poltronieri 08/05/2015   

Return(_VALOR)