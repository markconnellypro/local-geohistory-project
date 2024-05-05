SELECT pgtle.install_update_path
(
 'calendar',
 '1.6',
 '1.7',
$_pg_tle_$

--
-- 1.6 -> 1.7: Add security definer to functions
--

ALTER FUNCTION calendar.date(historicdate calendar.historicdate) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdate_difference(historicdate1 calendar.historicdate, historicdate2 calendar.historicdate) SECURITY DEFINER;
ALTER FUNCTION calendar.hebrewfirst(year integer) SECURITY DEFINER;
ALTER FUNCTION calendar.yearmonthday(gregorian date, typeidchar "char") SECURITY DEFINER;
ALTER FUNCTION calendar.yearmonthday(historicdate calendar.historicdate) SECURITY DEFINER;
ALTER FUNCTION calendar.date(yearmonthday calendar.yearmonthday, typeidchar "char") SECURITY DEFINER;
ALTER FUNCTION calendar.historicdatetext(historicdate calendar.historicdate) SECURITY DEFINER;
ALTER FUNCTION calendar.daterange(historicdaterange calendar.historicdaterange) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdate(datetext text) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdate(monarchname text, regnalyearnumbervalue integer, month integer, day integer, partidvalue text) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdatetextformat(historicdate calendar.historicdate, formattype text, localecode text) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdaterange(daterangetext text) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdaterangetext(historicdaterange calendar.historicdaterange) SECURITY DEFINER;
ALTER FUNCTION calendar.historicdaterangetextformat(historicdaterange calendar.historicdaterange, formattype text, localecode text) SECURITY DEFINER;
ALTER FUNCTION calendar.regnalyeartext(historicdate calendar.historicdate) SECURITY DEFINER;
ALTER FUNCTION calendar.is_historicdate(text) SECURITY DEFINER;
ALTER FUNCTION calendar.is_historicdaterange(text) SECURITY DEFINER;

$_pg_tle_$
);
