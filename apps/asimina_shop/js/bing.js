var myMap = null;

function GetMap(divId)
{
	if (myMap != null) {
	   myMap.Dispose();
	}

	myMap = new VEMap(divId);
	myMap.LoadMap();
	myMap.Resize(); 
}
          //this function is called for the suggested addresses
         function FindSuggestedLoc(addr)
         {
			addr = addr + " spain ";
            try
            {
               myMap.Find(null,
						  addr,
						  null,
						  null,
						  null,
						  null,
						  true,
						  false,
						  false,
						  true,
						  SuggestionResults);
            }
            catch(e)
            {
               alert(e.message);
            }
         }
        
        function SuggestionResults(layer, resultsArray, places, hasMore, veErrorMessage)
        {
			// if there are no results, display any error message and return
			if(places == null)
			{
				return;
			}
	
			var bestPlace = places[0];
			// Add pushpin to the *best* place
			var location = bestPlace.LatLong;
			var newShape = new VEShape(VEShapeType.Pushpin, location);
			var desc = "Latitude: " + location.Latitude + "<br>Longitude:" + location.Longitude;
			newShape.SetDescription(desc);
			newShape.SetTitle(bestPlace.Name);			
			myMap.AddShape(newShape);			
        }


	function OnSelectAddr(obj)
	{
		FindSuggestedLoc(obj.value);
	}


         function FindLoc(addr)
         {
			addr = addr + " spain ";
            try
            {
               myMap.Find(null,
						  addr,
						  null,
						  null,
						  null,
						  null,
						  true,
						  false,
						  false,
						  true,
						  MyResults);
            }
            catch(e)
            {
               alert(e.message);
            }
         }
        
        function MyResults(layer, resultsArray, places, hasMore, veErrorMessage)
        {
			anyMatchConfidenceHigh = false;
			var match = "";	
			suggestionsHTML = " no results found ";	
			firstSuggestion = "";	
			if(places)
			{
				suggestionsHTML = "<table style='font-size:8pt;' border=1 cellpadding=0 cellspacing=0 width='98%'>";
				suggestionsHTML = suggestionsHTML + "<tr><td width='5%'>&nbsp;</td><td width='20%'><b>Match</b></td><td><b>Suggested Address</b></td></tr>";
				for(var i=0;i<places.length;i++)
				{
					if(places[i].MatchConfidence == 0)//high
					{
						match = "High";
						anyMatchConfidenceHigh = true;
					}
					else if(places[i].MatchConfidence == 1)//medium
						match = "Medium";
					else if(places[i].MatchConfidence == 0)//low
						match = "Low";
					else match = "None";
					if(i==0)
					{
						suggestionsHTML = suggestionsHTML + "<tr><td><input type='radio' checked name='suggestedAddr' value='"+places[i].Name+"' onclick='OnSelectAddr(this)'/></td><td>"+match+"</td><td>"+places[i].Name+"</td></tr>";				
						firstSuggestion = places[i].Name;
					}
					else
						suggestionsHTML = suggestionsHTML + "<tr><td><input type='radio' name='suggestedAddr' value='"+places[i].Name+"' onclick='OnSelectAddr(this)'/></td><td>"+match+"</td><td>"+places[i].Name+"</td></tr>";				
				}
				suggestionsHTML = suggestionsHTML + "</table>";
			}

			if(anyMatchConfidenceHigh) document.getElementById('addrVerifyResult').innerHTML = 'Address is valid';
			else 
			{
				document.getElementById('addrVerifyResult').innerHTML = 'No exact match found for address. <a href="javascript:ShowAddrSuggestions();">Click here</a> for suggestions';
			}

		}



