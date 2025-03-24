<%!
String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib)
{ 
	return com.etn.asimina.util.LanguageHelper.getInstance().getTranslation(Etn, lib);
}
String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib, boolean addindictionary)
{ 
	return com.etn.asimina.util.LanguageHelper.getInstance().getTranslation(Etn, lib, addindictionary);
}
String getLangDirection(String lang, javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn)
{
	return com.etn.asimina.util.LanguageHelper.getInstance().getLangDirection(Etn, lang);
}
void set_lang(String lang, javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn)
{
	com.etn.asimina.util.LanguageHelper.getInstance().set_lang(Etn, lang);	
}

String getLangPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	return com.etn.asimina.util.LanguageHelper.getInstance().getLangPrefix(Etn, lang);
}

String getProductColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	return com.etn.asimina.util.LanguageHelper.getInstance().getProductColumnsPrefix(Etn, lang);
}
%>