SELECT pgtle.install_update_path
(
 'calendar',
 '1.5',
 '1.6',
$_pg_tle_$

--
-- 1.5 -> 1.6: Correct regnalyeardaterangetext datatype
--

ALTER TABLE regnalyeartest
  ALTER COLUMN regnalyeardaterangetext TYPE text;

$_pg_tle_$
);
