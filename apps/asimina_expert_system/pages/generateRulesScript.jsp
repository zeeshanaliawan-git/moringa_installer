<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map, java.io.*"%>
<%@ page import="java.util.LinkedHashMap, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>

<%!

	class Rule
	{
       	String outputTag;
	       String outputVal;
       	String outputType;        
	     	List<Condition> conditions;
		String htmlTagId = "";
   	}
    
	class Condition
	{
       	String jsonTag;
	       String operator;
       	String value;
		String intraConditionOp = "";
		String valueType;
		String sourceFunc;
		String targetFunc;
		String sourceParams;
		String targetParams;
	}

	String getJson(Map<String, String> nodes)
	{
		if (nodes.size() == 0) return "";
		String s = "";
		for(String key : nodes.keySet())
		{
			s += key + nodes.get(key) + ".";
		}
		s = s.substring(0, s.lastIndexOf("."));
		return s;
	}

	String getJsonForArray(Map<String, String> nodes)
	{
		if (nodes.size() == 0) return "";
		String s = "";
		String previousTagArrayVariable = "";

		int i=0;
		for(String key : nodes.keySet())
		{
			i++;
			if(i == nodes.keySet().size()) s += key + ".";
			else  s += key + nodes.get(key) + ".";
		}
		s = s.substring(0, s.lastIndexOf("."));
		return s;
	}

	String getSourceJsonTagsExists(Map<String, String> parentNodes)
	{
		String _json = "";
		String allJsonTags = "";

		String curTag = "";
		String previousTagArrayVariable = "";
		int i=0;
		for(String key : parentNodes.keySet())
		{
			if(i++ > 0) curTag = curTag + previousTagArrayVariable + "." + key;
			else curTag = key;

			allJsonTags += curTag + " && ";
			if(!parentNodes.get(key).trim().equals("")) //means the tag was an array
				previousTagArrayVariable = parentNodes.get(key);
			else previousTagArrayVariable = "";		
		}
		
		if(allJsonTags.length() >  0) allJsonTags = allJsonTags.substring(0, allJsonTags.length() - 3);
		return allJsonTags;
	}

	String getAllTags(List<String> tags)
	{
		String allJsonTags = "";
		for(int j=tags.size()-1; j > -1; j--) 
		{
			allJsonTags += tags.get(j) + " && ";
		}
		return allJsonTags;
	}


	/* 
	* This function generates the condition of source tag matching target tag. Target tag can itself be array (or array of arrays.. handled till nth level)
	* If the target tag is simply a value, then we just compare the source tag (and its property given in condition) with that value and set the corresponding 'variable'	
	* in javascript to true
	* If the target tag is itself a Tag, then it can either be a simple tag or array. If its a simple tag then source tag property is compared to target tag property and 'variable'
	* is set to true in javascript
	* If the target tag itself is an array (or array of arrays), then we have to generate for loop(s) for each array in the target tag. And then compare the source tag property to the
	* final tags/value in target array and set 'variable' in javascript to true
	* 'variable' is basically a var defined in output javascript with default value to false. If the condition meets its value will be set to true.
	* If there are multiple conditions in a rule, each condition will have its corresponding 'variable' to be set to true and then all those variables are checked with intra condition
	* operator defined in the rule
	*/

	String getConditionCode(String json, String prop, String operator, String val, String variable, String valueType, String sourceFunc, String targetFunc, String sourceParams, String targetParams)
	{
		String  s = "";

		if(json.contains("EXPSYS_SPECIAL_COL_"))
		{
//System.out.println(json);
			String _index = json.substring(json.indexOf(".EXPSYS_SPECIAL_COL_") + 20);
			json = json.substring(0, json.indexOf(".EXPSYS_SPECIAL_COL_"));
			json += "[" + _index + "]";
//System.out.println(json);
		}
		if(valueType.equals("V"))
		{
			if(!prop.equals("value")) s = json + "." + prop ;
			else s = "(''+"+json+")"+".toLowerCase()" ;

			s = "_expertSystemHelperFunctions('"+sourceFunc+"'," + s + ", '"+sourceParams+"') ";

			val = val.toLowerCase();
			if(operator.equalsIgnoreCase("EQUALS")) s += " == '" + val + "' ";
			else if(operator.equalsIgnoreCase("NOT_EQUALS")) s += " != '" + val + "' ";
			else if(operator.equalsIgnoreCase("CONTAINS")) s += ".indexOf(\""+val+"\") > -1";
			else if(operator.equalsIgnoreCase("STARTS")) s += ".match(/^"+val+"/)"; 
			else if(operator.equalsIgnoreCase("ENDS")) s += ".match(/"+val+"$/)"; 
			else if(operator.equalsIgnoreCase("GREATER")) s += " > " + val;
			else if(operator.equalsIgnoreCase("LESSER")) s += " < " + val;
			else if(operator.equalsIgnoreCase("GREATER_EQUALS")) s += " >= " + val;
			else if(operator.equalsIgnoreCase("LESSER_EQUALS")) s += " <= " + val;
		
						
			ArrayList<String> tags = new ArrayList<String>();

			String _json = json;
			tags.add(_json);
			while(_json.indexOf(".") > -1)
			{
				_json = _json.substring(0, _json.lastIndexOf("."));
				tags.add(_json);
			}
		
			String allJsonTags = getAllTags(tags);
//				allJsonTags += tags.get(j) + " && ";
			
			s = "\t\t\tif(" +allJsonTags+ " " +s+ ")\n\t\t\t{\n";
			s += "\t\t\t\t"+variable + " = true;\n";	
			s += "\t\t\t}\n";
		}
		else if(valueType.equals("T"))
		{
			if(!prop.equals("value")) s = json + "." + prop;
//			else s = json+".toLowerCase()";
			else s = "(''+"+json+")"+".toLowerCase()" ;

			s = "_expertSystemHelperFunctions('"+sourceFunc+"'," + s + ", '"+sourceParams+"') ";

			String _matchingTag = val.substring(0, val.lastIndexOf("."));
			_matchingTag = "_json." + _matchingTag;

			String[] matchingTags = _matchingTag.split("\\.");            
			String matchingProp = val.substring(val.lastIndexOf(".") + 1);

			if(!_matchingTag.contains("[*]"))//simple case where no arrays are involved in json
			{
				String s2 = "";
				if(!matchingProp.equals("value")) s2 = _matchingTag + "." + matchingProp;
//				else s2 = _matchingTag +".toLowerCase()";
				else s2 = "(''+"+_matchingTag+")"+".toLowerCase()" ;

				s2 = "_expertSystemHelperFunctions('"+targetFunc+"'," + s2 + ", '"+targetParams+"') "; 

				if(operator.equalsIgnoreCase("EQUALS")) s += " == " + s2 + " ";
				else if(operator.equalsIgnoreCase("NOT_EQUALS")) s += " != " + s2 + " ";
				else if(operator.equalsIgnoreCase("CONTAINS")) s += ".indexOf("+s2+") > -1";
				else if(operator.equalsIgnoreCase("STARTS")) s += ".match(/^"+s2+"/)"; 
				else if(operator.equalsIgnoreCase("ENDS")) s += ".match(/"+s2+"$/)"; 
				else if(operator.equalsIgnoreCase("GREATER")) s += " > " + s2;
				else if(operator.equalsIgnoreCase("LESSER")) s += " < " + s2;
				else if(operator.equalsIgnoreCase("GREATER_EQUALS")) s += " >= " + s2;
				else if(operator.equalsIgnoreCase("LESSER_EQUALS")) s += " <= " + s2;

				ArrayList<String> tags = new ArrayList<String>();

				String _json = _matchingTag;
				tags.add(_json);
				while(_json.indexOf(".") > -1)
				{
					_json = _json.substring(0, _json.lastIndexOf("."));
					tags.add(_json);
				}

				_json = json;
				tags.add(_json);
				while(_json.indexOf(".") > -1)
				{
					_json = _json.substring(0, _json.lastIndexOf("."));
					tags.add(_json);
				}
			
				String allJsonTags = getAllTags(tags);
//				for(int j=tags.size()-1; j > -1; j--)
//					allJsonTags += tags.get(j) + " && ";
			
				s = "\t\t\tif(" +allJsonTags+ " " +s+ ")\n\t\t\t{\n";
				s += "\t\t\t\t" + variable + " = true;\n";	
				s += "\t\t\t}\n";			

			}
			else
			{
				String output = "";
				String endingBrackets = "";

				ArrayList<String> tags = new ArrayList<String>();

				String _json = json;
				tags.add(_json);
				while(_json.indexOf(".") > -1)
				{
					_json = _json.substring(0, _json.lastIndexOf("."));
					tags.add(_json);
				}
			
				String allJsonTags = getAllTags(tags);
//				for(int j=tags.size()-1; j > -1; j--)
//					allJsonTags += tags.get(j) + " && ";
			
				output = "\t\t\tif(" +allJsonTags+ " 1 == 1)\n\t\t\t{\n"; //just adding 1=1 as we added && at last in allJsonTags

				String s3 = _matchingTag;

				int arrayCount = 0;//arrayCount actually holds the number of arrays which is basically used to define var m<arrayCount> in js for each array
				ArrayList<String> parentTags = new ArrayList<String>();//this will hold all array tags having [*] at the end
				while(	s3.indexOf("[*]") > -1)//for all arrays in target tag we have to generate for loops in js
				{
					if(s3.startsWith(".")) s3 = s3.substring(1);

					String parentJson = "";
		
					int curArrayCount = parentTags.size() -1;
					for(int p=parentTags.size()-1;p>-1;p--) parentJson  = parentTags.get(p) + "[m"+(curArrayCount--)+"]." + parentJson; 

					String curTag = s3.substring(0, s3.indexOf("[*]"));
					parentTags.add(curTag);

					if(!parentJson.equals("")) curTag = parentJson + curTag;

					_json = curTag;

					tags.clear();
					tags.add(_json);
					while(_json.indexOf(".") > -1)
					{
						_json = _json.substring(0, _json.lastIndexOf("."));
						tags.add(_json);
					}
					allJsonTags = getAllTags(tags);
//					for(int j=tags.size()-1; j > -1; j--)
//						allJsonTags += tags.get(j) + " && ";
				
					output += "\t\t\tif(" +allJsonTags+ " 1 == 1)\n\t\t\t{\n"; //just adding 1=1 as we added && at last in allJsonTags
			 					
					output += "\t\t\t\tfor(var m"+arrayCount+" = 0;  m"+arrayCount+" < "+curTag+".length; m"+arrayCount+"++)\n\t\t\t\t{\n";
					endingBrackets += "\t\t\t\t}\n";	//ending of for loop		

					endingBrackets += "\t\t\t}\n";	//ending of if		
					s3 = s3.substring(s3.indexOf("[*]") + 3);
					if(s3.startsWith(".")) s3 = s3.substring(1);

					arrayCount++;

					if(s3.indexOf("[*]") < 0) //no more arrays left so we have to add the condition code here
					{
						curArrayCount = parentTags.size() -1;
						parentJson = "";
						for(int p=parentTags.size()-1;p>-1;p--) parentJson  = parentTags.get(p) + "[m"+(curArrayCount--)+"]." + parentJson; 

						String s2 = (parentJson + s3).trim();
						if(s2.endsWith(".")) s2 = s2.substring(0, s2.length()-1);

						_json = s2;
		
						tags.clear();
						tags.add(_json);
						while(_json.indexOf(".") > -1)
						{
							_json = _json.substring(0, _json.lastIndexOf("."));
							tags.add(_json);
						}
						allJsonTags = getAllTags(tags);
//						for(int j=tags.size()-1; j > -1; j--)
//							allJsonTags += tags.get(j) + " && ";
					
						if(!matchingProp.equals("value")) s2 = s2 + "." + matchingProp;
//						else s2 = s2 +".toLowerCase()";
						else s2 = "(''+"+s2+")"+".toLowerCase()" ;
		
						s2 = "_expertSystemHelperFunctions('"+targetFunc+"'," + s2 + ", '"+targetParams+"') "; 

						if(operator.equalsIgnoreCase("EQUALS")) s += " == " + s2 + " ";
						else if(operator.equalsIgnoreCase("NOT_EQUALS")) s += " != " + s2 + " ";
						else if(operator.equalsIgnoreCase("CONTAINS")) s += ".indexOf(\""+s2+"\") > -1";
						else if(operator.equalsIgnoreCase("STARTS")) s += ".match(/^"+s2+"/)"; 
						else if(operator.equalsIgnoreCase("ENDS")) s += ".match(/"+s2+"$/)"; 
						else if(operator.equalsIgnoreCase("GREATER")) s += " > " + s2;
						else if(operator.equalsIgnoreCase("LESSER")) s += " < " + s2;
						else if(operator.equalsIgnoreCase("GREATER_EQUALS")) s += " >= " + s2;
						else if(operator.equalsIgnoreCase("LESSER_EQUALS")) s += " <= " + s2;

						output += "\t\t\tif(" +allJsonTags+ " " + s + ")\n\t\t\t{\n"; //just adding 1=1 as we added && at last in allJsonTags
						output += "\t\t\t\t" + variable + " = true;\n";
//						output += "\t\t\t\talert("+s2+"+' : '+"+__t+");\n";
						endingBrackets += "\t\t\t}\n";	//ending of if		
					}
				}
				s = output + endingBrackets;
				s += "\t\t\t}\n";			
			}

		}

		return s;
	}

