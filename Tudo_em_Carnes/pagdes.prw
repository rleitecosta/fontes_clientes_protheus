#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function Pagdes()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Se houver desconto o sistema coloca a data limite para o desconto do contrario zerado.
//

SetPrvt("_DatDesc")

If SE2->E2_XDESCON <> 0  

	If AllTrim(SE2->E2_CODBAR) == ""

      	_DatDesc	:=	DTOS(SE2->E2_VENCTO)  	

	Else
	
		_DatDesc	:=	DtoS(DaySum(StoD('19971007'),Val(SubStr(SE2->E2_CODBAR,6,4))))//Calcula o vencimento original do boleto com base no Codigo de Barras
      //_DatVenc	:=	DTOS(SE2->E2_DATAAGE)  
	EndIf                         				

Else

	_DatDesc	:=	STRZERO(0,8)                                                    

EndIf

Return(_DatDesc)