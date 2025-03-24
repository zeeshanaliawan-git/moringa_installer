package com.etn.asimina.cart;

import com.etn.beans.Contexte;
import javax.servlet.http.HttpServletRequest;
import org.apache.commons.fileupload.*;

public interface OrderInsertExtraDataImpl {
	public String verify(Contexte Etn, String siteId, org.json.JSONObject jRequest, java.util.Map<String, java.util.List<FileItem>> filesMap);
	public boolean process(Contexte Etn, String siteId, String orderUuid, org.json.JSONObject jRequest, java.util.Map<String, java.util.List<FileItem>> filesMap); 
}