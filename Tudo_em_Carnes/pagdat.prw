#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function Pagdat()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_DatVenc")

If AllTrim(SE2->E2_CODBAR) == ""

      _DatVenc	:=	DTOS(SE2->E2_VENCTO)  	

Else

      _DatVenc	:=	DtoS(DaySum(StoD('19971007'),Val(SubStr(SE2->E2_CODBAR,6,4))))//Calcula o vencimento original do boleto com base no Codigo de Barras
    //_DatVenc	:=	DTOS(SE2->E2_DATAAGE)  

EndIf

Return(_DatVenc)