#include "totvs.ch"
procedure u_mt010can()
	local aParameter as array
	begin sequence
		if !(type("ParamIXB")=="A")
			break
		endif
		if (.F.)
			mt010can(aParameter)
		endif
	end sequence
	return

static procedure mt010can(aParameter as array)
	local nOPC	as numeric
	nOPC := aParameter[1]
	begin sequence
		if (nOPC==3)
			break
		endif
		if IsInCallStack("A010Inclui")
			u_MT010INC()
			break
		endif
		if IsInCallStack("A010Altera")
			u_MT010ALT()
			break
		endif
		if IsInCallStack("A010Deleta")
			u_MTA010OK()
			break
		endif
	end sequence
	return