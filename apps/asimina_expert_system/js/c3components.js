function c3_pivot(json, container, charttype, xaxis, originalCols, coltypes, groupcolumns)
{	
	c3_pivot(json, container, charttype, xaxis, originalCols, coltypes, groupcolumns, false);
}

function c3_pivot(json, container, charttype, xaxis, originalCols, coltypes, groupcolumns, iszoom)
{	
	var pivotedCols = originalCols - 1;
	var xy = {};

	for(var i=0;i<json.length;i=i+pivotedCols)
	{
		for(var k=i+1; k<i+pivotedCols; k++)
		{
			xy[json[k][0]] = json[i][0];
		}
	}

	c3_chart_load(json, container, charttype, xaxis, '', xy, coltypes, groupcolumns, iszoom);
}

function c3_chart_load(json, container, charttype, xaxis, categoryCol, timeseriesXY, coltypes, groupcolumns)
{
	c3_chart_load(json, container, charttype, xaxis, categoryCol, timeseriesXY, coltypes, groupcolumns, false);
}

function c3_chart_load(json, container, charttype, xaxis, categoryCol, timeseriesXY, coltypes, groupcolumns, iszoom)
{
	var groupCols = [];
	var c3chart = null;
	var _types = {};
	if(charttype == 'stackedbar')
	{
		var index=  0;
		groupCols[0] = [];
		for(var k=0; k<json.length;k++) 
		{
			if(json[k][0] != categoryCol) 
			{
				groupCols[0][index++] = json[k][0];
			}
		}
		charttype = 'bar';
	}

	else if(charttype == 'combination')
	{
		//by default for combination chart all columns will be shown as line
		charttype = 'line';
		if(coltypes != '')
		{
			var _s = coltypes.split(",");
			for(var u=0;u<_s.length;u++)
			{
				if(_s[u].indexOf(":") > -1) 
				{
					var _ss = _s[u].split(":");
					_types[_ss[0].toUpperCase()] = _ss[1];
				}
			}
		}
		groupCols = [];
		if(groupcolumns != '')
		{
			var _s = groupcolumns.split("#");
			for(var u=0;u<_s.length;u++)
			{
				var _ss = _s[u].split(",")
				groupCols[u] = [];
				for(var v=0;v<_ss.length;v++)
				{
					groupCols[u][v] = _ss[v].toUpperCase();
				}
			}
		}
	}

	if(xaxis == 'category')
	{
		c3chart = c3.generate({
			bindto: container,
			data: {
				x : categoryCol,
				columns: json,
				type: charttype,
				types : _types,
				groups: groupCols
			},
			axis: {x: {type: 'category'}},
			zoom: {
			        enabled: iszoom
			}	
		});
	}
	else if(xaxis == 'timeseries') 
	{
		c3chart = c3.generate({
			bindto: container,
			data: { 
				xs : timeseriesXY,
				xFormat: '%d/%m/%Y', 
				type: charttype, 
				types : _types,
				groups: groupCols,
				columns: json
			},
			axis: {x: {type: 'timeseries', tick: {format: '%d/%m/%Y'}}},
			zoom: {
			        enabled: iszoom
			}
		});
	}
	else
	{
		c3chart = c3.generate({
			bindto: container,
			data: {
				columns: json,
				type: charttype,
				types : _types,
				groups: groupCols
			},
			zoom: {
			        enabled: iszoom
			}
		});
	}
	if(groupCols) 
	{
//		c3chart.groups([groupCols]);
	}
}