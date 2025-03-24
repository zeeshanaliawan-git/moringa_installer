// -----------------------------------------------------------------------------
// Projet : METEO +
// Client : ORANGE METEO
// Auteur : B-JEMNI
// Copyright © ETANCE - 2012
// -----------------------------------------------------------------------------
// 2012-31-03 15:27:34 
// -----------------------------------------------------------------------------
package com.etn.util;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;

public class DateTimeZone {

	public static Date getDateInTimeZone(Date currentDate, String timeZoneId) {
		TimeZone tz = TimeZone.getTimeZone(timeZoneId);
		Calendar mbCal = new GregorianCalendar(TimeZone.getTimeZone(timeZoneId));
		mbCal.setTimeInMillis(currentDate.getTime());
		Calendar cal = Calendar.getInstance();
		cal.set(Calendar.YEAR, mbCal.get(Calendar.YEAR));
		cal.set(Calendar.MONTH, mbCal.get(Calendar.MONTH));
		cal.set(Calendar.DAY_OF_MONTH, mbCal.get(Calendar.DAY_OF_MONTH));
		cal.set(Calendar.HOUR_OF_DAY, mbCal.get(Calendar.HOUR_OF_DAY));
		cal.set(Calendar.MINUTE, mbCal.get(Calendar.MINUTE));
		cal.set(Calendar.SECOND, mbCal.get(Calendar.SECOND));
		cal.set(Calendar.MILLISECOND, mbCal.get(Calendar.MILLISECOND));
		return cal.getTime();
	}

	public static void main(String[] args) {
		Date now = new Date();

		//System.out.println("Current Time=" + now);
		Calendar cal = Calendar.getInstance();
		//System.out.println("Current Timezone="+ cal.getTimeZone().getDisplayName());

		// Canada/Central
		String timeZoneId = "Asia/Anadyr";
		//System.out.println("Getting Time in the timezone=" + timeZoneId);
		//System.out.println("Current Time there="+ getDateInTimeZone(now, timeZoneId));
	}

}