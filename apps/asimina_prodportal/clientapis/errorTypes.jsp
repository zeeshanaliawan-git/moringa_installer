<%!
	static class ErrorTypes
	{
		public static int SESSION_TOKEN_MISMATCH = 100;
		public static int INVALID_LANG = 200;
		public static int INVALID_SHOP = 250;
		public static int INVALID_MENU_ID = 300;
		public static int INVALID_SITE_ID = 350;
		public static int ECOMMERCE_DISABLED = 351;
		public static int INVALID_CATALOG_ID = 400;
		public static int INVALID_PRODUCT_ID = 500;
		public static int INVALID_PROMO_CODE = 600;
		public static int INVALID_VARIANT_ID = 700;
		public static int INVALID_PRICE = 750;
		public static int CART_ITEM_NOT_REMOVED = 800;
		public static int CART_ITEM_NOT_ADDED = 801;
		public static int ONLY_LOGGED_IN = 900;
		public static int INVALID_CONTENT_TYPE = 950;
		public static int RESULT_SET_NULL = 998;
		public static int SOME_EXCEPTION = 999;
		public static int PRICE_LIMIT_EXCEED = 1000;
	}
	
	static class ErrorMessages
	{
		public static String SESSION_TOKEN_MISMATCH = "Session token mismatch. Please call APIs in the correct sequence.";
		public static String INVALID_LANG = "Invalid language. Please contact administrator.";
		public static String INVALID_SHOP = "Invalid shop. Please contact administrator.";
		public static String INVALID_MENU_ID = "Invalid menu uuid provided.";
		public static String INVALID_SITE_ID = "Invalid site. Please contact administrator.";
		public static String ECOMMERCE_DISABLED = "ECommerce is not enabled for this site. Please contact administrator";
		public static String INVALID_CATALOG_ID = "Invalid catalog uuid provided.";
		public static String INVALID_PROMO_CODE = "Invalid promo code provided.";
		public static String INVALID_PRODUCT_ID = "Invalid product uuid provided.";
		public static String INVALID_VARIANT_ID = "Invalid product variant uuid provided.";
		public static String INVALID_PRICE = "Invalid or no price provided.";
		public static String CART_ITEM_NOT_REMOVED = "Variant could not be removed from cart. Please contact administrator.";
		public static String CART_ITEM_NOT_ADDED = "Variant could not be added to cart. Please contact administrator.";
		public static String ONLY_LOGGED_IN = "Only logged-in users can add this product.";
		public static String INVALID_CONTENT_TYPE = "Invalid content type.";
		public static String RESULT_SET_NULL = "Result set is null. Please contact administrator.";
		public static String PRICE_LIMIT_EXCEED = "Price limit is exceeding. Cannot continue with purchase.";
		
	}
	
	String getStackTrace(Exception ex)
	{
		java.io.StringWriter sw = new java.io.StringWriter();
		java.io.PrintWriter pw = new java.io.PrintWriter(sw);
		ex.printStackTrace(pw);
		String trace = sw.toString(); // stack trace as a string
		return trace;
	}
	
%>