%>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));

	String scr = "";

	Set rsScr = Etn.execute("select * from expert_system_json where id = "+escape.cote(jsonId));
	rsScr.next();

       List<Rule> rules = new ArrayList<Rule>();
	Set rsRules = Etn.execute("select * from expert_system_rules where json_id = "+escape.cote(jsonId)+" order by coalesce(exec_order,10000), id  ");
	while(rsRules.next())
	{
		Rule _r = new Rule();
		_r.outputTag = parseNull(rsRules.value("output_tag"));		
		_r.outputVal = parseNull(rsRules.value("output_val"));		
		_r.outputType = parseNull(rsRules.value("output_type"));		
       	_r.conditions = new ArrayList<Condition>();
		_r.htmlTagId = parseNull(rsRules.value("html_tag_id"));		

		Set rsCond = Etn.execute("select * from expert_system_conditions where rule_id = "+escape.cote(rsRules.value("id"))+" order by id ");
		while(rsCond.next())
		{
		       Condition _c = new Condition();
		       _c.jsonTag = parseNull(rsCond.value("json_tag"));
		       _c.operator = parseNull(rsCond.value("operator"));
	       	_c.value = parseNull(rsCond.value("value"));			
		       _c.valueType = parseNull(rsCond.value("value_type"));	
			_c.intraConditionOp = parseNull(rsCond.value("intra_condition_operator"));			
			_c.sourceFunc = parseNull(rsCond.value("source_func"));			
			_c.targetFunc = parseNull(rsCond.value("target_func"));			
			_c.sourceParams = parseNull(rsCond.value("source_params"));			
			_c.targetParams = parseNull(rsCond.value("target_params"));			

			if(_c.intraConditionOp.equalsIgnoreCase("AND")) _c.intraConditionOp = "&&";
			else if(_c.intraConditionOp.equalsIgnoreCase("OR")) _c.intraConditionOp = "||";
		       _r.conditions.add(_c);
		}//end of while(rsCond.next)
		
		rules.add(_r);
	}//end of rsRules.next

	for(int i=0; i<rules.size(); i++) { 
		Rule r = rules.get(i);
		if(r.outputType.equalsIgnoreCase("S")) continue;
		String _val = r.outputVal.replaceAll("&lt;","<").replaceAll("&gt;",">");
		
		if(_val.toLowerCase().trim().startsWith("<script"))
		{
			_val = _val.substring(_val.indexOf(">")+1);
			_val = _val.substring(0,_val.indexOf("</script>"));
			scr += "function _expertSystemScripts_"+CommonHelper.escapeCoteValue(jsonId)+"_"+i+"()\n{\n";
			scr += "\t" + _val+ "\n";			
			scr += "}\n";
		}
	}

	scr += "\nfunction _applyExpertSystemRules"+CommonHelper.escapeCoteValue(jsonId)+"(_json)\n{\n";
