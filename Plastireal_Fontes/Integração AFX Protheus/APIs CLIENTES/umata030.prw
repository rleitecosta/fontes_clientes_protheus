#include "totvs.ch"

class uMATA030 from tMATA030

	method New() constructor

	method Activate()
	method DeActivate()
	method OnError()

	method SetModel()
	method ClearModel()
	method SetName()
	method GetName()
	method SetAsXml()
	method SetAsJson()

	method StartGetFormat()
	method EscapeGetFormat()
	method EndGetFormat()

	method SetAlias()
	method GetAlias()
	method HasAlias()
	method Seek()
	method Skip()
	method Total()
	method GetData()
	method SaveData()
	method DelData()

	method SetFilter()
	method GetFilter()
	method ClearFilter()
	method DecodePK()
	method ConvertPK()

	method GetStatusResponse()
	method SetStatusResponse()

	method SetQueryString()
	method GetQueryString()
	method GetQSValue()
	method GetHttpHeader()
	method SetFields()
	method debuger()

endclass

method new() class uMATA030
	_Super:New()
	return

method Activate() class uMATA030
	return(_Super:Activate())

method DeActivate() class uMATA030
    return(_Super:DeActivate())

method OnError() class uMATA030
    return(_Super:OnError())

method SetModel(oModel) class uMATA030
    return(_Super:SetModel(@oModel))

method ClearModel() class uMATA030
    return(_Super:ClearModel())

method SetName(cName) class uMATA030
    return(_Super:SetName(@cName))

method GetName() class uMATA030
    return(_Super:GetName())

method SetAsXml() class uMATA030
    return(_Super:SetAsXml())

method SetAsJson() class uMATA030
    return(_Super:SetAsJson())

method StartGetFormat(nTotal,nCount,nStartIndex) class uMATA030
    return(_Super:StartGetFormat(@nTotal,@nCount,@nStartIndex))

method EscapeGetFormat() class uMATA030
    return(_Super:EscapeGetFormat())

method EndGetFormat() class uMATA030
    return(_Super:EndGetFormat())

method SetAlias(cAlias) class uMATA030
    return(_Super:SetAlias(cAlias))

method GetAlias() class uMATA030
    return(_Super:GetAlias())

method HasAlias() class uMATA030
    return(_Super:HasAlias())

method Seek(cPK) class uMATA030
    return(_Super:Seek(@cPK))

method Skip(nSkip) class uMATA030
    return(_Super:Skip(@nSkip))

method Total() class uMATA030
    return(_Super:Total())

method GetData(lFieldDetail,lFieldVirtual,lFieldEmpty,lFirstLevel,lInternalID) class uMATA030
    return(_Super:GetData(@lFieldDetail,@lFieldVirtual,@lFieldEmpty,@lFirstLevel,@lInternalID))

method SaveData(cPK,cData,cError) class uMATA030
    return(_Super:SaveData(@cPK,@cData,@cError))

method DelData(cPK,cError) class uMATA030
    return(_Super:DelData(@cPK,@cError))

method SetFilter(cFilter) class uMATA030
    return(_Super:SetFilter(cFilter))

method GetFilter() class uMATA030
    return(_Super:GetFilter())

method ClearFilter() class uMATA030
    return(_Super:ClearFilter())

method DecodePK() class uMATA030
    return(_Super:DecodePK())

method ConvertPK(cPK) class uMATA030
    return(_Super:ConvertPK(@cPK))

method GetStatusResponse() class uMATA030
    return(_Super:GetStatusResponse())

method SetStatusResponse(nStatus,cStatus) class uMATA030
    return(_Super:SetStatusResponse(@nStatus,@cStatus))

method SetQueryString(aQueryString) class uMATA030
    return(_Super:SetQueryString(@aQueryString))

method GetQueryString() class uMATA030
    return(_Super:GetQueryString())

method GetQSValue(cKey) class uMATA030
    return(_Super:GetQSValue(@cKey))

method GetHttpHeader(cParam) class uMATA030
    return(_Super:GetHttpHeader(@cParam))

method SetFields(aFields) class uMATA030
    return(_Super:SetFields(@aFields))

method debuger(lDebug) class uMATA030
    return(_Super:debuger(@lDebug))

function u_mata030()
	local xRet
	begin sequence
		if (!MA030IsMVC())
			break
		endif
		if (!type("ParamIXB")=="A")
			break
		endif
		xRet:=mata030(&("ParamIXB"))
	end sequence
	DEFAULT xRet:=.T.
	return(xRet)

static function mata030(aParameter as array)

    local cIdPonto		as character
    local cIdModel		as character

    local nOperation	as numeric

    local oObj			as object

	local xRet

	begin sequence

        oObj:=aParameter[1]
        cIdPonto:=aParameter[2]
        cIdModel:=aParameter[3]
        nOperation:=oObj:GetOperation()

        if (cIdPonto=="MODELPOS")
            if (nOperation==5)
            	xRet:=u_M030DEL()
            	break
            endif
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMPOS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMLINEPRE")
            if ((len(aParameter)>=5).and.(aParameter[5]=="DELETE"))
                xRet:=.T.
            endif
            break
        endif

        if (cIdPonto=="FORMLINEPOS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="MODELCOMMITTTS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="MODELCOMMITNTTS")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMCOMMITTTSPRE")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="FORMCOMMITTTSPOS")
            do case
            case (nOperation==3)
            	xRet:=u_M030INC()
            	break
            case (nOperation==4)
            	xRet:=u_M030PALT()
            	break
            case (nOperation==5)
            	xRet:=u_M030DEL()
            	break
            endcase
            xRet:=.T.
            break
        endif

        if (cIdPonto=="MODELCANCEL")
            xRet:=.T.
            break
        endif

        if (cIdPonto=="BUTTONBAR")
            xRet:=array(0)
            break
        endif

	end sequence

	return(xRet)