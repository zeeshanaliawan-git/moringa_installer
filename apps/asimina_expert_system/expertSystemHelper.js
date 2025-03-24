function _expertSystemHelperFunctions(func, val, otherParams)
{
	switch (func)
	{
		case 'day' : 
			var __d = "";				
			if(val != '' && val.length >=2) 
			{
				__d = val.substring(0,2);
				if(parseInt(__d) < 1 || parseInt(__d) > 31) return "";
			}
			return ""+parseInt(__d);
		case 'month' : 
			var __m = "";
			if(val != '' && val.length >=5) 
			{
				__m = val.substring(3,5);
				if(parseInt(__m) < 1 || parseInt(__m) > 12) return "";
			}
			return ""+parseInt(__m);
		case 'year' : 
			var __y = "";
			if(val != '' && val.length >=10) 
			{
				__y = val.substring(6,10);
			}
			return ""+parseInt(__y);
		case 'eval' : 
			return eval(val);
		case 'substring' : 
			var __s = '';
			if(otherParams == "" || otherParams.indexOf(",") < 0) return "";
			var p1 = otherParams.substring(0, otherParams.indexOf(","));
			var p2 = otherParams.substring(otherParams.indexOf(",") + 1);
			if(p1.indexOf(".length") > -1) 
			{
				var _temp = $.trim(p1.substring(p1.indexOf(".length")+7));
				p1 = parseInt(val.length);

				if(_temp.indexOf("+") > -1)
				{
					_temp = parseInt(_temp.substring(_temp.indexOf("+") + 1));
					p1 = p1 + _temp;
				}			
				else if(_temp.indexOf("-") > -1)
				{
					_temp = parseInt(_temp.substring(_temp.indexOf("-") + 1));
					p1 = p1 - _temp;
				}
			}
			if(p2.indexOf(".length") > -1) 
			{
				var _temp = $.trim(p2.substring(p2.indexOf(".length")+7));
				p2 = parseInt(val.length);

				if(_temp.indexOf("+") > -1)
				{
					_temp = parseInt(_temp.substring(_temp.indexOf("+") + 1));
					p2 = p2 + _temp;
				}			
				else if(_temp.indexOf("-") > -1)
				{
					_temp = parseInt(_temp.substring(_temp.indexOf("-") + 1));
					p2 = p2 - _temp;
				}			
			}
			__s = val.substring(p1,p2);
			return __s;
		default : return val;
	}			
}

function prevPage(pageSize, rowClass)
{ 
	var pno = parseFloat($("#"+rowClass+"_pageno").val());
	if(pno == 0) return;
	showPage(pno -1, pageSize, rowClass);
}

function nextPage(pageSize, rowClass)
{ 
	var pno = parseFloat($("#"+rowClass+"_pageno").val());
	showPage(pno + 1, pageSize, rowClass);
}

function showPage(pageNum, pageSize, rowClass)
{ 
	var _st = parseFloat(pageNum) * parseFloat(pageSize);
	var _et = _st + parseFloat(pageSize);
	if(_st >= $("." + rowClass).length) return;
	$("." + rowClass).each(function(){
		var _id = this.id;
		_id = _id.substring(_id.lastIndexOf("_")+1);
		$(this).hide();
		if(parseFloat(_id) >= _st && parseFloat(_id) < _et) $(this).show();
	});
	$("#"+rowClass+"_pageno").val(pageNum);
	showPagination(pageSize, rowClass); 
}

function showPagination(pageSize, rowClass)
{
// 	$("#"+ rowClass + "_pagination").css({fontSize:10});
 	$("#"+ rowClass + "_pagination").addClass("es_pagination");

	var records = parseFloat($("." + rowClass).length);
	if(records > pageSize)
	{
		var totalPages = parseInt(records/pageSize);
		if(records % pageSize > 0) totalPages ++;
		var currentPage = parseInt($("#"+rowClass+"_pageno").val());
		var _txt = "<a class=\"es_page\" href=\"javascript:prevPage("+pageSize+",'"+rowClass+"')\"><</a>&nbsp;&nbsp;";

		if(currentPage == 0 ) _txt += "<span class=\"es_current_page\">1</span>&nbsp;&nbsp;";
		else _txt += "<a class=\"es_page\" href=\"javascript:showPage(0,"+pageSize+",'"+rowClass+"')\">1</a>&nbsp;&nbsp;";

		var plusminus = 2;
		var plus = plusminus;
		var minus = plusminus;
		if(currentPage - plusminus < 0) 
		{
			plus = plusminus + parseInt(((currentPage - plusminus) * -1));
			minus = parseInt(((currentPage - plusminus) * -1));
		}
		else if(currentPage + plusminus > parseInt(totalPages))
		{
			minus = plusminus + parseInt(((totalPages - (currentPage + plusminus)) * -1));
			plus = parseInt(((totalPages - (currentPage + plusminus)) * -1));
		}

		var addStartSpace = 0;
		var addEndSpace = 0;

		var _innertxt = "";
		for(var i=1; i<totalPages-1; i++)
		{
			if( i < (currentPage-minus)) addStartSpace ++;
			if( i >= (currentPage-minus) && i <= (currentPage + plus))
			{
				if($("#"+rowClass+"_pageno").val() == i ) _innertxt += "<span class=\"es_current_page\">"+ (i+1) + "</span>&nbsp;&nbsp;";
				else _innertxt += "<a class=\"es_page\" href=\"javascript:showPage("+i+","+pageSize+",'"+rowClass+"')\">" + (i+1) + "</a>&nbsp;&nbsp;";
			}
			if( i > (currentPage+plus)) addEndSpace ++;
		}
		if(addStartSpace > 0) _innertxt = "...&nbsp;&nbsp;" + _innertxt;
		if(addEndSpace > 0) _innertxt += "...&nbsp;&nbsp;";

		_txt += _innertxt;

		if(currentPage == totalPages-1 ) _txt += "<span class=\"es_current_page\">"+ totalPages + "</span>&nbsp;&nbsp;";
		else _txt += "<a class=\"es_page\" href=\"javascript:showPage("+(totalPages-1)+","+pageSize+",'"+rowClass+"')\">" + totalPages + "</a>&nbsp;&nbsp;";

		_txt += "<a class=\"es_page\" href=\"javascript:nextPage("+pageSize+",'"+rowClass+"')\">></a>";
		_txt += "<br/><span class=\"es_pagination_records\">Total records : " + records + "</span>";
		$("#"+ rowClass + "_pagination").html(_txt);
	}
	else
	{
		$("#"+ rowClass + "_pagination").html("<span class=\"es_current_page\">1</span><br/><span class=\"es_pagination_records\">Total records : " + records + "</span>");
	}
}

