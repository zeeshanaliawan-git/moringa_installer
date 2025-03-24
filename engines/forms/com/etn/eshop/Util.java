package com.etn.eshop;

public class Util {

	public static String parseNull(Object o) {
		if (o == null)
			return ("");
		String s = o.toString();
		if ("null".equals(s.trim().toLowerCase()))
			return ("");
		else
			return (s.trim());
	}

	public static int parseNullInt(Object o) {
		if (o == null)
			return 0;
		String s = o.toString();
		if (s.equals("null"))
			return 0;
		if (s.equals(""))
			return 0;
		return Integer.parseInt(s);
	}

	public static double parseNullDouble(Object o) {
		if (o == null)
			return 0;
		String s = o.toString();
		if (s.equals("null"))
			return 0;
		if (s.equals(""))
			return 0;
		return Double.parseDouble(s);
	}
}