//	scr += "\tif(typeof(_uiDisplay"+CommonHelper.escapeCoteValue(jsonId)+") == 'function') _uiDisplay"+CommonHelper.escapeCoteValue(jsonId)+"(_json)\n"; 

	scr += "\tvar __jsonObj = new Object()\n";
	List<String> containersReset = new ArrayList<String>();
	for(int i=0; i<rules.size(); i++) 
	{ 
		Rule r = rules.get(i);
		for(int j=0;j<r.conditions.size();j++)
		{
			Condition c = r.conditions.get(j);
			scr += "\tvar _condResult"+i+"_"+j+" = false;\n";
			String _tag = c.jsonTag.substring(0, c.jsonTag.lastIndexOf("."));
			String[] tags = _tag.split("\\.");            
			String prop = c.jsonTag.substring(c.jsonTag.lastIndexOf(".") + 1);
			String output = "";
			String endingBrackets = "";
			Map<String, String> parentNodes = new LinkedHashMap<String, String>();
			//_json is the json variable incoming to _applyExpertSystemRules
			parentNodes.put("_json","");
			int k = 0;
			for(String tag : tags)
			{
				if(tag.indexOf("[*]") > -1)//if the tag is an array, then we have to generate a for loop in javascript for it
				{
					String curTag = tag.substring(0, tag.indexOf("[*]"));
					parentNodes.put(curTag, "[__i"+i+""+j+""+k+"]");//here we are putting the javascript variable name used in for loop 
						
					if(k+1 == tags.length)//means end of tags
					{
						if(prop.equalsIgnoreCase("length")) output = getConditionCode(getJson(parentNodes), prop, c.operator, c.value, "_condResult"+i+"_"+j, c.valueType, c.sourceFunc, c.targetFunc, c.sourceParams, c.targetParams);
						else
						{
							scr += "\tif("+getSourceJsonTagsExists(parentNodes)+")\n\t{\n";//here we are checking if json tags exist
							
							//this is the for loop for the array tag
							scr += "\t\tfor(var __i"+i+""+j+""+k+"=0; __i"+i+""+j+""+k+"<"+getJsonForArray(parentNodes)+".length; __i"+i+""+j+""+k+"++)\n\t\t{\n";
							output = getConditionCode(getJson(parentNodes), prop, c.operator, c.value, "_condResult"+i+"_"+j, c.valueType, c.sourceFunc, c.targetFunc, c.sourceParams, c.targetParams);
							endingBrackets += "\t\t}\n";//ending for loop
							endingBrackets += "\t}\n";//ending if
						}
					}
					else
					{
						scr += "\tif("+getSourceJsonTagsExists(parentNodes)+")\n\t{\n";//here we are checking if json tag exists
						scr += "\t\tfor(var __i"+i+""+j+""+k+"=0; __i"+i+""+j+""+k+"<"+getJsonForArray(parentNodes)+".length; __i"+i+""+j+""+k+"++)\n\t\t{\n";
						parentNodes.put(curTag, "[__i"+i+""+j+""+k+"]");
						//output = "";
						endingBrackets += "\t\t}\n";//ending for loop
						endingBrackets += "\t}\n";//ending if
					}
				} 
				else 
				{	
					parentNodes.put(tag, "");
					if(k+1 == tags.length)//means end of tags
						output = getConditionCode(getJson(parentNodes), prop, c.operator, c.value, "_condResult"+i+"_"+j, c.valueType, c.sourceFunc, c.targetFunc, c.sourceParams, c.targetParams);
					else 
					{
						output = getJson(parentNodes);
					}
				}
				k ++;
			}//end for of tags
			scr += output+"\n";
			scr += endingBrackets+"\n";
		}//end for of r.conditions

		//reseting the divs/textareas/text input etc for previous values
		String resetHtmlContainers = "";
		if(!r.htmlTagId.equals("") && !containersReset.contains(r.htmlTagId.toLowerCase())) 
		{
			containersReset.add(r.htmlTagId.toLowerCase());
			resetHtmlContainers += "\tif($('#"+r.htmlTagId+"') && $('#"+r.htmlTagId+"').is('input')) $('#"+r.htmlTagId+"').val(''); \n";
			resetHtmlContainers += "\telse if($('#"+r.htmlTagId+"') && $('#"+r.htmlTagId+"').is('textarea')) $('#"+r.htmlTagId+"').val(''); \n";
			resetHtmlContainers += "\telse if($('#"+r.htmlTagId+"')) $('#"+r.htmlTagId+"').html(''); \n";
		}
		scr += resetHtmlContainers;

		String ruleCondition = "";

		//appending ruleCondition with all condition variables and the intra condition operator to generate the final if statement
		for(int j=0;j<r.conditions.size();j++)
		{
			Condition c = r.conditions.get(j);
			if(j==0) ruleCondition = " _condResult"+i+"_"+j;
			else ruleCondition += " _condResult"+i+"_"+j;
			ruleCondition += " " + c.intraConditionOp +" ";
		}
		//we need to check if more than 2 tags have same name then displaying their values must be appended. Otherwise the container will be reset everytime
		boolean multipleTag = false;
		int counter = 0;
		for(int n=0; n<rules.size(); n++) { 
			if(rules.get(n).outputTag.equals(r.outputTag)) counter ++;
		}
		if(counter > 1) multipleTag = true;


		ruleCondition = "\tif( " + ruleCondition + ")\n\t{\n";
//			if(r.outputType.equalsIgnoreCase("S")) ruleCondition += " __jsonObj.SYSTEM_ALERTS.push('"+r.outputVal+"');\n";
		if(r.outputType.equalsIgnoreCase("S")) ruleCondition += " alert('"+r.outputVal.replaceAll("'","\\\\'")+"');\n";
		else 
		{ 
			String _val = r.outputVal.replaceAll("'","\\\\'").replaceAll("&lt;","<").replaceAll("&gt;",">");
			
			if(multipleTag) 
			{
				scr += "\tif(!__jsonObj."+r.outputTag+") __jsonObj."+r.outputTag+" = new Array(); \n";
				scr += "\t__jsonObj."+r.outputTag+".push('"+r.outputVal.replaceAll("'","\\\\'")+"'); \n";
			}
			else ruleCondition += "\t\t__jsonObj."+r.outputTag+" = '"+r.outputVal.replaceAll("'","\\\\'")+"';  \n";
			if(!r.htmlTagId.equals("") && !_val.toLowerCase().trim().startsWith("<script")) 
			{
				if(multipleTag) {
					ruleCondition += "\t\tif($('#"+r.htmlTagId+"') && $('#"+r.htmlTagId+"').is('input')) $('#"+r.htmlTagId+"').val($('#"+r.htmlTagId+"').val() + '"+_val+"'); \n";
					ruleCondition += "\t\telse if($('#"+r.htmlTagId+"') && $('#"+r.htmlTagId+"').is('textarea')) $('#"+r.htmlTagId+"').val($('#"+r.htmlTagId+"').val() + '"+_val+"'); \n";
					ruleCondition += "\t\telse if($('#"+r.htmlTagId+"'))\n\t\t{\n";
					ruleCondition += "\t\t\tif($.trim($('#"+r.htmlTagId+"').html()) == '') $('#"+r.htmlTagId+"').html('"+_val+"'); \n";
					ruleCondition += "\t\t\telse $('#"+r.htmlTagId+"').html($('#"+r.htmlTagId+"').html() + '<br/> "+_val+"'); \n";
					ruleCondition += "\t\t}\n";
				}
				else {
					ruleCondition += "\t\tif($('#"+r.htmlTagId+"') && $('#"+r.htmlTagId+"').is('input')) $('#"+r.htmlTagId+"').val('"+_val+"'); \n";
					ruleCondition += "\t\telse if($('#"+r.htmlTagId+"') && $('#"+r.htmlTagId+"').is('textarea')) $('#"+r.htmlTagId+"').val('"+_val+"'); \n";
					ruleCondition += "\t\telse if($('#"+r.htmlTagId+"')) $('#"+r.htmlTagId+"').html('"+_val+"'); \n";
				}
			}

			if(r.outputVal.toLowerCase().trim().replaceAll("&lt;","<").startsWith("<script"))
			{
				ruleCondition += "\t\t_expertSystemScripts_"+CommonHelper.escapeCoteValue(jsonId)+"_"+i+"();\n";
			}
		}

		ruleCondition += "\t}\n";
		scr += ruleCondition;
	}//end of rules

//	scr += "\treturn window[\"eval\"](\"(\" + JSON.stringify(__jsonObj) + \")\"); \n";
	scr += "}//end of applyExpertSystemRules\n";

	FileOutputStream fos = null;
	String resp = "SUCCESS";
	try
	{
		scr = "/**This file is generated by Expert System.\nPlease do not make changes to this file.\n**/\n\n" + scr;
		fos = new FileOutputStream(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_rules_"+CommonHelper.escapeCoteValue(jsonId)+".js");
		fos.write(scr.getBytes("utf8"));
		fos.close();
		Etn.executeCmd("update expert_system_json set rules_script_file = "+escape.cote("expsys_rules_"+CommonHelper.escapeCoteValue(jsonId)+".js")+" where id = " + escape.cote(jsonId));
	}
	catch(Exception e)
	{
		if(fos != null) fos.close();
		e.printStackTrace();	
		resp = "ERROR";	
	}
%>
{"MSG":"Script generated!!!", "RESPONSE":"<%=resp%>"}