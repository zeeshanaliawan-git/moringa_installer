function montre( e )
{
  if(e) 
  {
	e.stopPropagation(true);
	e.preventDefault(true);
	var obj = e.target;	

//	if(obj.tagName.toUpperCase() == 'DIV' || obj.tagName.toUpperCase() == 'FOOTER' || obj.tagName.toUpperCase() == 'HEADER')
//	{
		if((obj.className).indexOf("dataExtract_Selected") > -1)
		{
			obj.className = obj.className.replace(new RegExp(" dataExtract_Selected\\b", "g"), "");
			var __id = obj['id'];
			if(__id != '') opener.removeSelectedSection(obj.tagName.toLowerCase()+"#id:"+obj['id']);
			else
			{
				var __cls = obj['className'];
				__cls = __cls.replace(new RegExp(" dataExtract_Selected\\b", "g"), "");
				__cls = __cls.replace(new RegExp(" dataExtract_highlight\\b", "g"), "");
				if(__cls != '') 
				{
					opener.removeSelectedSection(obj.tagName.toLowerCase()+"#class:"+__cls);
				}
			}
		}
		else
		{			
			var __id = obj['id'];
			var __cls = obj['className'];
			if(__id != '') 
			{
				opener.addSelectedSection(obj.tagName.toLowerCase()+"#id:"+obj['id']);
				obj.className += " dataExtract_Selected";
			}
			else if(__cls != '')
			{
				__cls = __cls.replace(new RegExp(" dataExtract_Selected\\b", "g"), "");
				__cls = __cls.replace(new RegExp(" dataExtract_highlight\\b", "g"), "");
				opener.addSelectedSection(obj.tagName.toLowerCase()+"#class:"+__cls);
				obj.className += " dataExtract_Selected";
			}
		}
//	}
   }   
}

document.oncontextmenu=montre;
