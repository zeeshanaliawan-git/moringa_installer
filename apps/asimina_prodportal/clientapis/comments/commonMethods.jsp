<%!
int getCount(com.etn.beans.Contexte Etn, String sourceId, String sourceType)
{
	int cnt = 0;
	com.etn.lang.ResultSet.Set rs = Etn.execute("select count(0) as cnt from client_reviews where type = 'comment' and source_id = "+com.etn.sql.escape.cote(sourceId)+" and source_type = "+com.etn.sql.escape.cote(sourceType));
	if(rs.next())
	{
		cnt = com.etn.asimina.util.PortalHelper.parseNullInt(rs.value("cnt"));
	}
	return cnt;
}
%>