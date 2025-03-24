<%@ page import="com.google.gson.*"%>

<%!
    public class MyObject
    {
        boolean isArray;
        boolean isObject;
        Map<String, Object> map;
	 String defaultHeaderName ;
		
        public MyObject(boolean _isArray, Map<String, Object> _map, boolean _isObject)
        {
            isArray = _isArray;
            map = _map;
	     isObject = _isObject;
        }
    }

	public class ColsDatas
	{
		String tag;
		List<String> colNames;
		
		public ColsDatas()
		{
		}
	}

	public int noOfColumns(JsonParser parser , String json)
	{
//System.out.println(json);
		int cols = -1;
		JsonElement ele = parser.parse(json);    
		if(ele.isJsonArray())
		{
			JsonArray array = (JsonArray)ele;
	 		if(array.size() > 0) 
		 	{
				cols = array.size();
	       		int cols2 = noOfColumns(parser, array.get(0).toString());
				if(cols2 != -1) cols = cols2;
		 	}
		}
		return cols;
	}

	public List<String> parseColumnNames(JsonParser parser, String json)
	{
		JsonElement ele = parser.parse(json);
		List<String> names = new ArrayList<String>();
		if(ele.isJsonArray())
		{
			JsonArray array = (JsonArray)ele;
			if(array.size() > 0) 
			{
				for(int i=0; i<array.size(); i++) names.add(array.get(i).getAsString());
			}
		}
		return names;
	}

	public Map<String, Object> parse(JsonParser parser , String json, List<ColsDatas> colsDatas) 
	{    
		Map<String, Object> map = new LinkedHashMap<String, Object>();
		JsonElement ele = parser.parse(json);    
		if(ele.isJsonObject())//starting point will always be JsonObject
		{
			JsonObject object = (JsonObject)ele;
			java.util.Set<Map.Entry<String, JsonElement>> set = object.entrySet();
			Iterator<Map.Entry<String, JsonElement>> iterator = set.iterator();
			while (iterator.hasNext()) 
			{
				Map.Entry<String, JsonElement> entry = iterator.next();
				String key = entry.getKey();
				JsonElement value = entry.getValue();
				if (!value.isJsonPrimitive()) 
				{
//                System.out.println(key + " " + value.isJsonArray() + " " + value.isJsonObject());               
					MyObject obj = new MyObject(value.isJsonArray(),parse(parser, value.toString(), colsDatas), value.isJsonObject());	
					if(obj.map.keySet().size() == 0)
					{
						//Special type of tabular data in which column names are sent separately and data is sent in a separate array
						int cols = noOfColumns(parser, value.toString());
						System.out.println("$$$ colsDatas : " + colsDatas.size());
/*					if(!colsDatas.isEmpty())
					{
						System.out.println(colsDatas.get(colsDatas.size()-1).colNames.size());
						System.out.println(cols);		
					}*/
						if(!colsDatas.isEmpty() && colsDatas.get(colsDatas.size()-1).tag.equals("cols") && key.equals("datas") && colsDatas.get(colsDatas.size()-1).colNames != null &&
						   colsDatas.get(colsDatas.size()-1).colNames.size() == cols)//we are checking we have a cols part for the datas part and they have same number of cols
						{				
							for(int i=0;i<cols;i++)
							{
								MyObject _m = new MyObject(false, new LinkedHashMap<String, Object>(), false);
								_m.defaultHeaderName = colsDatas.get(colsDatas.size()-1).colNames.get(i);
								obj.map.put("EXPSYS_SPECIAL_COL_"+i, _m);
							}
						}	
						else
						{
							for(int i=0;i<cols;i++)
							{
								obj.map.put("EXPSYS_SPECIAL_COL_"+i, new MyObject(false, new LinkedHashMap<String, Object>(), false));
							}
						}
						ColsDatas cds = new ColsDatas();
						cds.tag = key;
						colsDatas.add(cds);
						if(key.equals("cols"))
						{
							System.out.println("json = " + value.toString());				
							cds.colNames = parseColumnNames(parser, value.toString());
						}
					}
					map.put(key, obj);
				} 
				else 
				{
					map.put(key, value.getAsString());
				}
			}
		}
		else if(ele.isJsonArray())
		{
			JsonArray array = (JsonArray)ele;
			if(array.size() > 0) 
			{
				map = parse(parser, array.get(0).toString(), colsDatas);
			}
		}
		return map;
	}    


/*public MyObject parse2(JsonParser parser , String json) {
    MyObject myObject = new MyObject();
    myObject.map = new LinkedHashMap<String, Object>();
    JsonElement ele = parser.parse(json);
System.out.println("$$$ json : " + json);    
//System.out.println("$$$ ele : " + ele.isJsonObject());
    if(ele.isJsonObject())//starting point will always be JsonObject
    {
        JsonObject object = (JsonObject)ele;
        java.util.Set<Map.Entry<String, JsonElement>> set = object.entrySet();
        Iterator<Map.Entry<String, JsonElement>> iterator = set.iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, JsonElement> entry = iterator.next();
            String key = entry.getKey();
            JsonElement value = entry.getValue();
            if (!value.isJsonPrimitive()) {
                //System.out.println(key + " " + value.isJsonArray() + " " + value.isJsonObject());               
		  MyObject myObjectChild = parse(parser, value.toString());
                MyObject obj = new MyObject(value.isJsonArray(),myObjectChild.map, value.isJsonObject());
		  System.out.println(" %%  "+key+" : " + myObjectChild.noOfPrimitiveColsInArray);
                myObject.map.put(key, obj);
            } else {
//System.out.println("$$$ key : " + key + " val : " + value.getAsString());
                myObject.map.put(key, value.getAsString());
            }
        }
    }
    else if(ele.isJsonArray())
    {
        JsonArray array = (JsonArray)ele;
	 if(array.size() > 0) 
	 {
		MyObject child = parse(parser, array.get(0).toString());
		//this is a special kind of array in which we dont have col names but col names are sent in separate array and data in separate array
	 	if(myObject.map.keySet().size() == 0 && array.get(0).isJsonPrimitive())
	  	{
			System.out.println(array.size());
			myObject.noOfPrimitiveColsInArray = child.noOfPrimitiveColsInArray;
	  	}
	 	myObject.map = child.map;
	 }
    }
    return myObject;
}    */


%>