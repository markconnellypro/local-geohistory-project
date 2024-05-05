SELECT pgtle.install_extension
(
 'calendar',
 '1.7',
 'Support for non-standard calendars.',
$_pg_tle_$

--
-- CREATE TABLES
--

CREATE TABLE calendar.hebrewmonth (
    k integer NOT NULL,
    m integer NOT NULL,
    a integer NOT NULL
);

COMMENT ON TABLE calendar.hebrewmonth IS 'Derived from: Richards, E. G. "Calendars." In Explanatory Supplement to the Astronomical Almanac,
  3rd ed., edited by Sean E. Urban and P. Kenneth Seidelmann, 585-624. Mill Valley, Calif.:
  University Science Books, 2012. https://aa.usno.navy.mil/downloads/c15_usb_online.pdf
Source: Table 15.15
Note: Mathematical principles, formulas, algorithms, or equations are not copyrightable. See
  U.S. COPYRIGHT OFFICE, COMPENDIUM OF U.S. COPYRIGHT OFFICE PRACTICES § 313.3(A) (3d ed. 2021).';

CREATE TABLE calendar.locale
(
    localeid character varying(2) NOT NULL,
    dayfirst boolean NOT NULL,
    daysuffix text NOT NULL,
    daydelimiter text NOT NULL,
    monthdelimiter text NOT NULL,
    dayonesuffix text NOT NULL
);

CREATE TABLE calendar.monthday (
    type "char" NOT NULL,
    monthinteger integer NOT NULL,
    monthday integer NOT NULL
);

CREATE TABLE calendar.monthshort (
    type "char" NOT NULL,
    monthinteger integer NOT NULL,
    monthshort text NOT NULL
);

CREATE TABLE calendar.monthlong (
    type "char" NOT NULL,
    locale character varying(2) NOT NULL,
    monthinteger integer NOT NULL,
    monthlong text NOT NULL,
    monthabbreviation text NOT NULL
);

CREATE TABLE calendar.part (
    partid text NOT NULL,
    type "char",
    monthshorttype "char",
    monthlongtype "char",
    monthdaytype "char",
    monthmax integer,
    monthstart integer,
    daystart integer,
    yearbefore integer,
    yearafter integer,
    monthdifference integer
);

COMMENT ON COLUMN calendar.part.type IS 'This determines the calendar conversion type';

COMMENT ON COLUMN calendar.part.monthshorttype IS 'This determines how the text and integer versions of the months relate';

COMMENT ON COLUMN calendar.part.monthlongtype IS 'This determines the names of the months in their locales';

COMMENT ON COLUMN calendar.part.monthdaytype IS 'This determines what days are valid in which months';

CREATE TABLE calendar.qualifier (
    qualifierid text NOT NULL,
    qualifierabbreviation text NOT NULL,
    qualifiershort text NOT NULL,
    qualifierisinstant boolean NOT NULL
);

CREATE TABLE calendar.qualifierlocale (
    qualifier text NOT NULL,
    locale text NOT NULL,
    qualifiershort text NOT NULL,
    qualifierlong text NOT NULL
);

CREATE TABLE calendar.regnalyear
(
    monarch text NOT NULL,
    regnalyearnumber integer NOT NULL,
    regnalyeardaterangetext text NOT NULL
);

CREATE TABLE calendar.type (
    typeid "char" NOT NULL,
    typelong text NOT NULL,
    "group" text NOT NULL,
    y integer,
    j integer,
    m integer,
    n integer,
    r integer,
    p integer,
    q integer,
    v integer,
    u integer,
    s integer,
    t integer,
    w integer,
    a integer,
    b integer,
    c integer
);

COMMENT ON TABLE calendar.type IS 'Derived from: Richards, E. G. "Calendars." In Explanatory Supplement to the Astronomical Almanac,
  3rd ed., edited by Sean E. Urban and P. Kenneth Seidelmann, 585-624. Mill Valley, Calif.:
  University Science Books, 2012. https://aa.usno.navy.mil/downloads/c15_usb_online.pdf
Source: Table 15.14
Note: Mathematical principles, formulas, algorithms, or equations are not copyrightable. See
  U.S. COPYRIGHT OFFICE, COMPENDIUM OF U.S. COPYRIGHT OFFICE PRACTICES § 313.3(A) (3d ed. 2021).';

--
-- CREATE SIMPLE TYPES
--

CREATE TYPE calendar.historicdate AS (
	gregorian date,
	"precision" text,
	qualifier text,
	yeardouble text,
	calendar text
);

CREATE TYPE calendar.yearmonthday AS (
	year integer,
	month integer,
	day integer
);

--
-- CREATE RANGE TYPE FUNCTIONS
--

CREATE FUNCTION calendar.date(historicdate calendar.historicdate) RETURNS date
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    BEGIN

        RETURN historicdate.gregorian;

    END;

$$;

CREATE FUNCTION calendar.historicdate_difference(historicdate1 calendar.historicdate, historicdate2 calendar.historicdate) RETURNS double precision
    LANGUAGE sql IMMUTABLE SECURITY DEFINER
    AS $$
    SELECT cast(
      CASE
        WHEN historicdate1 IS NULL AND historicdate2 IS NULL THEN 0
        ELSE coalesce(calendar.date(historicdate1), '4000-01-01 BC'::date) -
          coalesce(calendar.date(historicdate2), '4000-01-01'::date)
      END
    as float);
$$;

--
-- CREATE RANGE TYPES
--

CREATE TYPE calendar.historicdaterange AS RANGE (
    subtype = calendar.historicdate,
    multirange_type_name = calendar.historicdatemultirange,
    subtype_diff = calendar.historicdate_difference
);

--
-- CREATE PREREQUISITE FUNCTIONS
--

CREATE FUNCTION calendar.hebrewfirst(year integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        Derived from: Richards, E. G. "Calendars." In Explanatory Supplement to the Astronomical Almanac,
          3rd ed., edited by Sean E. Urban and P. Kenneth Seidelmann, 585-624. Mill Valley, Calif.:
          University Science Books, 2012. https://aa.usno.navy.mil/downloads/c15_usb_online.pdf
        Note: Mathematical principles, formulas, algorithms, or equations are not copyrightable. See
          U.S. COPYRIGHT OFFICE, COMPENDIUM OF U.S. COPYRIGHT OFFICE PRACTICES § 313.3(A) (3d ed. 2021).
    */

    DECLARE

      a bigint;
      b bigint;
      c bigint;
      d bigint;
      e bigint;
      f bigint;
      g bigint;
      h bigint;

    BEGIN

      /* 15.11.4 Algorithm 5 */

      a := (235 * year - 234)/19;
      b := 204 + 793 * a;
      c := 5 + 12 * a + b/1080;
      d := 1 + 29 * a + c/24;
      e := mod(b, 1080) + 1080 * mod(c, 24);
      f := 1 + mod(d, 7);
      g := mod(7 * year + 13, 19)/12;
      h := mod(7 * year + 6, 19)/12;

      IF e >= 19440 OR (e >= 9924 AND f = 3 AND g = 0) OR (e >= 16788 AND f = 2 AND g = 0 AND h = 1) THEN
        d := d + 1;
      END IF;

      RETURN d + mod(mod(d + 5, 7), 2) + 347997;

    END;

$$;

CREATE FUNCTION calendar.yearmonthday(gregorian date, typeidchar "char") RETURNS calendar.yearmonthday
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        Derived from: Richards, E. G. "Calendars." In Explanatory Supplement to the Astronomical Almanac,
          3rd ed., edited by Sean E. Urban and P. Kenneth Seidelmann, 585-624. Mill Valley, Calif.:
          University Science Books, 2012. https://aa.usno.navy.mil/downloads/c15_usb_online.pdf
        Also See: Errata in The Explanatory Supplement to the Astronomical Almanac (3rd edition, 1st printing).
          1 June 2020. https://aa.usno.navy.mil/downloads/exp_supp_errata.pdf
        Note: Mathematical principles, formulas, algorithms, or equations are not copyrightable. See
          U.S. COPYRIGHT OFFICE, COMPENDIUM OF U.S. COPYRIGHT OFFICE PRACTICES § 313.3(A) (3d ed. 2021).
    */

    DECLARE

      hebrewmonth calendar.hebrewmonth;
      type calendar.type;
      yearmonthday calendar.yearmonthday;

      a bigint;
      b bigint;
      c bigint;
      e bigint;
      f bigint;
      g bigint;
      gregorianj integer;
      h bigint;
      k1 bigint;
      m bigint;
      x bigint;
      z bigint;

    BEGIN

      -- Skip processing for empty values

      IF gregorian IS NULL THEN
        RETURN NULL;
      END IF;

      -- Get calendar type

      SELECT * INTO
      type
      FROM calendar.type calendar_type
      WHERE calendar_type.typeid = typeidchar;

      gregorianj := to_char(gregorian, 'J');

      IF type.group IS NULL THEN

        RAISE EXCEPTION 'Calendar not supported';

      ELSIF type.group = 'default' THEN

        RETURN ROW(
          date_part('year', gregorian)::integer,
          date_part('month', gregorian)::integer,
          date_part('day', gregorian)::integer
        );

      ELSIF type.group = 'hebrew' THEN

        /* 15.11.4 Algorithm 6 */

        -- See errata p. 7

        m := floor(0.03386318 * (gregorianj - 347996))::integer + 1;
        yearmonthday.year := 19 * (m/235) + (19 * mod(m, 235) - 2)/235 + 1;
        k1 := calendar.hebrewfirst(yearmonthday.year);

        IF k1 > gregorianj THEN
          yearmonthday.year := yearmonthday.year - 1;
        END IF;

        /* 15.11.4 Algorithm 7 */

        a := calendar.hebrewfirst(yearmonthday.year);
        b := calendar.hebrewfirst(yearmonthday.year + 1);
        k1 := b - a - 352 - 27 * (mod(7 * yearmonthday.year + 13, 19)/12);
        c := gregorianj - a + 1;

        SELECT *
        INTO hebrewmonth
        FROM calendar.hebrewmonth
        WHERE hebrewmonth.k = k1
        AND hebrewmonth.a < c
        ORDER BY hebrewmonth.m DESC;

        yearmonthday.month := hebrewmonth.m;
        yearmonthday.day := c - hebrewmonth.a;

        /* Not part of algorithm */

        -- Determine if leap year

        SELECT * INTO
        hebrewmonth
        FROM calendar.hebrewmonth
        WHERE hebrewmonth.k = k1
        AND hebrewmonth.m = 13;

        -- If not leap year, shift months up to leave placeholder leap month

        IF hebrewmonth.a IS NULL AND yearmonthday.month > 5 THEN
          yearmonthday.month := yearmonthday.month + 1;
        END IF;

      ELSE

        /* 15.11.3 Algorithm 4 */

        f := gregorianj + type.j;

        IF type.group IN ('gregorian', 'saka') THEN
          f := f + (((4 * gregorianj + type.b)/146097) * 3)/4 + type.c;
        END IF;

        e := type.r * f + type.v;
        g := mod(e, type.p)/type.r;

        IF type.group = 'saka' THEN
          x := g/365;
          z := g/185 - x;
          type.s := 31 - z;
          type.w = -5 * z;
          h := type.u * g + type.w;
          yearmonthday.day := (6 * x + mod(h, type.s))/type.u + 1;
        ELSE
          h := type.u * g + type.w;
          yearmonthday.day := (mod(h, type.s))/type.u + 1;
        END IF;

        yearmonthday.month := mod(h/type.s + type.m, type.n) + 1;
        yearmonthday.year := e/type.p - type.y + (type.n + type.m - yearmonthday.month)/type.n;

      END IF;

      RETURN yearmonthday;

    END;

$$;

CREATE FUNCTION calendar.yearmonthday(historicdate calendar.historicdate) RETURNS calendar.yearmonthday
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts the historicdate type to the calendar.yearmonthday type.
    */

    DECLARE

        -- Intermediate values

        part calendar.part;

        -- Final values

        yearmonthday calendar.yearmonthday;

    BEGIN

        -- Skip processing for empty values

        IF historicdate IS NULL THEN
          RETURN NULL;
        END IF;

        -- Get calendar type

        SELECT *
        INTO part
        FROM calendar.part
        WHERE partid = historicdate.calendar;

        IF part.type IS NULL THEN
          RAISE EXCEPTION 'Calendar not supported';
        END IF;

        -- Convert from date

        yearmonthday := calendar.yearmonthday(historicdate.gregorian, part.type);
        IF calendar.date(yearmonthday, part.type) <> historicdate.gregorian THEN
          RAISE EXCEPTION 'Calendar conversion check failed';
        END IF;

        -- Adjust from logical year for month-day combinations on or after year start in calendar

        IF part.yearafter <> 0 AND ((yearmonthday.month > part.monthstart) OR (yearmonthday.month = part.monthstart AND yearmonthday.day >= part.daystart)) THEN
          yearmonthday.year := yearmonthday.year - part.yearafter;
        END IF;

        -- Adjust from logical year for month-day combinations before year start in calendar

        IF part.yearbefore <> 0 AND ((yearmonthday.month < part.monthstart) OR (yearmonthday.month = part.monthstart AND yearmonthday.day < part.daystart)) THEN
          yearmonthday.year := yearmonthday.year - part.yearbefore;
        END IF;

        -- Adjust to logical month

        IF part.monthdifference <> 0 THEN
          yearmonthday.month := yearmonthday.month - part.monthdifference;
          IF yearmonthday.month > part.monthmax THEN
            yearmonthday.month := yearmonthday.month - part.monthmax;
          ELSIF yearmonthday.month < 1 THEN
            yearmonthday.month := yearmonthday.month + part.monthmax;
          END IF;
        END IF;
		
		RETURN yearmonthday;

    END;

$$;

CREATE FUNCTION calendar.date(yearmonthday calendar.yearmonthday, typeidchar "char") RETURNS date
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        Derived from: Richards, E. G. "Calendars." In Explanatory Supplement to the Astronomical Almanac,
          3rd ed., edited by Sean E. Urban and P. Kenneth Seidelmann, 585-624. Mill Valley, Calif.:
          University Science Books, 2012. https://aa.usno.navy.mil/downloads/c15_usb_online.pdf
        Note: Mathematical principles, formulas, algorithms, or equations are not copyrightable. See
          U.S. COPYRIGHT OFFICE, COMPENDIUM OF U.S. COPYRIGHT OFFICE PRACTICES § 313.3(A) (3d ed. 2021).
    */

    DECLARE

      hebrewmonth calendar.hebrewmonth;
      type calendar.type;

      a integer;
      b integer;
      e bigint;
      f bigint;
      g bigint;
      h bigint;
      j bigint;
      k1 bigint;
      z bigint;

    BEGIN

      -- Skip processing for empty values

      IF yearmonthday IS NULL THEN
        RETURN NULL;
      END IF;

      -- Get calendar type

      SELECT * INTO
      type
      FROM calendar.type calendar_type
      WHERE calendar_type.typeid = typeidchar;

      IF type.group IS NULL THEN

        RAISE EXCEPTION 'Calendar not supported';

      ELSIF type.group = 'default' THEN

        RETURN make_date(yearmonthday.year, yearmonthday.month, yearmonthday.day);

      ELSIF type.group = 'hebrew' THEN

        /* 15.11.4 Algorithm 8 */

        a := calendar.hebrewfirst(yearmonthday.year);
        b := calendar.hebrewfirst(yearmonthday.year + 1);
        k1 := b - a - 352 - 27 * (mod(7 * yearmonthday.year + 13, 19)/12);

        /* Begin addition */

        -- Determine if leap year

        SELECT * INTO
        hebrewmonth
        FROM calendar.hebrewmonth
        WHERE hebrewmonth.k = k1
        AND hebrewmonth.m = 13;

        -- If not leap year, shift months down to fill placeholder leap month

        IF hebrewmonth.a IS NULL AND yearmonthday.month > 5 THEN
          yearmonthday.month := yearmonthday.month - 1;
        END IF;

        /* End addition */

        SELECT * INTO
        hebrewmonth
        FROM calendar.hebrewmonth
        WHERE hebrewmonth.k = k1
        -- The algorithm calls for M - 1, but M appears to be correct
        AND hebrewmonth.m = yearmonthday.month;

        j := a + hebrewmonth.a + yearmonthday.day - 1;

      ELSE

        /* 15.11.3 Algorithm 3 */

        h := yearmonthday.month - type.m;
        g := yearmonthday.year + type.y - (type.n - h)/type.n;
        f := mod(h - 1 + type.n, type.n);
        e := (type.p * g + type.q)/type.r + yearmonthday.day - 1 - type.j;

        IF type.group = 'saka' THEN
          z := f/6;
          j := e + ((31 - z) * f + 5 * z)/type.u;
        ELSE
          j := e + (type.s * f + type.t)/type.u;
        END IF;

        IF type.group IN ('gregorian', 'saka') THEN
          j := j - (3 * ((g + type.a)/100))/4 - type.c;
        END IF;

      END IF;

      RETURN ('J' || j)::date;

    END;

$$;

CREATE FUNCTION calendar.historicdatetext(historicdate calendar.historicdate) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts the historicdate type to the serialized calendar.historicdatetext type.
    */

    DECLARE

        -- Intermediate values

        part calendar.part;
        yearmonthday calendar.yearmonthday;
        monthtext text;
        qualifier text;

        -- Final values

        datetext text := '';

    BEGIN

        -- Skip processing for empty values

        IF historicdate IS NULL THEN
          RETURN '';
        END IF;

        -- Convert from date

        yearmonthday := calendar.yearmonthday(historicdate);

        -- Get calendar type

        SELECT *
        INTO part
        FROM calendar.part
        WHERE partid = historicdate.calendar;

        /* YEAR */

        -- Convert qualifier

        SELECT qualifier.qualifierabbreviation
        INTO qualifier
        FROM calendar.qualifier
        WHERE qualifier.qualifierid = historicdate.qualifier;

        IF qualifier IS NULL THEN
          RAISE EXCEPTION 'Invalid qualifier type';
        END IF;

        datetext := datetext || qualifier;

        -- Convert year double (before);
        --   adjust to logical year for double year (before)

        IF historicdate.yeardouble = 'before_implied' THEN
          datetext := datetext || '[';
          yearmonthday.year := yearmonthday.year + 1;
        END IF;

        -- Convert negative years

        IF yearmonthday.year < 0 THEN
          datetext := datetext || 'm';
          yearmonthday.year := abs(yearmonthday.year);
        END IF;

        -- Add year integer

        datetext := datetext || yearmonthday.year::text;

        -- Convert year double (after)

        IF historicdate.yeardouble = 'after' THEN
          datetext := datetext || '*';
        ELSIF historicdate.yeardouble = 'after_implied' THEN
          datetext := datetext || '[';
        END IF;

        /* MONTH */

        datetext := datetext || '-';

        -- Convert precision

        IF historicdate.precision IN ('year') THEN
          datetext := datetext || '~';
        END IF;

        -- Add month name

        SELECT monthshort
        INTO monthtext
        FROM calendar.monthshort
        WHERE monthshort.type = part.monthshorttype
        AND monthshort.monthinteger = yearmonthday.month;

        IF monthtext IS NULL THEN
          RAISE EXCEPTION 'Month does not exist.';
        END IF;

        datetext := datetext || monthtext;

        /* DAY */

        datetext := datetext || '-';

        -- Convert precision (before)

        IF historicdate.precision IN ('month', 'year') THEN
          datetext := datetext || '~';
        END IF;

        -- Add day integer

        datetext := datetext || lpad(yearmonthday.day::text, 2, '0');

        -- Convert precision (after)

        IF historicdate.precision = 'none' THEN
          datetext := datetext || '~';
        END IF;

        -- Add calendar

        datetext := datetext || part.partid;

        /* RETURN */

        RETURN datetext;

    END;

$$;

--
-- CREATE FUNCTIONS
--

CREATE FUNCTION calendar.daterange(historicdaterange calendar.historicdaterange) RETURNS daterange
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    BEGIN

        RETURN daterange((lower(historicdaterange)).gregorian, (upper(historicdaterange)).gregorian);

    END;

$$;

CREATE FUNCTION calendar.historicdate(datetext text) RETURNS calendar.historicdate
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts the serialized historicdatetext type to the historicdate type.
    */

    DECLARE

        -- Intermediate values

        part calendar.part;

        allimprecise boolean := false;
        dayimprecise boolean := false;
        daytext text := '';
        imprecision integer := 0;
        monthdaycheck boolean;
        monthimprecise boolean := false;
        monthtext text := '';
        yearmonthday calendar.yearmonthday;
        yearmultiplier integer := 1;
        yeartext text := '';

        -- Final values

        gregorian date := NULL;
        precision text := 'none';
        qualifier text := '';
        yeardouble text := 'none';
        calendar text := '';

    BEGIN

        -- Skip processing for empty values;
        --   Verify that exactly 3 date segments are present if not empty;
        --   Verify not of historicdaterangetext type

        IF datetext = '' THEN
          RETURN NULL;
        ELSIF length(datetext) - length(replace(datetext, '-', '')) <> 2 THEN
          RAISE EXCEPTION 'Missing date segment';
        ELSIF datetext ~ '[/]' THEN
          RAISE EXCEPTION 'Not historicdatetext type';
        END IF;

        -- Break up date into segments

        yeartext := split_part(datetext, '-', 1);
        monthtext := split_part(datetext, '-', 2);
        daytext := split_part(datetext, '-', 3);

        /* YEAR */

        -- Verify no extra whitespace

        IF yeartext <> trim(yeartext) THEN
          RAISE EXCEPTION 'Extra whitespace in year segment';
        END IF;

        -- Retrieve date qualifier and normalize

        IF left(yeartext, 1) !~ '^(\d|[[!m])$' THEN
          SELECT qualifier.qualifierid
          INTO qualifier
          FROM calendar.qualifier
          WHERE qualifier.qualifierabbreviation = left(yeartext, 1);

          IF qualifier IS NULL THEN
            RAISE EXCEPTION 'Invalid qualifier type';
          END IF;

          yeartext := substring(yeartext FROM 2);
        END IF;

        -- Determine if should be double year (before)

        IF left(yeartext, 1) ~ '^[[]$' THEN
          IF left(yeartext, 1) = '[' THEN
            yeardouble := 'before_implied';
          END IF;
          yeartext := substring(yeartext FROM 2);
        END IF;

        -- Determine if year is negative

        IF left(yeartext, 1) = 'm' THEN
          yearmultiplier := -1;
          yeartext := substring(yeartext FROM 2);
        END IF;

        -- Determine if should be double year (after)

        IF right(yeartext, 1) ~ '^[*[!]$' THEN
          IF yeardouble <> 'none' THEN
            RAISE EXCEPTION 'Year may only have one double character';
          ELSIF right(yeartext, 1) = '*' THEN
            yeardouble := 'after';
          ELSIF right(yeartext, 1) = '[' THEN
            yeardouble := 'after_implied';
          END IF;
          yeartext := substring(yeartext FOR length(yeartext) - 1);
        END IF;

        -- Convert year to integer

        IF yeartext !~ '^[1-9]\d*$' THEN
          RAISE EXCEPTION 'Incorrect year segment format';
        ELSE
          yearmonthday.year := yeartext::integer * yearmultiplier;
        END IF;

        -- Adjust from logical year for double year (before)

        IF yeardouble = 'before_implied' THEN
          yearmonthday.year := yearmonthday.year - 1;
        END IF;

        /* MONTH */

        -- Verify no extra whitespace

        IF monthtext <> trim(monthtext) THEN
          RAISE EXCEPTION 'Extra whitespace in month segment';
        END IF;

        -- Determine if precision month

        IF left(monthtext, 1) = '~' THEN
          monthimprecise := true;
          imprecision := imprecision + 1;
          monthtext := substring(monthtext FROM 2);
        END IF;

        -- Wait to convert month to integer until after calendar conversion

        /* DAY */

        -- Determine if precision day

        IF left(daytext, 1) = '~' THEN
          dayimprecise := true;
          imprecision := imprecision + 1;
          daytext := substring(daytext FROM 2);
        END IF;

        -- Convert day to integer

        IF daytext !~ '^\d{2}' THEN
          RAISE EXCEPTION 'Incorrect numeric day segment format';
        ELSE
          yearmonthday.day := left(daytext, 2)::integer;
          daytext := substring(daytext FROM 3);
        END IF;

        -- Determine if all precision

        IF left(daytext, 1) = '~' THEN
          allimprecise := true;
          imprecision := imprecision + 1;
          daytext := substring(daytext FROM 2);
        END IF;

        -- Change remainder to calendar

        calendar := daytext;

        /* PRECISION */

        -- Assign precision type

        IF imprecision >= 3 OR imprecision < 0 OR (imprecision = 1 AND monthimprecise) OR (imprecision = 2 AND allimprecise) THEN
          RAISE EXCEPTION 'Incorrect approximation format';
        ELSIF imprecision = 0 THEN
          precision := 'day';
        ELSIF imprecision = 2 THEN
          precision := 'year';
        ELSIF dayimprecise THEN
          precision := 'month';
        ELSIF allimprecise THEN
          precision := 'none';
        ELSE
          RAISE EXCEPTION 'Incorrect approximation format';
        END IF;

        /* CALENDAR CONVERSION */

        -- Get calendar type

        SELECT *
        INTO part
        FROM calendar.part
        WHERE partid = calendar;

        IF part.type IS NULL THEN
          RAISE EXCEPTION 'Calendar not supported';
        END IF;

        -- Convert month to integer

        SELECT monthinteger
        INTO yearmonthday.month
        FROM calendar.monthshort
        WHERE monthshort.type = part.monthshorttype
        AND monthshort.monthshort = monthtext;

        IF yearmonthday.month IS NULL THEN
          RAISE EXCEPTION 'Month does not exist.';
        END IF;

        -- Verify if date possible (no leap year check)

        SELECT COALESCE(yearmonthday.day <= monthday.monthday, FALSE)
        INTO monthdaycheck
        FROM calendar.monthday
        WHERE monthday.type = part.monthdaytype
        AND monthday.monthinteger = yearmonthday.month;

        IF NOT monthdaycheck THEN
          RAISE EXCEPTION 'Month-day combination not possible';
        END IF;

        -- Adjust to logical month

        IF part.monthdifference <> 0 THEN
          yearmonthday.month := yearmonthday.month + part.monthdifference;
          IF yearmonthday.month > part.monthmax THEN
            yearmonthday.month := yearmonthday.month - part.monthmax;
          ELSIF yearmonthday.month < 1 THEN
            yearmonthday.month := yearmonthday.month + part.monthmax;
          END IF;
        END IF;

        -- Adjust to logical year for month-day combinations before year start in calendar

        IF part.yearbefore <> 0 AND ((yearmonthday.month < part.monthstart) OR (yearmonthday.month = part.monthstart AND yearmonthday.day < part.daystart)) THEN
          yearmonthday.year := yearmonthday.year + part.yearbefore;
        END IF;

        -- Adjust to logical year for month-day combinations on or after year start in calendar

        IF part.yearafter <> 0 AND ((yearmonthday.month > part.monthstart) OR (yearmonthday.month = part.monthstart AND yearmonthday.day >= part.daystart)) THEN
          yearmonthday.year := yearmonthday.year + part.yearafter;
        END IF;

        -- Convert to date

        gregorian := calendar.date(yearmonthday, part.type);
        IF calendar.yearmonthday(gregorian, part.type) <> yearmonthday THEN
          RAISE EXCEPTION 'Calendar conversion check failed';
        END IF;

        /* RETURN */

        RETURN ROW(
          gregorian,
          precision,
          qualifier,
          yeardouble,
          calendar
        );

    END;

$$;

CREATE FUNCTION calendar.historicdate(monarchname text, regnalyearnumbervalue integer, month integer, day integer, partidvalue text) RETURNS calendar.historicdate
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts a regnal date to the historicdate type.
    */

    DECLARE

        -- Intermediate values

        partvalue calendar.part;
        regnalyearvalue calendar.regnalyear;
        regnalyeardaterange daterange;
        minyear integer;
        maxyear integer;
        comparedate calendar.historicdate;

        -- Final values

        finaldate calendar.historicdate;

    BEGIN

        -- Get regnal year

        SELECT *
        INTO regnalyearvalue
        FROM calendar.regnalyear
        WHERE regnalyear.monarch = monarchname
        AND regnalyear.regnalyearnumber = regnalyearnumbervalue;

        IF regnalyearvalue.regnalyeardaterangetext IS NULL THEN
          RAISE EXCEPTION 'No matching regnal year';
        END IF;

        regnalyeardaterange = regnalyearvalue.regnalyeardaterangetext::calendar.historicdaterange::daterange;

        -- Get calendar type

        SELECT *
        INTO partvalue
        FROM calendar.part
        WHERE part.partid = partidvalue;

        IF partvalue.type IS NULL THEN
          RAISE EXCEPTION 'Calendar not supported';
        END IF;

        -- Get plausible logical or historical years

        minyear := (date_part('year', lower(regnalyeardaterange)))::integer - 2;
        maxyear := (date_part('year', upper(regnalyeardaterange)))::integer + 2;

        -- Loop through possible years to see if any have matching dates

        WHILE minyear <= maxyear LOOP
          comparedate = (minyear || '-' || lpad(month::text, 2, '0') || '-' || lpad(day::text, 2, '0') || partvalue.partid)::calendar.historicdate;
          IF regnalyeardaterange @> comparedate::date THEN
            IF finaldate IS NOT NULL THEN
              RAISE EXCEPTION 'Multiple matching regnal dates';
            ELSE
              finaldate := comparedate;
            END IF;
          END IF;
          minyear := minyear + 1;
        END LOOP;

        -- Return matching date

        IF finaldate IS NULL THEN
          RAISE EXCEPTION 'No matching regnal date';
        ELSE
          RETURN finaldate;
        END IF;

    END;

$$;

CREATE FUNCTION calendar.historicdatetextformat(historicdate calendar.historicdate, formattype text, localecode text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function formats the historicdate type as a full-text date with multilingual support.
        NOTE: Qualifiers only support English.
    */

    DECLARE

        -- Intermediate values

        locale calendar.locale;
        part calendar.part;
        yearmonthday calendar.yearmonthday;
        daytext text := '';
		monthtext text;
        qualifier text;

        -- Final values

        datetext text := '';

    BEGIN

        -- Skip processing for empty values

        IF historicdate IS NULL THEN
          RETURN '';
        END IF;

        -- Convert from date

        yearmonthday := calendar.yearmonthday(historicdate);

        -- Get calendar type

        SELECT *
        INTO part
        FROM calendar.part
        WHERE partid = historicdate.calendar;

        -- Check formattype

        IF formattype NOT IN ('long', 'short') THEN
          RAISE EXCEPTION 'Format not supported';
        END IF;
        
        -- Get locale type

        SELECT *
        INTO locale
        FROM calendar.locale
        WHERE localeid = localecode;

        IF locale.localeid IS NULL THEN
          RAISE EXCEPTION 'Locale not supported';
        END IF;       

        /* MONTH */

        -- Convert precision

        IF historicdate.precision NOT IN ('year') THEN

          -- Add month name

          SELECT CASE
              WHEN formattype = 'short' THEN monthabbreviation
              ELSE monthlong
          END
          INTO monthtext
          FROM calendar.monthlong
          WHERE monthlong.type = part.monthlongtype
          AND monthlong.monthinteger = yearmonthday.month
          AND monthlong.locale = locale.localeid;

          IF monthtext IS NULL THEN
            RAISE EXCEPTION 'Month does not exist.';
          END IF;

          monthtext := monthtext || locale.monthdelimiter || ' ';

        END IF;      

        /* DAY */

        -- Convert precision

        IF historicdate.precision NOT IN ('month', 'year') THEN

          daytext := yearmonthday.day || locale.daysuffix || CASE
              WHEN yearmonthday.day = 1 THEN locale.dayonesuffix
              ELSE ''
          END || locale.daydelimiter || ' ';

          IF locale.dayfirst THEN
            datetext := daytext || monthtext;
          ELSE
            datetext := monthtext || daytext;
          END IF;

        ELSIF monthtext IS NOT NULL THEN

          datetext := monthtext;

        END IF;

        /* YEAR */

        -- Convert qualifier

        SELECT CASE
            WHEN formattype = 'short' AND qualifierlocale.qualifiershort IS NOT NULL THEN qualifierlocale.qualifiershort
            WHEN formattype = 'short' THEN qualifier.qualifiershort
            WHEN formattype = 'long' AND qualifierlocale.qualifierlong IS NOT NULL THEN qualifierlocale.qualifierlong
            ELSE qualifier.qualifierid
        END
        INTO qualifier
        FROM calendar.qualifier
        LEFT JOIN calendar.qualifierlocale
          ON qualifier.qualifierid = qualifierlocale.qualifier
          AND qualifierlocale.locale = locale.localeid
        WHERE qualifier.qualifierid = historicdate.qualifier;

        IF qualifier IS NULL THEN
          RAISE EXCEPTION 'Invalid qualifier type';
        END IF;

        datetext := qualifier || ' ' || datetext;

        -- Adjust from logical year for double year (before);
        --   convert year double (before)

        IF historicdate.yeardouble = 'before_implied' THEN
          yearmonthday.year := yearmonthday.year + 1;
          datetext := datetext || '[' || (yearmonthday.year - 1)::text || '/]';
        END IF;

        -- Add year integer

        datetext := datetext || yearmonthday.year::text;

        -- Convert year double (after)

        IF historicdate.yeardouble LIKE 'after%' THEN
          IF historicdate.yeardouble = 'after_implied' THEN
            datetext := datetext || '[';
          END IF;
          datetext := datetext || '/' || (yearmonthday.year + 1)::text;
          IF historicdate.yeardouble = 'after_implied' THEN
            datetext := datetext || ']';
          END IF;
        END IF;

        -- Trim

        datetext := trim(datetext);

        -- Convert precision (after)

        IF historicdate.precision = 'none' THEN
          datetext := '~ ' || datetext;
        END IF;

        /* RETURN */

        RETURN datetext;

    END;

$$;

CREATE FUNCTION calendar.historicdaterange(daterangetext text) RETURNS calendar.historicdaterange
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts the serialized historicdaterangetext type to the historicdaterange type.
    */

    DECLARE

      fromhistoricdatetext text;
      fromhistoricdate calendar.historicdate;
      tohistoricdatetext text;
      tohistoricdate calendar.historicdate;
      isinstant boolean := FALSE;

    BEGIN

      -- Skip processing for empty values

      IF daterangetext = '' THEN
        RETURN NULL;
      END IF;

      -- Verify that appropriate date range segments are present

      IF length(daterangetext) - length(replace(daterangetext, '/', '')) > 1 THEN
        RAISE EXCEPTION 'Extra date range segment';
      ELSIF length(daterangetext) - length(replace(daterangetext, '/', '')) = 0 THEN
        daterangetext := daterangetext || '/' || daterangetext;
        isinstant = TRUE;
      ELSIF split_part(daterangetext, '/', 1) = split_part(daterangetext, '/', 2) THEN
        RAISE EXCEPTION 'Date range instant formatted incorrectly';
      END IF;

      -- Break up date into segments

      fromhistoricdatetext := split_part(daterangetext, '/', 1);
      tohistoricdatetext := split_part(daterangetext, '/', 2);

      -- Convert segments into historicdate type

      fromhistoricdate := calendar.historicdate(fromhistoricdatetext);
      tohistoricdate := calendar.historicdate(tohistoricdatetext);

      -- Check identical dates in ranges;
      --   add from and to qualifiers for ranges

      IF NOT isinstant AND fromhistoricdate IS NOT NULL AND tohistoricdate IS NOT NULL THEN
        IF fromhistoricdate.gregorian = tohistoricdate.gregorian THEN
          RAISE EXCEPTION 'Instant should not be expressed as a range';
        ELSIF fromhistoricdate.qualifier = '' AND tohistoricdate.qualifier = '' THEN
          fromhistoricdate.qualifier = 'from';
          tohistoricdate.qualifier = 'to';
        END IF;
      END IF;

      -- Add extra day to tohistoricdate

      IF tohistoricdate IS NOT NULL THEN
        tohistoricdate.gregorian := tohistoricdate.gregorian + 1;
      END IF;

      -- Before

      IF isinstant AND fromhistoricdate IS NOT NULL AND fromhistoricdate.qualifier = 'before' AND tohistoricdate IS NOT NULL AND tohistoricdate.qualifier = 'before' THEN
        fromhistoricdate := ROW(
	      '-infinity'::date,
	      fromhistoricdate."precision",
	      '',
	      fromhistoricdate.yeardouble,
	      fromhistoricdate.calendar
        );
      END IF;

      -- After

      IF isinstant AND fromhistoricdate IS NOT NULL AND fromhistoricdate.qualifier = 'after' AND tohistoricdate IS NOT NULL AND tohistoricdate.qualifier = 'after' THEN
        tohistoricdate := ROW(
	      'infinity'::date,
	      tohistoricdate."precision",
	      '',
	      tohistoricdate.yeardouble,
	      tohistoricdate.calendar
        );
      END IF;

      -- Check date order

      IF fromhistoricdate IS NOT NULL AND tohistoricdate IS NOT NULL AND fromhistoricdate.gregorian >= tohistoricdate.gregorian THEN
        RAISE EXCEPTION 'From date after before date';
      ELSIF NOT (
        (NOT isinstant AND fromhistoricdate.qualifier = 'between' AND tohistoricdate.qualifier = 'and') OR
        (NOT isinstant AND fromhistoricdate.qualifier = 'from' AND tohistoricdate.qualifier = 'to') OR
        (isinstant AND fromhistoricdate.qualifier = '' AND fromhistoricdate.gregorian = '-infinity' AND tohistoricdate.qualifier = 'before') OR
        (isinstant AND fromhistoricdate.qualifier = 'after' AND tohistoricdate.qualifier = '' AND tohistoricdate.gregorian = 'infinity') OR
        (isinstant AND fromhistoricdate.qualifier = '' AND tohistoricdate.qualifier = '')
      ) THEN
        RAISE EXCEPTION 'Qualifier mismatch';
      END IF;

      /* RETURN */

      RETURN calendar.historicdaterange(
        fromhistoricdate,
        tohistoricdate
      );

    END;

$$;

CREATE FUNCTION calendar.historicdaterangetext(historicdaterange calendar.historicdaterange) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts the historicdaterange type to the serialized historicdaterangetext type.
    */

    DECLARE

      fromhistoricdate calendar.historicdate;
      tohistoricdate calendar.historicdate;
      fromtext text;
      totext text;

    BEGIN

      -- Skip processing for empty values

      IF historicdaterange IS NULL THEN
        RETURN '';
      END IF;

      -- Extract historicdate types

      fromhistoricdate = lower(historicdaterange);
      tohistoricdate = upper(historicdaterange);

      -- Remove extra day from tohistoricdate

      IF tohistoricdate.gregorian IS NOT NULL THEN
        tohistoricdate.gregorian := tohistoricdate.gregorian - 1;
      END IF;

      -- Convert parts to text;
      --   skip processing of infinity dates

      IF tohistoricdate.qualifier <> 'before' THEN
        fromtext = calendar.historicdatetext(fromhistoricdate);
      END IF;

      IF fromhistoricdate.qualifier <> 'after' THEN
        totext = calendar.historicdatetext(tohistoricdate);
      END IF;

      IF (fromhistoricdate.qualifier = '' AND tohistoricdate.qualifier = '') OR fromhistoricdate.qualifier = 'after' THEN
        RETURN fromtext;
      ELSIF tohistoricdate.qualifier = 'before' THEN
        RETURN totext;
      ELSE
        RETURN fromtext || '/' || totext;
      END IF;

    END;

$$;

CREATE FUNCTION calendar.historicdaterangetextformat(historicdaterange calendar.historicdaterange, formattype text, localecode text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function formats the historicdaterange type as a full-text date with multilingual support.
        NOTE: Qualifiers only support English.
    */

    DECLARE

      fromhistoricdate calendar.historicdate;
      tohistoricdate calendar.historicdate;
      fromtext text;
      totext text;

    BEGIN

      -- Skip processing for empty values

      IF historicdaterange IS NULL THEN
        RETURN '';
      END IF;

      -- Extract historicdate types

      fromhistoricdate = lower(historicdaterange);
      tohistoricdate = upper(historicdaterange);

      -- Remove extra day from tohistoricdate

      IF tohistoricdate.gregorian IS NOT NULL THEN
        tohistoricdate.gregorian := tohistoricdate.gregorian - 1;
      END IF;

      -- Convert parts to text;
      --   skip processing of infinity dates

      IF tohistoricdate.qualifier <> 'before' THEN
        fromtext = calendar.historicdatetextformat(fromhistoricdate, formattype, localecode);
      END IF;

      IF fromhistoricdate.qualifier <> 'after' THEN
        totext = calendar.historicdatetextformat(tohistoricdate, formattype, localecode);
      END IF;

      IF (fromhistoricdate.qualifier = '' AND tohistoricdate.qualifier = '') OR fromhistoricdate.qualifier = 'after' THEN
        RETURN fromtext;
      ELSIF tohistoricdate.qualifier = 'before' THEN
        RETURN totext;
      ELSE
        RETURN fromtext || ' ' || totext;
      END IF;

    END;

$$;

CREATE FUNCTION calendar.regnalyeartext(historicdate calendar.historicdate) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

    /*
        This function converts a historicdate type to a regnal date.
    */

    DECLARE

        -- Intermediate values

        regnalyearcursor refcursor;
        regnalyearcount integer := 0;
        lastregnalyearrow calendar.regnalyear;
        regnalyearrow calendar.regnalyear;

    BEGIN

        -- Get regnal year

        OPEN regnalyearcursor FOR
        SELECT *
        FROM calendar.regnalyear
        WHERE regnalyear.regnalyeardaterangetext::calendar.historicdaterange::daterange @> historicdate::date;

        -- Determine how many regnal years returned

        LOOP
          lastregnalyearrow := regnalyearrow;

          FETCH regnalyearcursor INTO regnalyearrow;

          IF NOT FOUND THEN
            EXIT;
          END IF;

          regnalyearcount := regnalyearcount + 1;
        END LOOP;

        -- Return regnal year if only 1;
        --   otherwise, return blank

        IF regnalyearcount = 0 THEN
          -- No matching regnal year
          RETURN '';
        ELSIF regnalyearcount > 1 THEN
          -- Multiple matching regnal years
          RETURN '';
        ELSE
          RETURN lastregnalyearrow.regnalyearnumber::text || ' ' || lastregnalyearrow.monarch;
        END IF;

    END;

$$;

--
-- INSERT TABLE DATA
--

INSERT INTO calendar.hebrewmonth VALUES 
(1, 1, 0),
(1, 2, 30),
(1, 3, 59),
(1, 4, 88),
(1, 5, 117),
(1, 6, 147),
(1, 7, 176),
(1, 8, 206),
(1, 9, 235),
(1, 10, 265),
(1, 11, 294),
(1, 12, 324),
(2, 1, 0),
(2, 2, 30),
(2, 3, 59),
(2, 4, 89),
(2, 5, 118),
(2, 6, 148),
(2, 7, 177),
(2, 8, 207),
(2, 9, 236),
(2, 10, 266),
(2, 11, 295),
(2, 12, 325),
(3, 1, 0),
(3, 2, 30),
(3, 3, 60),
(3, 4, 90),
(3, 5, 119),
(3, 6, 149),
(3, 7, 178),
(3, 8, 208),
(3, 9, 237),
(3, 10, 267),
(3, 11, 296),
(3, 12, 326),
(4, 1, 0),
(4, 2, 30),
(4, 3, 59),
(4, 4, 88),
(4, 5, 117),
(4, 6, 147),
(4, 7, 177),
(4, 8, 206),
(4, 9, 236),
(4, 10, 265),
(4, 11, 295),
(4, 12, 324),
(4, 13, 354),
(5, 1, 0),
(5, 2, 30),
(5, 3, 59),
(5, 4, 89),
(5, 5, 118),
(5, 6, 148),
(5, 7, 178),
(5, 8, 207),
(5, 9, 237),
(5, 10, 266),
(5, 11, 296),
(5, 12, 325),
(5, 13, 355),
(6, 1, 0),
(6, 2, 30),
(6, 3, 60),
(6, 4, 90),
(6, 5, 119),
(6, 6, 149),
(6, 7, 179),
(6, 8, 208),
(6, 9, 238),
(6, 10, 267),
(6, 11, 297),
(6, 12, 326),
(6, 13, 356);

INSERT INTO calendar.locale VALUES
('ar', true, '', '', '', ''),
('cs', true, '.', '', '', ''),
('cy', true, '', '', '', ''),
('da', true, '.', '', '', ''),
('de', true, '.', '', '', ''),
('en', false, '', ',', '', ''),
('es', true, '', ' de', ' de', ''),
('fr', true, '', '', '', 'er'),
('ga', true, '', '', '', ''),
('he', true, '', '', '', ''),
('it', true, '', '', '', 'º'),
('la', true, '', '', '', ''),
('nl', true, '', '', '', ''),
('no', true, '.', '', '', ''),
('pl', true, '', '', '', ''),
('pt', true, '', ' de', ' de', ''),
('sv', true, '', '', '', '');

INSERT INTO calendar.monthday VALUES 
('B', 1, 19),
('B', 2, 19),
('B', 3, 19),
('B', 4, 19),
('B', 5, 19),
('B', 6, 19),
('B', 7, 19),
('B', 8, 19),
('B', 9, 19),
('B', 10, 19),
('B', 11, 19),
('B', 12, 19),
('B', 13, 19),
('B', 14, 19),
('B', 15, 19),
('B', 16, 19),
('B', 17, 19),
('B', 18, 19),
('B', 19, 5),
('B', 20, 19),
('C', 1, 30),
('C', 2, 30),
('C', 3, 30),
('C', 4, 30),
('C', 5, 30),
('C', 6, 30),
('C', 7, 30),
('C', 8, 30),
('C', 9, 30),
('C', 10, 30),
('C', 11, 30),
('C', 12, 30),
('C', 13, 6),
('E', 1, 30),
('E', 2, 30),
('E', 3, 30),
('E', 4, 30),
('E', 5, 30),
('E', 6, 30),
('E', 7, 30),
('E', 8, 30),
('E', 9, 30),
('E', 10, 30),
('E', 11, 30),
('E', 12, 30),
('E', 13, 5),
('F', 1, 30),
('F', 2, 30),
('F', 3, 30),
('F', 4, 30),
('F', 5, 30),
('F', 6, 30),
('F', 7, 30),
('F', 8, 30),
('F', 9, 30),
('F', 10, 30),
('F', 11, 30),
('F', 12, 30),
('F', 13, 6),
('G', 1, 31),
('G', 2, 29),
('G', 3, 31),
('G', 4, 30),
('G', 5, 31),
('G', 6, 30),
('G', 7, 31),
('G', 8, 31),
('G', 9, 30),
('G', 10, 31),
('G', 11, 30),
('G', 12, 31),
('H', 1, 30),
('H', 2, 30),
('H', 3, 30),
('H', 4, 29),
('H', 5, 30),
('H', 6, 30),
('H', 7, 29),
('H', 8, 30),
('H', 9, 29),
('H', 10, 30),
('H', 11, 29),
('H', 12, 30),
('H', 13, 29),
('I', 1, 30),
('I', 2, 30),
('I', 3, 30),
('I', 4, 30),
('I', 5, 30),
('I', 6, 30),
('I', 7, 30),
('I', 8, 30),
('I', 9, 30),
('I', 10, 30),
('I', 11, 30),
('I', 12, 30),
('Q', 1, 31),
('Q', 2, 30),
('Q', 3, 31),
('Q', 4, 30),
('Q', 5, 31),
('Q', 6, 31),
('Q', 7, 30),
('Q', 8, 31),
('Q', 9, 30),
('Q', 10, 31),
('Q', 11, 31),
('Q', 12, 29),
('S', 1, 31),
('S', 2, 31),
('S', 3, 31),
('S', 4, 31),
('S', 5, 31),
('S', 6, 31),
('S', 7, 30),
('S', 8, 30),
('S', 9, 30),
('S', 10, 30),
('S', 11, 30),
('S', 12, 30),
('T', 1, 30),
('T', 2, 30),
('T', 3, 30),
('T', 4, 30),
('T', 5, 30),
('T', 6, 30),
('T', 7, 30),
('T', 8, 30),
('T', 9, 30),
('T', 10, 30),
('T', 11, 30),
('T', 12, 30),
('T', 13, 6);

INSERT INTO calendar.monthlong VALUES 
('F', 'fr', 1, 'vendémiaire', 'vendémiaire'),
('F', 'fr', 2, 'brumaire', 'brumaire'),
('F', 'fr', 3, 'frimaire', 'frimaire'),
('F', 'fr', 4, 'nivôse', 'nivôse'),
('F', 'fr', 5, 'pluviôse', 'pluviôse'),
('F', 'fr', 6, 'ventôse', 'ventôse'),
('F', 'fr', 7, 'germinal', 'germinal'),
('F', 'fr', 8, 'floréal', 'floréal'),
('F', 'fr', 9, 'prairial', 'prairial'),
('F', 'fr', 10, 'messidor', 'messidor'),
('F', 'fr', 11, 'thermidor', 'thermidor'),
('F', 'fr', 12, 'fructidor', 'fructidor'),
('F', 'fr', 13, 'jours complémentaires', 'jours complémentaires'),
('G', 'cs', 1, 'leden', 'led.'),
('G', 'cs', 2, 'únor', 'ún.'),
('G', 'cs', 3, 'březen', 'břez.'),
('G', 'cs', 4, 'duben', 'dub.'),
('G', 'cs', 5, 'květen', 'květ.'),
('G', 'cs', 6, 'červen', 'červ.'),
('G', 'cs', 7, 'červenec', 'červen.'),
('G', 'cs', 8, 'srpen', 'srp.'),
('G', 'cs', 9, 'září', 'září'),
('G', 'cs', 10, 'říjen', 'řij.'),
('G', 'cs', 11, 'listopad', 'list.'),
('G', 'cs', 12, 'prosinec', 'pros.'),
('G', 'cy', 1, 'Ionawr', 'Ion.'),
('G', 'cy', 2, 'Chwefror', 'Chwef.'),
('G', 'cy', 3, 'Mawrth', 'Maw.'),
('G', 'cy', 4, 'Ebrill', 'Ebr.'),
('G', 'cy', 5, 'Mai', 'Mai'),
('G', 'cy', 6, 'Mehefin', 'Meh.'),
('G', 'cy', 7, 'Gorffennaf', 'Gorff.'),
('G', 'cy', 8, 'Awst', 'Awst'),
('G', 'cy', 9, 'Medi', 'Medi'),
('G', 'cy', 10, 'Hydref', 'Hyd.'),
('G', 'cy', 11, 'Tachwedd', 'Tach.'),
('G', 'cy', 12, 'Rhagfyr', 'Rhag.'),
('G', 'da', 1, 'januar', 'jan.'),
('G', 'da', 2, 'februar', 'febr.'),
('G', 'da', 3, 'marts', 'marts'),
('G', 'da', 4, 'april', 'april'),
('G', 'da', 5, 'maj', 'maj'),
('G', 'da', 6, 'juni', 'juni'),
('G', 'da', 7, 'juli', 'juli'),
('G', 'da', 8, 'august', 'aug.'),
('G', 'da', 9, 'september', 'sept.'),
('G', 'da', 10, 'oktober', 'okt.'),
('G', 'da', 11, 'november', 'nov.'),
('G', 'da', 12, 'december', 'dec.'),
('G', 'de', 1, 'Januar', 'Jan.'),
('G', 'de', 2, 'Februar', 'Feb.'),
('G', 'de', 3, 'März', 'März'),
('G', 'de', 4, 'April', 'Apr.'),
('G', 'de', 5, 'Mai', 'Mai'),
('G', 'de', 6, 'Juni', 'Juni'),
('G', 'de', 7, 'Juli', 'Juli'),
('G', 'de', 8, 'August', 'Aug.'),
('G', 'de', 9, 'September', 'Sept.'),
('G', 'de', 10, 'Oktober', 'Okt.'),
('G', 'de', 11, 'November', 'Nov.'),
('G', 'de', 12, 'Dezember', 'Dez.'),
('G', 'en', 1, 'January', 'Jan.'),
('G', 'en', 2, 'February', 'Feb.'),
('G', 'en', 3, 'March', 'Mar.'),
('G', 'en', 4, 'April', 'Apr.'),
('G', 'en', 5, 'May', 'May'),
('G', 'en', 6, 'June', 'June'),
('G', 'en', 7, 'July', 'July'),
('G', 'en', 8, 'August', 'Aug.'),
('G', 'en', 9, 'September', 'Sept.'),
('G', 'en', 10, 'October', 'Oct.'),
('G', 'en', 11, 'November', 'Nov.'),
('G', 'en', 12, 'December', 'Dec.'),
('G', 'es', 1, 'enero', 'enero'),
('G', 'es', 2, 'febrero', 'feb.'),
('G', 'es', 3, 'marzo', 'marzo'),
('G', 'es', 4, 'abril', 'abr.'),
('G', 'es', 5, 'mayo', 'mayo'),
('G', 'es', 6, 'junio', 'jun.'),
('G', 'es', 7, 'julio', 'jul.'),
('G', 'es', 8, 'agosto', 'agosto'),
('G', 'es', 9, 'septiembre', 'sept.'),
('G', 'es', 10, 'octubre', 'oct.'),
('G', 'es', 11, 'noviembre', 'nov.'),
('G', 'es', 12, 'diciembre', 'dic.'),
('G', 'fr', 1, 'janvier', 'janv.'),
('G', 'fr', 2, 'février', 'févr.'),
('G', 'fr', 3, 'mars', 'mars'),
('G', 'fr', 4, 'avril', 'avril'),
('G', 'fr', 5, 'mai', 'mai'),
('G', 'fr', 6, 'juin', 'juin'),
('G', 'fr', 7, 'juillet', 'juil.'),
('G', 'fr', 8, 'août', 'août'),
('G', 'fr', 9, 'septembre', 'sept.'),
('G', 'fr', 10, 'octobre', 'oct.'),
('G', 'fr', 11, 'novembre', 'nov.'),
('G', 'fr', 12, 'décembre', 'déc.'),
('G', 'ga', 1, 'Eanáir', 'Eanáir'),
('G', 'ga', 2, 'Feabhra', 'Feabhra'),
('G', 'ga', 3, 'Márta', 'Márta'),
('G', 'ga', 4, 'Aibreán', 'Aibreán'),
('G', 'ga', 5, 'Bealtaine', 'Bealtaine'),
('G', 'ga', 6, 'Meitheamh', 'Meitheamh'),
('G', 'ga', 7, 'Iúil', 'Iúil'),
('G', 'ga', 8, 'Lúnasa', 'Lúnasa'),
('G', 'ga', 9, 'Meán Fómhair', 'Meán Fómhair'),
('G', 'ga', 10, 'Deireadh Fómhair', 'Deireadh Fómhair'),
('G', 'ga', 11, 'Samhain', 'Samhain'),
('G', 'ga', 12, 'Nollaig', 'Nollaig'),
('G', 'it', 1, 'gennaio', 'genn.'),
('G', 'it', 2, 'febbraio', 'febbr.'),
('G', 'it', 3, 'marzo', 'mar.'),
('G', 'it', 4, 'aprile', 'apr.'),
('G', 'it', 5, 'maggio', 'magg.'),
('G', 'it', 6, 'giugno', 'giugno'),
('G', 'it', 7, 'luglio', 'luglio'),
('G', 'it', 8, 'agosto', 'ag.'),
('G', 'it', 9, 'settembre', 'sett.'),
('G', 'it', 10, 'ottobre', 'ott.'),
('G', 'it', 11, 'novembre', 'nov.'),
('G', 'it', 12, 'dicembre', 'dic.'),
('G', 'la', 1, 'Ianuarius', 'Ian.'),
('G', 'la', 2, 'Februarius', 'Febr.'),
('G', 'la', 3, 'Martius', 'Mart.'),
('G', 'la', 4, 'Aprilis', 'Apr.'),
('G', 'la', 5, 'Maius', 'Mai'),
('G', 'la', 6, 'Iunius', 'Iun.'),
('G', 'la', 7, 'Iulius', 'Iul.'),
('G', 'la', 8, 'Augustus', 'Aug.'),
('G', 'la', 9, 'September', 'Sept.'),
('G', 'la', 10, 'October', 'Oct.'),
('G', 'la', 11, 'November', 'Nov.'),
('G', 'la', 12, 'December', 'Dec.'),
('G', 'nl', 1, 'januari', 'jan.'),
('G', 'nl', 2, 'februari', 'feb.'),
('G', 'nl', 3, 'maart', 'maart'),
('G', 'nl', 4, 'april', 'apr.'),
('G', 'nl', 5, 'mei', 'mei'),
('G', 'nl', 6, 'juni', 'juni'),
('G', 'nl', 7, 'juli', 'juli'),
('G', 'nl', 8, 'augustus', 'aug.'),
('G', 'nl', 9, 'september', 'sept.'),
('G', 'nl', 10, 'oktober', 'oct.'),
('G', 'nl', 11, 'november', 'nov.'),
('G', 'nl', 12, 'december', 'dec.'),
('G', 'no', 1, 'januar', 'jan.'),
('G', 'no', 2, 'februar', 'febr.'),
('G', 'no', 3, 'mars', 'mars'),
('G', 'no', 4, 'april', 'april'),
('G', 'no', 5, 'mai', 'mai'),
('G', 'no', 6, 'juni', 'juni'),
('G', 'no', 7, 'juli', 'juli'),
('G', 'no', 8, 'august', 'aug.'),
('G', 'no', 9, 'september', 'sept.'),
('G', 'no', 10, 'oktober', 'okt.'),
('G', 'no', 11, 'november', 'nov.'),
('G', 'no', 12, 'desember', 'des.'),
('G', 'pl', 1, 'styczeń', 'stycz.'),
('G', 'pl', 2, 'luty', 'luty'),
('G', 'pl', 3, 'marzec', 'mar.'),
('G', 'pl', 4, 'kwiecień', 'kwiec.'),
('G', 'pl', 5, 'maj', 'maj'),
('G', 'pl', 6, 'czerwiec', 'czerw.'),
('G', 'pl', 7, 'lipiec', 'lip.'),
('G', 'pl', 8, 'sierpień', 'sierp.'),
('G', 'pl', 9, 'wrzesień', 'wrzes.'),
('G', 'pl', 10, 'październik', 'paźdz.'),
('G', 'pl', 11, 'listopad', 'listop.'),
('G', 'pl', 12, 'grudzień', 'grudz.'),
('G', 'pt', 1, 'janeiro', 'jan.'),
('G', 'pt', 2, 'fevereiro', 'fev.'),
('G', 'pt', 3, 'março', 'março'),
('G', 'pt', 4, 'abril', 'abril'),
('G', 'pt', 5, 'maio', 'maio'),
('G', 'pt', 6, 'junho', 'junho'),
('G', 'pt', 7, 'julho', 'julho'),
('G', 'pt', 8, 'agosto', 'agosto'),
('G', 'pt', 9, 'setembro', 'set.'),
('G', 'pt', 10, 'outubro', 'out.'),
('G', 'pt', 11, 'novembro', 'nov.'),
('G', 'pt', 12, 'dezembro', 'dez.'),
('G', 'sv', 1, 'januari', 'jan.'),
('G', 'sv', 2, 'februari', 'febr.'),
('G', 'sv', 3, 'mars', 'mars'),
('G', 'sv', 4, 'april', 'april'),
('G', 'sv', 5, 'maj', 'maj'),
('G', 'sv', 6, 'juni', 'juni'),
('G', 'sv', 7, 'juli', 'juli'),
('G', 'sv', 8, 'augusti', 'aug.'),
('G', 'sv', 9, 'september', 'sept.'),
('G', 'sv', 10, 'oktober', 'okt.'),
('G', 'sv', 11, 'november', 'nov.'),
('G', 'sv', 12, 'december', 'dec.'),
('Q', 'en', 1, 'First Month', '1 mo.'),
('Q', 'en', 2, 'Second Month', '2 mo.'),
('Q', 'en', 3, 'Third Month', '3 mo.'),
('Q', 'en', 4, 'Fourth Month', '4 mo.'),
('Q', 'en', 5, 'Fifth Month', '5 mo.'),
('Q', 'en', 6, 'Sixth Month', '6 mo.'),
('Q', 'en', 7, 'Seventh Month', '7 mo.'),
('Q', 'en', 8, 'Eighth Month', '8 mo.'),
('Q', 'en', 9, 'Ninth Month', '9 mo.'),
('Q', 'en', 10, 'Tenth Month', '10 mo.'),
('Q', 'en', 11, 'Eleventh Month', '11 mo.'),
('Q', 'en', 12, 'Twelfth Month', '12 mo.'),
('H', 'en', 8, 'Nisan', 'Nisan'),
('H', 'en', 9, 'Iyar', 'Iyar'),
('H', 'en', 10, 'Sivan', 'Sivan'),
('H', 'en', 11, 'Tammuz', 'Tammuz'),
('H', 'en', 12, 'Av', 'Av'),
('H', 'en', 13, 'Elul', 'Elul'),
('H', 'en', 1, 'Tishrei', 'Tishrei'),
('H', 'en', 2, 'Cheshvan', 'Cheshvan'),
('H', 'en', 3, 'Kislev', 'Kislev'),
('H', 'en', 4, 'Tevet', 'Tevet'),
('H', 'en', 5, 'Shevat', 'Shevat'),
('H', 'en', 6, 'Adar I', 'Adar I'),
('H', 'en', 7, 'Adar II', 'Adar II'),
('H', 'he', 8, 'ניסן', 'ניסן'),
('H', 'he', 9, 'אייר', 'אייר'),
('H', 'he', 10, 'סיוון', 'סיוון'),
('H', 'he', 11, 'תמוז', 'תמוז'),
('H', 'he', 12, 'אב', 'אב'),
('H', 'he', 13, 'אלול', 'אלול'),
('H', 'he', 1, 'תשרי', 'תשרי'),
('H', 'he', 2, 'חשוון', 'חשוון'),
('H', 'he', 3, 'כסלו', 'כסלו'),
('H', 'he', 4, 'טבת', 'טבת'),
('H', 'he', 5, 'שבט', 'שבט'),
('H', 'he', 6, '''אדר א', '''אדר א'),
('H', 'he', 7, '''אדר ב', '''אדר ב'),
('I', 'en', 1, 'Muharram', 'Muharram'),
('I', 'en', 2, 'Safar', 'Safar'),
('I', 'en', 3, 'Rabi'' al-Awwal', 'Rabi'' al-Awwal'),
('I', 'en', 4, 'Rabi'' al-Thani', 'Rabi'' al-Thani'),
('I', 'en', 5, 'Jumada al-Awwal', 'Jumada al-Awwal'),
('I', 'en', 6, 'Jumada al-Thani', 'Jumada al-Thani'),
('I', 'en', 7, 'Rajab', 'Rajab'),
('I', 'en', 8, 'Sha''ban', 'Sha''ban'),
('I', 'en', 9, 'Ramadan', 'Ramadan'),
('I', 'en', 10, 'Shawwal', 'Shawwal'),
('I', 'en', 11, 'Dhu al-Qadah', 'Dhu al-Qadah'),
('I', 'en', 12, 'Dhu al-Hijja', 'Dhu al-Hijja'),
('I', 'ar', 1, 'محرم', 'محرم'),
('I', 'ar', 2, 'صفر', 'صفر'),
('I', 'ar', 3, 'ربيع الأول', 'ربيع الأول'),
('I', 'ar', 4, 'ربيع الآخر', 'ربيع الآخر'),
('I', 'ar', 5, 'جمادى الأولى', 'جمادى الأولى'),
('I', 'ar', 6, 'جمادى الآخرة', 'جمادى الآخرة'),
('I', 'ar', 7, 'رجب', 'رجب'),
('I', 'ar', 8, 'شعبان', 'شعبان'),
('I', 'ar', 9, 'رمضان', 'رمضان'),
('I', 'ar', 10, 'شوال', 'شوال'),
('I', 'ar', 11, 'ذو القعدة', 'ذو القعدة'),
('I', 'ar', 12, 'ذو الحجة', 'ذو الحجة'),
('S', 'en', 1, 'Chaitra', 'Chaitra'),
('S', 'en', 2, 'Vaisakha', 'Vaisakha'),
('S', 'en', 3, 'Jyeshtha', 'Jyeshtha'),
('S', 'en', 4, 'Ashadha', 'Ashadha'),
('S', 'en', 5, 'Shraavana', 'Shraavana'),
('S', 'en', 6, 'Bhadra', 'Bhadra'),
('S', 'en', 7, 'Ashvin', 'Ashvin'),
('S', 'en', 8, 'Kartika', 'Kartika'),
('S', 'en', 9, 'Agrahayana', 'Agrahayana'),
('S', 'en', 10, 'Pausha', 'Pausha'),
('S', 'en', 11, 'Magha', 'Magha'),
('S', 'en', 12, 'Phalguna', 'Phalguna'),
('B', 'en', 1, 'Bahá', 'Bahá'),
('B', 'en', 2, 'Jalál', 'Jalál'),
('B', 'en', 3, 'Jamál', 'Jamál'),
('B', 'en', 4, 'ʻAẓamat', 'ʻAẓamat'),
('B', 'en', 5, 'Núr', 'Núr'),
('B', 'en', 6, 'Raḥmat', 'Raḥmat'),
('B', 'en', 7, 'Kalimát', 'Kalimát'),
('B', 'en', 8, 'Kamál', 'Kamál'),
('B', 'en', 9, 'Asmáʼ', 'Asmáʼ'),
('B', 'en', 10, 'ʻIzzat', 'ʻIzzat'),
('B', 'en', 11, 'Mas͟híyyat', 'Mas͟híyyat'),
('B', 'en', 12, 'ʻIlm', 'ʻIlm'),
('B', 'en', 13, 'Qudrat', 'Qudrat'),
('B', 'en', 14, 'Qawl', 'Qawl'),
('B', 'en', 15, 'Masáʼil', 'Masáʼil'),
('B', 'en', 16, 'S͟haraf', 'S͟haraf'),
('B', 'en', 17, 'Sulṭán', 'Sulṭán'),
('B', 'en', 18, 'Mulk', 'Mulk'),
('B', 'en', 19, 'Ayyám-i-Há', 'Ayyám-i-Há'),
('B', 'en', 20, 'ʻAláʼ', 'ʻAláʼ'),
('B', 'ar', 1, 'بهاء', 'بهاء'),
('B', 'ar', 2, 'جلال', 'جلال'),
('B', 'ar', 3, 'جمال', 'جمال'),
('B', 'ar', 4, 'عظمة', 'عظمة'),
('B', 'ar', 5, 'نور', 'نور'),
('B', 'ar', 6, 'رحمة', 'رحمة'),
('B', 'ar', 7, 'كلمات', 'كلمات'),
('B', 'ar', 8, 'كمال', 'كمال'),
('B', 'ar', 9, 'اسماء', 'اسماء'),
('B', 'ar', 10, 'عزة', 'عزة'),
('B', 'ar', 11, 'مشية', 'مشية'),
('B', 'ar', 12, 'علم', 'علم'),
('B', 'ar', 13, 'قدرة', 'قدرة'),
('B', 'ar', 14, 'قول', 'قول'),
('B', 'ar', 15, 'مسائل', 'مسائل'),
('B', 'ar', 16, 'شرف', 'شرف'),
('B', 'ar', 17, 'سلطان', 'سلطان'),
('B', 'ar', 18, 'ملك', 'ملك'),
('B', 'ar', 19, 'ايام الهاء', 'ايام الهاء'),
('B', 'ar', 20, 'علاء', 'علاء'),
('C', 'en', 1, 'Thout', 'Thout'),
('C', 'en', 2, 'Paopi', 'Paopi'),
('C', 'en', 3, 'Hathor', 'Hathor'),
('C', 'en', 4, 'Koiak', 'Koiak'),
('C', 'en', 5, 'Tobi', 'Tobi'),
('C', 'en', 6, 'Meshir', 'Meshir'),
('C', 'en', 7, 'Paremhat', 'Paremhat'),
('C', 'en', 8, 'Parmouti', 'Parmouti'),
('C', 'en', 9, 'Pashons', 'Pashons'),
('C', 'en', 10, 'Paoni', 'Paoni'),
('C', 'en', 11, 'Epip', 'Epip'),
('C', 'en', 12, 'Mesori', 'Mesori'),
('C', 'en', 13, 'Pi Kogi Enavot', 'Pi Kogi Enavot'),
('T', 'en', 1, 'Mäskäräm', 'Mäskäräm'),
('T', 'en', 2, 'Ṭəqəmt', 'Ṭəqəmt'),
('T', 'en', 3, 'Ḫədar', 'Ḫədar'),
('T', 'en', 4, 'Taḫśaś', 'Taḫśaś'),
('T', 'en', 5, 'Ṭərr', 'Ṭərr'),
('T', 'en', 6, 'Yäkatit', 'Yäkatit'),
('T', 'en', 7, 'Mägabit', 'Mägabit'),
('T', 'en', 8, 'Miyazya', 'Miyazya'),
('T', 'en', 9, 'Gənbo', 'Gənbo'),
('T', 'en', 10, 'Säne', 'Säne'),
('T', 'en', 11, 'Ḥamle', 'Ḥamle'),
('T', 'en', 12, 'Nähase', 'Nähase'),
('T', 'en', 13, 'Ṗagʷəmen', 'Ṗagʷəmen'),
('E', 'en', 1, 'Thoth', 'Thoth'),
('E', 'en', 2, 'Paophi', 'Paophi'),
('E', 'en', 3, 'Athyr', 'Athyr'),
('E', 'en', 4, 'Cohiac', 'Cohiac'),
('E', 'en', 5, 'Tybi', 'Tybi'),
('E', 'en', 6, 'Mesir', 'Mesir'),
('E', 'en', 7, 'Phanemoth', 'Phanemoth'),
('E', 'en', 8, 'Pharmouti', 'Pharmouti'),
('E', 'en', 9, 'Pachons', 'Pachons'),
('E', 'en', 10, 'Payni', 'Payni'),
('E', 'en', 11, 'Epiphi', 'Epiphi'),
('E', 'en', 12, 'Mesori', 'Mesori'),
('E', 'en', 13, 'Epagomenal', 'Epagomenal');

INSERT INTO calendar.monthshort VALUES
('F', 1, 'VEND'),
('F', 2, 'BRUM'),
('F', 3, 'FRIM'),
('F', 4, 'NIVO'),
('F', 5, 'PLUV'),
('F', 6, 'VENT'),
('F', 7, 'GERM'),
('F', 8, 'FLOR'),
('F', 9, 'PRAI'),
('F', 10, 'MESS'),
('F', 11, 'THER'),
('F', 12, 'FRUC'),
('F', 13, 'COMP'),
('G', 1, '01'),
('G', 2, '02'),
('G', 3, '03'),
('G', 4, '04'),
('G', 5, '05'),
('G', 6, '06'),
('G', 7, '07'),
('G', 8, '08'),
('G', 9, '09'),
('G', 10, '10'),
('G', 11, '11'),
('G', 12, '12'),
('G', 13, '13'),
('G', 14, '14'),
('G', 15, '15'),
('G', 16, '16'),
('G', 17, '17'),
('G', 18, '18'),
('G', 19, '19'),
('G', 20, '20'),
('H', 1, 'TSH'),
('H', 2, 'CSH'),
('H', 3, 'KSL'),
('H', 4, 'TVT'),
('H', 5, 'SHV'),
('H', 6, 'ADR'),
('H', 7, 'ADS'),
('H', 8, 'NSN'),
('H', 9, 'IYR'),
('H', 10, 'SVN'),
('H', 11, 'TMZ'),
('H', 12, 'AAV'),
('H', 13, 'ELL');

INSERT INTO calendar.part VALUES
('F', 'F', 'F', 'F', 'F', 13, 1, 1, 0, 0, 0),
('G1225', 'G', 'G', 'G', 'G', 12, 12, 25, 0, -1, 0),
('G31', 'G', 'G', 'G', 'G', 12, 3, 1, 1, 0, 0),
('G321', 'G', 'G', 'G', 'G', 12, 3, 21, 1, 0, 0),
('G325', 'G', 'G', 'G', 'G', 12, 3, 25, 1, 0, 0),
('G91', 'G', 'G', 'G', 'G', 12, 9, 1, 1, 0, 0),
('H', 'H', 'H', 'H', 'H', 13, 1, 1, 0, 0, 0),
('J', 'J', 'G', 'G', 'G', 12, 3, 25, 1, 0, 0),
('J11', 'J', 'G', 'G', 'G', 12, 1, 1, 0, 0, 0),
('J1225', 'J', 'G', 'G', 'G', 12, 12, 25, 0, -1, 0),
('J31', 'J', 'G', 'G', 'G', 12, 3, 1, 1, 0, 0),
('J321', 'J', 'G', 'G', 'G', 12, 3, 21, 1, 0, 0),
('J91', 'J', 'G', 'G', 'G', 12, 9, 1, 1, 0, 0),
('Q', 'G', 'G', 'Q', 'G', 12, 1, 1, 0, 0, 0),
('QJ', 'J', 'G', 'Q', 'Q', 12, 3, 25, 1, 0, 2),
('QJ11', 'J', 'G', 'Q', 'G', 12, 1, 1, 0, 0, 0),
('U', 'J', 'G', 'G', 'G', 12, 3, 25, 1, 0, 0),
('U11', 'J', 'G', 'G', 'G', 12, 1, 1, 0, 0, 0),
('U1225', 'J', 'G', 'G', 'G', 12, 12, 25, 0, -1, 0),
('U31', 'J', 'G', 'G', 'G', 12, 3, 1, 1, 0, 0),
('U321', 'J', 'G', 'G', 'G', 12, 3, 21, 1, 0, 0),
('U91', 'J', 'G', 'G', 'G', 12, 9, 1, 1, 0, 0),
('V', 'G', 'G', 'G', 'G', 12, 1, 1, 0, 0, 0),
('', 'G', 'G', 'G', 'G', 12, 1, 1, 0, 0, 0),
('B', 'B', 'G', 'B', 'B', 20, 1, 1, 0, 0, 0),
('C', 'C', 'G', 'C', 'C', 13, 1, 1, 0, 0, 0),
('E', 'E', 'G', 'E', 'E', 13, 1, 1, 0, 0, 0),
('I', 'I', 'G', 'I', 'I', 12, 1, 1, 0, 0, 0),
('S', 'S', 'G', 'S', 'S', 12, 1, 1, 0, 0, 0),
('T', 'T', 'G', 'T', 'T', 13, 1, 1, 0, 0, 0);

INSERT INTO calendar.qualifier VALUES
('', '', '', true),
('after', '>', 'aft.', false),
('and', '&', '&', false),
('before', '<', 'bef.', false),
('between', 'b', 'bet.', false),
('from', '', 'fr.', false),
('to', '', 'to', false);

INSERT INTO calendar.qualifierlocale VALUES
('', 'de', '', ''),
('after', 'de', 'n.', 'nach'),
('and', 'de', 'u.', 'und'),
('before', 'de', 'v.', 'vor'),
('between', 'de', 'zw.', 'zwischen'),
('from', 'de', 'v.', 'von'),
('to', 'de', 'bis', 'bis'),
('', 'en', '', ''),
('after', 'en', 'aft.', 'after'),
('and', 'en', '&', 'and'),
('before', 'en', 'bef.', 'before'),
('between', 'en', 'bet.', 'between'),
('from', 'en', 'fr.', 'from'),
('to', 'en', 'to', 'to'),
('', 'fr', '', ''),
('after', 'fr', 'apr.', 'après'),
('and', 'fr', 'et', 'et'),
('before', 'fr', 'av.', 'avant'),
('between', 'fr', 'entre', 'entre'),
('from', 'fr', 'de', 'de'),
('to', 'fr', 'à', 'à');

INSERT INTO calendar.regnalyear VALUES
('Will.', 1, '1066-10-14J11/1067-10-13J11'),
('Will.', 2, '1067-10-14J11/1068-10-13J11'),
('Will.', 3, '1068-10-14J11/1069-10-13J11'),
('Will.', 4, '1069-10-14J11/1070-10-13J11'),
('Will.', 5, '1070-10-14J11/1071-10-13J11'),
('Will.', 6, '1071-10-14J11/1072-10-13J11'),
('Will.', 7, '1072-10-14J11/1073-10-13J11'),
('Will.', 8, '1073-10-14J11/1074-10-13J11'),
('Will.', 9, '1074-10-14J11/1075-10-13J11'),
('Will.', 10, '1075-10-14J11/1076-10-13J11'),
('Will.', 11, '1076-10-14J11/1077-10-13J11'),
('Will.', 12, '1077-10-14J11/1078-10-13J11'),
('Will.', 13, '1078-10-14J11/1079-10-13J11'),
('Will.', 14, '1079-10-14J11/1080-10-13J11'),
('Will.', 15, '1080-10-14J11/1081-10-13J11'),
('Will.', 16, '1081-10-14J11/1082-10-13J11'),
('Will.', 17, '1082-10-14J11/1083-10-13J11'),
('Will.', 18, '1083-10-14J11/1084-10-13J11'),
('Will.', 19, '1084-10-14J11/1085-10-13J11'),
('Will.', 20, '1085-10-14J11/1086-10-13J11'),
('Will.', 21, '1086-10-14J11/1087-09-09J11'),
('Will. 2', 1, '1087-09-26J11/1088-09-25J11'),
('Will. 2', 2, '1088-09-26J11/1089-09-25J11'),
('Will. 2', 3, '1089-09-26J11/1090-09-25J11'),
('Will. 2', 4, '1090-09-26J11/1091-09-25J11'),
('Will. 2', 5, '1091-09-26J11/1092-09-25J11'),
('Will. 2', 6, '1092-09-26J11/1093-09-25J11'),
('Will. 2', 7, '1093-09-26J11/1094-09-25J11'),
('Will. 2', 8, '1094-09-26J11/1095-09-25J11'),
('Will. 2', 9, '1095-09-26J11/1096-09-25J11'),
('Will. 2', 10, '1096-09-26J11/1097-09-25J11'),
('Will. 2', 11, '1097-09-26J11/1098-09-25J11'),
('Will. 2', 12, '1098-09-26J11/1099-09-25J11'),
('Will. 2', 13, '1099-09-26J11/1100-08-02J11'),
('Hen.', 1, '1100-08-05J11/1101-08-04J11'),
('Hen.', 2, '1101-08-05J11/1102-08-04J11'),
('Hen.', 3, '1102-08-05J11/1103-08-04J11'),
('Hen.', 4, '1103-08-05J11/1104-08-04J11'),
('Hen.', 5, '1104-08-05J11/1105-08-04J11'),
('Hen.', 6, '1105-08-05J11/1106-08-04J11'),
('Hen.', 7, '1106-08-05J11/1107-08-04J11'),
('Hen.', 8, '1107-08-05J11/1108-08-04J11'),
('Hen.', 9, '1108-08-05J11/1109-08-04J11'),
('Hen.', 10, '1109-08-05J11/1110-08-04J11'),
('Hen.', 11, '1110-08-05J11/1111-08-04J11'),
('Hen.', 12, '1111-08-05J11/1112-08-04J11'),
('Hen.', 13, '1112-08-05J11/1113-08-04J11'),
('Hen.', 14, '1113-08-05J11/1114-08-04J11'),
('Hen.', 15, '1114-08-05J11/1115-08-04J11'),
('Hen.', 16, '1115-08-05J11/1116-08-04J11'),
('Hen.', 17, '1116-08-05J11/1117-08-04J11'),
('Hen.', 18, '1117-08-05J11/1118-08-04J11'),
('Hen.', 19, '1118-08-05J11/1119-08-04J11'),
('Hen.', 20, '1119-08-05J11/1120-08-04J11'),
('Hen.', 21, '1120-08-05J11/1121-08-04J11'),
('Hen.', 22, '1121-08-05J11/1122-08-04J11'),
('Hen.', 23, '1122-08-05J11/1123-08-04J11'),
('Hen.', 24, '1123-08-05J11/1124-08-04J11'),
('Hen.', 25, '1124-08-05J11/1125-08-04J11'),
('Hen.', 26, '1125-08-05J11/1126-08-04J11'),
('Hen.', 27, '1126-08-05J11/1127-08-04J11'),
('Hen.', 28, '1127-08-05J11/1128-08-04J11'),
('Hen.', 29, '1128-08-05J11/1129-08-04J11'),
('Hen.', 30, '1129-08-05J11/1130-08-04J11'),
('Hen.', 31, '1130-08-05J11/1131-08-04J11'),
('Hen.', 32, '1131-08-05J11/1132-08-04J11'),
('Hen.', 33, '1132-08-05J11/1133-08-04J11'),
('Hen.', 34, '1133-08-05J11/1134-08-04J11'),
('Hen.', 35, '1134-08-05J11/1135-08-04J11'),
('Hen.', 36, '1135-08-05J11/1135-12-01J11'),
('Stephen', 1, '1135-12-26J11/1136-12-25J11'),
('Stephen', 2, '1136-12-26J11/1137-12-25J11'),
('Stephen', 3, '1137-12-26J11/1138-12-25J11'),
('Stephen', 4, '1138-12-26J11/1139-12-25J11'),
('Stephen', 5, '1139-12-26J11/1140-12-25J11'),
('Stephen', 6, '1140-12-26J11/1141-12-25J11'),
('Stephen', 7, '1141-12-26J11/1142-12-25J11'),
('Stephen', 8, '1142-12-26J11/1143-12-25J11'),
('Stephen', 9, '1143-12-26J11/1144-12-25J11'),
('Stephen', 10, '1144-12-26J11/1145-12-25J11'),
('Stephen', 11, '1145-12-26J11/1146-12-25J11'),
('Stephen', 12, '1146-12-26J11/1147-12-25J11'),
('Stephen', 13, '1147-12-26J11/1148-12-25J11'),
('Stephen', 14, '1148-12-26J11/1149-12-25J11'),
('Stephen', 15, '1149-12-26J11/1150-12-25J11'),
('Stephen', 16, '1150-12-26J11/1151-12-25J11'),
('Stephen', 17, '1151-12-26J11/1152-12-25J11'),
('Stephen', 18, '1152-12-26J11/1153-12-25J11'),
('Stephen', 19, '1153-12-26J11/1154-10-25J11'),
('Hen. 2', 1, '1154-12-19J11/1155-12-18J11'),
('Hen. 2', 2, '1155-12-19J11/1156-12-18J11'),
('Hen. 2', 3, '1156-12-19J11/1157-12-18J11'),
('Hen. 2', 4, '1157-12-19J11/1158-12-18J11'),
('Hen. 2', 5, '1158-12-19J11/1159-12-18J11'),
('Hen. 2', 6, '1159-12-19J11/1160-12-18J11'),
('Hen. 2', 7, '1160-12-19J11/1161-12-18J11'),
('Hen. 2', 8, '1161-12-19J11/1162-12-18J11'),
('Hen. 2', 9, '1162-12-19J11/1163-12-18J11'),
('Hen. 2', 10, '1163-12-19J11/1164-12-18J11'),
('Hen. 2', 11, '1164-12-19J11/1165-12-18J11'),
('Hen. 2', 12, '1165-12-19J11/1166-12-18J11'),
('Hen. 2', 13, '1166-12-19J11/1167-12-18J11'),
('Hen. 2', 14, '1167-12-19J11/1168-12-18J11'),
('Hen. 2', 15, '1168-12-19J11/1169-12-18J11'),
('Hen. 2', 16, '1169-12-19J11/1170-12-18J11'),
('Hen. 2', 17, '1170-12-19J11/1171-12-18J11'),
('Hen. 2', 18, '1171-12-19J11/1172-12-18J11'),
('Hen. 2', 19, '1172-12-19J11/1173-12-18J11'),
('Hen. 2', 20, '1173-12-19J11/1174-12-18J11'),
('Hen. 2', 21, '1174-12-19J11/1175-12-18J11'),
('Hen. 2', 22, '1175-12-19J11/1176-12-18J11'),
('Hen. 2', 23, '1176-12-19J11/1177-12-18J11'),
('Hen. 2', 24, '1177-12-19J11/1178-12-18J11'),
('Hen. 2', 25, '1178-12-19J11/1179-12-18J11'),
('Hen. 2', 26, '1179-12-19J11/1180-12-18J11'),
('Hen. 2', 27, '1180-12-19J11/1181-12-18J11'),
('Hen. 2', 28, '1181-12-19J11/1182-12-18J11'),
('Hen. 2', 29, '1182-12-19J11/1183-12-18J11'),
('Hen. 2', 30, '1183-12-19J11/1184-12-18J11'),
('Hen. 2', 31, '1184-12-19J11/1185-12-18J11'),
('Hen. 2', 32, '1185-12-19J11/1186-12-18J11'),
('Hen. 2', 33, '1186-12-19J11/1187-12-18J11'),
('Hen. 2', 34, '1187-12-19J11/1188-12-18J11'),
('Hen. 2', 35, '1188-12-19J11/1189-07-06J11'),
('Rich.', 1, '1189-09-03J11/1190-09-02J11'),
('Rich.', 2, '1190-09-03J11/1191-09-02J11'),
('Rich.', 3, '1191-09-03J11/1192-09-02J11'),
('Rich.', 4, '1192-09-03J11/1193-09-02J11'),
('Rich.', 5, '1193-09-03J11/1194-09-02J11'),
('Rich.', 6, '1194-09-03J11/1195-09-02J11'),
('Rich.', 7, '1195-09-03J11/1196-09-02J11'),
('Rich.', 8, '1196-09-03J11/1197-09-02J11'),
('Rich.', 9, '1197-09-03J11/1198-09-02J11'),
('Rich.', 10, '1198-09-03J11/1199-04-06J11'),
('John', 1, '1199-05-27J11/1200-05-17J11'),
('John', 2, '1200-05-18J11/1201-05-02J11'),
('John', 3, '1201-05-03J11/1202-05-22J11'),
('John', 4, '1202-05-23J11/1203-05-14J11'),
('John', 5, '1203-05-15J11/1204-06-02J11'),
('John', 6, '1204-06-03J11/1205-05-18J11'),
('John', 7, '1205-05-19J11/1206-05-10J11'),
('John', 8, '1206-05-11J11/1207-05-30J11'),
('John', 9, '1207-05-31J11/1208-05-14J11'),
('John', 10, '1208-05-15J11/1209-05-06J11'),
('John', 11, '1209-05-07J11/1210-05-26J11'),
('John', 12, '1210-05-27J11/1211-05-11J11'),
('John', 13, '1211-05-12J11/1212-05-02J11'),
('John', 14, '1212-05-03J11/1213-05-22J11'),
('John', 15, '1213-05-23J11/1214-05-07J11'),
('John', 16, '1214-05-08J11/1215-05-27J11'),
('John', 17, '1215-05-28J11/1216-05-18J11'),
('John', 18, '1216-05-19J11/1216-10-19J11'),
('Hen. 3', 1, '1216-10-28J11/1217-10-27J11'),
('Hen. 3', 2, '1217-10-28J11/1218-10-27J11'),
('Hen. 3', 3, '1218-10-28J11/1219-10-27J11'),
('Hen. 3', 4, '1219-10-28J11/1220-10-27J11'),
('Hen. 3', 5, '1220-10-28J11/1221-10-27J11'),
('Hen. 3', 6, '1221-10-28J11/1222-10-27J11'),
('Hen. 3', 7, '1222-10-28J11/1223-10-27J11'),
('Hen. 3', 8, '1223-10-28J11/1224-10-27J11'),
('Hen. 3', 9, '1224-10-28J11/1225-10-27J11'),
('Hen. 3', 10, '1225-10-28J11/1226-10-27J11'),
('Hen. 3', 11, '1226-10-28J11/1227-10-27J11'),
('Hen. 3', 12, '1227-10-28J11/1228-10-27J11'),
('Hen. 3', 13, '1228-10-28J11/1229-10-27J11'),
('Hen. 3', 14, '1229-10-28J11/1230-10-27J11'),
('Hen. 3', 15, '1230-10-28J11/1231-10-27J11'),
('Hen. 3', 16, '1231-10-28J11/1232-10-27J11'),
('Hen. 3', 17, '1232-10-28J11/1233-10-27J11'),
('Hen. 3', 18, '1233-10-28J11/1234-10-27J11'),
('Hen. 3', 19, '1234-10-28J11/1235-10-27J11'),
('Hen. 3', 20, '1235-10-28J11/1236-10-27J11'),
('Hen. 3', 21, '1236-10-28J11/1237-10-27J11'),
('Hen. 3', 22, '1237-10-28J11/1238-10-27J11'),
('Hen. 3', 23, '1238-10-28J11/1239-10-27J11'),
('Hen. 3', 24, '1239-10-28J11/1240-10-27J11'),
('Hen. 3', 25, '1240-10-28J11/1241-10-27J11'),
('Hen. 3', 26, '1241-10-28J11/1242-10-27J11'),
('Hen. 3', 27, '1242-10-28J11/1243-10-27J11'),
('Hen. 3', 28, '1243-10-28J11/1244-10-27J11'),
('Hen. 3', 29, '1244-10-28J11/1245-10-27J11'),
('Hen. 3', 30, '1245-10-28J11/1246-10-27J11'),
('Hen. 3', 31, '1246-10-28J11/1247-10-27J11'),
('Hen. 3', 32, '1247-10-28J11/1248-10-27J11'),
('Hen. 3', 33, '1248-10-28J11/1249-10-27J11'),
('Hen. 3', 34, '1249-10-28J11/1250-10-27J11'),
('Hen. 3', 35, '1250-10-28J11/1251-10-27J11'),
('Hen. 3', 36, '1251-10-28J11/1252-10-27J11'),
('Hen. 3', 37, '1252-10-28J11/1253-10-27J11'),
('Hen. 3', 38, '1253-10-28J11/1254-10-27J11'),
('Hen. 3', 39, '1254-10-28J11/1255-10-27J11'),
('Hen. 3', 40, '1255-10-28J11/1256-10-27J11'),
('Hen. 3', 41, '1256-10-28J11/1257-10-27J11'),
('Hen. 3', 42, '1257-10-28J11/1258-10-27J11'),
('Hen. 3', 43, '1258-10-28J11/1259-10-27J11'),
('Hen. 3', 44, '1259-10-28J11/1260-10-27J11'),
('Hen. 3', 45, '1260-10-28J11/1261-10-27J11'),
('Hen. 3', 46, '1261-10-28J11/1262-10-27J11'),
('Hen. 3', 47, '1262-10-28J11/1263-10-27J11'),
('Hen. 3', 48, '1263-10-28J11/1264-10-27J11'),
('Hen. 3', 49, '1264-10-28J11/1265-10-27J11'),
('Hen. 3', 50, '1265-10-28J11/1266-10-27J11'),
('Hen. 3', 51, '1266-10-28J11/1267-10-27J11'),
('Hen. 3', 52, '1267-10-28J11/1268-10-27J11'),
('Hen. 3', 53, '1268-10-28J11/1269-10-27J11'),
('Hen. 3', 54, '1269-10-28J11/1270-10-27J11'),
('Hen. 3', 55, '1270-10-28J11/1271-10-27J11'),
('Hen. 3', 56, '1271-10-28J11/1272-10-27J11'),
('Hen. 3', 57, '1272-10-28J11/1272-11-16J11'),
('Edw.', 1, '1272-11-20J11/1273-11-20J11'),
('Edw.', 2, '1273-11-20J11/1274-11-20J11'),
('Edw.', 3, '1274-11-20J11/1275-11-20J11'),
('Edw.', 4, '1275-11-20J11/1276-11-20J11'),
('Edw.', 5, '1276-11-20J11/1277-11-20J11'),
('Edw.', 6, '1277-11-20J11/1278-11-20J11'),
('Edw.', 7, '1278-11-20J11/1279-11-20J11'),
('Edw.', 8, '1279-11-20J11/1280-11-20J11'),
('Edw.', 9, '1280-11-20J11/1281-11-20J11'),
('Edw.', 10, '1281-11-20J11/1282-11-20J11'),
('Edw.', 11, '1282-11-20J11/1283-11-20J11'),
('Edw.', 12, '1283-11-20J11/1284-11-20J11'),
('Edw.', 13, '1284-11-20J11/1285-11-20J11'),
('Edw.', 14, '1285-11-20J11/1286-11-20J11'),
('Edw.', 15, '1286-11-20J11/1287-11-20J11'),
('Edw.', 16, '1287-11-20J11/1288-11-20J11'),
('Edw.', 17, '1288-11-20J11/1289-11-20J11'),
('Edw.', 18, '1289-11-20J11/1290-11-20J11'),
('Edw.', 19, '1290-11-20J11/1291-11-20J11'),
('Edw.', 20, '1291-11-20J11/1292-11-20J11'),
('Edw.', 21, '1292-11-20J11/1293-11-20J11'),
('Edw.', 22, '1293-11-20J11/1294-11-20J11'),
('Edw.', 23, '1294-11-20J11/1295-11-20J11'),
('Edw.', 24, '1295-11-20J11/1296-11-20J11'),
('Edw.', 25, '1296-11-20J11/1297-11-20J11'),
('Edw.', 26, '1297-11-20J11/1298-11-20J11'),
('Edw.', 27, '1298-11-20J11/1299-11-20J11'),
('Edw.', 28, '1299-11-20J11/1300-11-20J11'),
('Edw.', 29, '1300-11-20J11/1301-11-20J11'),
('Edw.', 30, '1301-11-20J11/1302-11-20J11'),
('Edw.', 31, '1302-11-20J11/1303-11-20J11'),
('Edw.', 32, '1303-11-20J11/1304-11-20J11'),
('Edw.', 33, '1304-11-20J11/1305-11-20J11'),
('Edw.', 34, '1305-11-20J11/1306-11-20J11'),
('Edw.', 35, '1306-11-20J11/1307-07-07J11'),
('Edw. 2', 1, '1307-07-08J11/1308-07-07J11'),
('Edw. 2', 2, '1308-07-08J11/1309-07-07J11'),
('Edw. 2', 3, '1309-07-08J11/1310-07-07J11'),
('Edw. 2', 4, '1310-07-08J11/1311-07-07J11'),
('Edw. 2', 5, '1311-07-08J11/1312-07-07J11'),
('Edw. 2', 6, '1312-07-08J11/1313-07-07J11'),
('Edw. 2', 7, '1313-07-08J11/1314-07-07J11'),
('Edw. 2', 8, '1314-07-08J11/1315-07-07J11'),
('Edw. 2', 9, '1315-07-08J11/1316-07-07J11'),
('Edw. 2', 10, '1316-07-08J11/1317-07-07J11'),
('Edw. 2', 11, '1317-07-08J11/1318-07-07J11'),
('Edw. 2', 12, '1318-07-08J11/1319-07-07J11'),
('Edw. 2', 13, '1319-07-08J11/1320-07-07J11'),
('Edw. 2', 14, '1320-07-08J11/1321-07-07J11'),
('Edw. 2', 15, '1321-07-08J11/1322-07-07J11'),
('Edw. 2', 16, '1322-07-08J11/1323-07-07J11'),
('Edw. 2', 17, '1323-07-08J11/1324-07-07J11'),
('Edw. 2', 18, '1324-07-08J11/1325-07-07J11'),
('Edw. 2', 19, '1325-07-08J11/1326-07-07J11'),
('Edw. 2', 20, '1326-07-08J11/1327-01-20J11'),
('Edw. 3', 1, '1327-01-25J11/1328-01-24J11'),
('Edw. 3', 2, '1328-01-25J11/1329-01-24J11'),
('Edw. 3', 3, '1329-01-25J11/1330-01-24J11'),
('Edw. 3', 4, '1330-01-25J11/1331-01-24J11'),
('Edw. 3', 5, '1331-01-25J11/1332-01-24J11'),
('Edw. 3', 6, '1332-01-25J11/1333-01-24J11'),
('Edw. 3', 7, '1333-01-25J11/1334-01-24J11'),
('Edw. 3', 8, '1334-01-25J11/1335-01-24J11'),
('Edw. 3', 9, '1335-01-25J11/1336-01-24J11'),
('Edw. 3', 10, '1336-01-25J11/1337-01-24J11'),
('Edw. 3', 11, '1337-01-25J11/1338-01-24J11'),
('Edw. 3', 12, '1338-01-25J11/1339-01-24J11'),
('Edw. 3', 13, '1339-01-25J11/1340-01-24J11'),
('Edw. 3', 14, '1340-01-25J11/1341-01-24J11'),
('Edw. 3', 15, '1341-01-25J11/1342-01-24J11'),
('Edw. 3', 16, '1342-01-25J11/1343-01-24J11'),
('Edw. 3', 17, '1343-01-25J11/1344-01-24J11'),
('Edw. 3', 18, '1344-01-25J11/1345-01-24J11'),
('Edw. 3', 19, '1345-01-25J11/1346-01-24J11'),
('Edw. 3', 20, '1346-01-25J11/1347-01-24J11'),
('Edw. 3', 21, '1347-01-25J11/1348-01-24J11'),
('Edw. 3', 22, '1348-01-25J11/1349-01-24J11'),
('Edw. 3', 23, '1349-01-25J11/1350-01-24J11'),
('Edw. 3', 24, '1350-01-25J11/1351-01-24J11'),
('Edw. 3', 25, '1351-01-25J11/1352-01-24J11'),
('Edw. 3', 26, '1352-01-25J11/1353-01-24J11'),
('Edw. 3', 27, '1353-01-25J11/1354-01-24J11'),
('Edw. 3', 28, '1354-01-25J11/1355-01-24J11'),
('Edw. 3', 29, '1355-01-25J11/1356-01-24J11'),
('Edw. 3', 30, '1356-01-25J11/1357-01-24J11'),
('Edw. 3', 31, '1357-01-25J11/1358-01-24J11'),
('Edw. 3', 32, '1358-01-25J11/1359-01-24J11'),
('Edw. 3', 33, '1359-01-25J11/1360-01-24J11'),
('Edw. 3', 34, '1360-01-25J11/1361-01-24J11'),
('Edw. 3', 35, '1361-01-25J11/1362-01-24J11'),
('Edw. 3', 36, '1362-01-25J11/1363-01-24J11'),
('Edw. 3', 37, '1363-01-25J11/1364-01-24J11'),
('Edw. 3', 38, '1364-01-25J11/1365-01-24J11'),
('Edw. 3', 39, '1365-01-25J11/1366-01-24J11'),
('Edw. 3', 40, '1366-01-25J11/1367-01-24J11'),
('Edw. 3', 41, '1367-01-25J11/1368-01-24J11'),
('Edw. 3', 42, '1368-01-25J11/1369-01-24J11'),
('Edw. 3', 43, '1369-01-25J11/1370-01-24J11'),
('Edw. 3', 44, '1370-01-25J11/1371-01-24J11'),
('Edw. 3', 45, '1371-01-25J11/1372-01-24J11'),
('Edw. 3', 46, '1372-01-25J11/1373-01-24J11'),
('Edw. 3', 47, '1373-01-25J11/1374-01-24J11'),
('Edw. 3', 48, '1374-01-25J11/1375-01-24J11'),
('Edw. 3', 49, '1375-01-25J11/1376-01-24J11'),
('Edw. 3', 50, '1376-01-25J11/1377-01-24J11'),
('Edw. 3', 51, '1377-01-25J11/1377-06-21J11'),
('Rich. 2', 1, '1377-06-22J11/1378-06-21J11'),
('Rich. 2', 2, '1378-06-22J11/1379-06-21J11'),
('Rich. 2', 3, '1379-06-22J11/1380-06-21J11'),
('Rich. 2', 4, '1380-06-22J11/1381-06-21J11'),
('Rich. 2', 5, '1381-06-22J11/1382-06-21J11'),
('Rich. 2', 6, '1382-06-22J11/1383-06-21J11'),
('Rich. 2', 7, '1383-06-22J11/1384-06-21J11'),
('Rich. 2', 8, '1384-06-22J11/1385-06-21J11'),
('Rich. 2', 9, '1385-06-22J11/1386-06-21J11'),
('Rich. 2', 10, '1386-06-22J11/1387-06-21J11'),
('Rich. 2', 11, '1387-06-22J11/1388-06-21J11'),
('Rich. 2', 12, '1388-06-22J11/1389-06-21J11'),
('Rich. 2', 13, '1389-06-22J11/1390-06-21J11'),
('Rich. 2', 14, '1390-06-22J11/1391-06-21J11'),
('Rich. 2', 15, '1391-06-22J11/1392-06-21J11'),
('Rich. 2', 16, '1392-06-22J11/1393-06-21J11'),
('Rich. 2', 17, '1393-06-22J11/1394-06-21J11'),
('Rich. 2', 18, '1394-06-22J11/1395-06-21J11'),
('Rich. 2', 19, '1395-06-22J11/1396-06-21J11'),
('Rich. 2', 20, '1396-06-22J11/1397-06-21J11'),
('Rich. 2', 21, '1397-06-22J11/1398-06-21J11'),
('Rich. 2', 22, '1398-06-22J11/1399-06-21J11'),
('Rich. 2', 23, '1399-06-22J11/1399-09-29J11'),
('Hen. 4', 1, '1399-09-30J11/1400-09-29J11'),
('Hen. 4', 2, '1400-09-30J11/1401-09-29J11'),
('Hen. 4', 3, '1401-09-30J11/1402-09-29J11'),
('Hen. 4', 4, '1402-09-30J11/1403-09-29J11'),
('Hen. 4', 5, '1403-09-30J11/1404-09-29J11'),
('Hen. 4', 6, '1404-09-30J11/1405-09-29J11'),
('Hen. 4', 7, '1405-09-30J11/1406-09-29J11'),
('Hen. 4', 8, '1406-09-30J11/1407-09-29J11'),
('Hen. 4', 9, '1407-09-30J11/1408-09-29J11'),
('Hen. 4', 10, '1408-09-30J11/1409-09-29J11'),
('Hen. 4', 11, '1409-09-30J11/1410-09-29J11'),
('Hen. 4', 12, '1410-09-30J11/1411-09-29J11'),
('Hen. 4', 13, '1411-09-30J11/1412-09-29J11'),
('Hen. 4', 14, '1412-09-30J11/1413-03-20J11'),
('Hen. 5', 1, '1413-03-21J11/1414-03-20J11'),
('Hen. 5', 2, '1414-03-21J11/1415-03-20J11'),
('Hen. 5', 3, '1415-03-21J11/1416-03-20J11'),
('Hen. 5', 4, '1416-03-21J11/1417-03-20J11'),
('Hen. 5', 5, '1417-03-21J11/1418-03-20J11'),
('Hen. 5', 6, '1418-03-21J11/1419-03-20J11'),
('Hen. 5', 7, '1419-03-21J11/1420-03-20J11'),
('Hen. 5', 8, '1420-03-21J11/1421-03-20J11'),
('Hen. 5', 9, '1421-03-21J11/1422-03-20J11'),
('Hen. 5', 10, '1422-03-21J11/1422-08-31J11'),
('Hen. 6', 1, '1422-09-01J11/1423-08-31J11'),
('Hen. 6', 2, '1423-09-01J11/1424-08-31J11'),
('Hen. 6', 3, '1424-09-01J11/1425-08-31J11'),
('Hen. 6', 4, '1425-09-01J11/1426-08-31J11'),
('Hen. 6', 5, '1426-09-01J11/1427-08-31J11'),
('Hen. 6', 6, '1427-09-01J11/1428-08-31J11'),
('Hen. 6', 7, '1428-09-01J11/1429-08-31J11'),
('Hen. 6', 8, '1429-09-01J11/1430-08-31J11'),
('Hen. 6', 9, '1430-09-01J11/1431-08-31J11'),
('Hen. 6', 10, '1431-09-01J11/1432-08-31J11'),
('Hen. 6', 11, '1432-09-01J11/1433-08-31J11'),
('Hen. 6', 12, '1433-09-01J11/1434-08-31J11'),
('Hen. 6', 13, '1434-09-01J11/1435-08-31J11'),
('Hen. 6', 14, '1435-09-01J11/1436-08-31J11'),
('Hen. 6', 15, '1436-09-01J11/1437-08-31J11'),
('Hen. 6', 16, '1437-09-01J11/1438-08-31J11'),
('Hen. 6', 17, '1438-09-01J11/1439-08-31J11'),
('Hen. 6', 18, '1439-09-01J11/1440-08-31J11'),
('Hen. 6', 19, '1440-09-01J11/1441-08-31J11'),
('Hen. 6', 20, '1441-09-01J11/1442-08-31J11'),
('Hen. 6', 21, '1442-09-01J11/1443-08-31J11'),
('Hen. 6', 22, '1443-09-01J11/1444-08-31J11'),
('Hen. 6', 23, '1444-09-01J11/1445-08-31J11'),
('Hen. 6', 24, '1445-09-01J11/1446-08-31J11'),
('Hen. 6', 25, '1446-09-01J11/1447-08-31J11'),
('Hen. 6', 26, '1447-09-01J11/1448-08-31J11'),
('Hen. 6', 27, '1448-09-01J11/1449-08-31J11'),
('Hen. 6', 28, '1449-09-01J11/1450-08-31J11'),
('Hen. 6', 29, '1450-09-01J11/1451-08-31J11'),
('Hen. 6', 30, '1451-09-01J11/1452-08-31J11'),
('Hen. 6', 31, '1452-09-01J11/1453-08-31J11'),
('Hen. 6', 32, '1453-09-01J11/1454-08-31J11'),
('Hen. 6', 33, '1454-09-01J11/1455-08-31J11'),
('Hen. 6', 34, '1455-09-01J11/1456-08-31J11'),
('Hen. 6', 35, '1456-09-01J11/1457-08-31J11'),
('Hen. 6', 36, '1457-09-01J11/1458-08-31J11'),
('Hen. 6', 37, '1458-09-01J11/1459-08-31J11'),
('Hen. 6', 38, '1459-09-01J11/1460-08-31J11'),
('Hen. 6', 39, '1460-09-01J11/1461-03-04J11'),
('Edw. 4', 1, '1461-03-04J11/1462-03-03J11'),
('Edw. 4', 2, '1462-03-04J11/1463-03-03J11'),
('Edw. 4', 3, '1463-03-04J11/1464-03-03J11'),
('Edw. 4', 4, '1464-03-04J11/1465-03-03J11'),
('Edw. 4', 5, '1465-03-04J11/1466-03-03J11'),
('Edw. 4', 6, '1466-03-04J11/1467-03-03J11'),
('Edw. 4', 7, '1467-03-04J11/1468-03-03J11'),
('Edw. 4', 8, '1468-03-04J11/1469-03-03J11'),
('Edw. 4', 9, '1469-03-04J11/1470-03-03J11'),
('Edw. 4', 10, '1470-03-04J11/1471-03-03J11'),
('Edw. 4', 11, '1471-03-04J11/1472-03-03J11'),
('Edw. 4', 12, '1472-03-04J11/1473-03-03J11'),
('Edw. 4', 13, '1473-03-04J11/1474-03-03J11'),
('Edw. 4', 14, '1474-03-04J11/1475-03-03J11'),
('Edw. 4', 15, '1475-03-04J11/1476-03-03J11'),
('Edw. 4', 16, '1476-03-04J11/1477-03-03J11'),
('Edw. 4', 17, '1477-03-04J11/1478-03-03J11'),
('Edw. 4', 18, '1478-03-04J11/1479-03-03J11'),
('Edw. 4', 19, '1479-03-04J11/1480-03-03J11'),
('Edw. 4', 20, '1480-03-04J11/1481-03-03J11'),
('Edw. 4', 21, '1481-03-04J11/1482-03-03J11'),
('Edw. 4', 22, '1482-03-04J11/1483-03-03J11'),
('Edw. 4', 23, '1483-03-04J11/1483-04-09J11'),
('Edw. 5', 1, '1483-04-09J11/1483-06-25J11'),
('Rich. 3', 1, '1483-06-26J11/1484-06-25J11'),
('Rich. 3', 2, '1484-06-26J11/1485-06-25J11'),
('Rich. 3', 3, '1485-06-26J11/1485-08-22J11'),
('Hen. 7', 1, '1485-08-22J11/1486-08-21J11'),
('Hen. 7', 2, '1486-08-22J11/1487-08-21J11'),
('Hen. 7', 3, '1487-08-22J11/1488-08-21J11'),
('Hen. 7', 4, '1488-08-22J11/1489-08-21J11'),
('Hen. 7', 5, '1489-08-22J11/1490-08-21J11'),
('Hen. 7', 6, '1490-08-22J11/1491-08-21J11'),
('Hen. 7', 7, '1491-08-22J11/1492-08-21J11'),
('Hen. 7', 8, '1492-08-22J11/1493-08-21J11'),
('Hen. 7', 9, '1493-08-22J11/1494-08-21J11'),
('Hen. 7', 10, '1494-08-22J11/1495-08-21J11'),
('Hen. 7', 11, '1495-08-22J11/1496-08-21J11'),
('Hen. 7', 12, '1496-08-22J11/1497-08-21J11'),
('Hen. 7', 13, '1497-08-22J11/1498-08-21J11'),
('Hen. 7', 14, '1498-08-22J11/1499-08-21J11'),
('Hen. 7', 15, '1499-08-22J11/1500-08-21J11'),
('Hen. 7', 16, '1500-08-22J11/1501-08-21J11'),
('Hen. 7', 17, '1501-08-22J11/1502-08-21J11'),
('Hen. 7', 18, '1502-08-22J11/1503-08-21J11'),
('Hen. 7', 19, '1503-08-22J11/1504-08-21J11'),
('Hen. 7', 20, '1504-08-22J11/1505-08-21J11'),
('Hen. 7', 21, '1505-08-22J11/1506-08-21J11'),
('Hen. 7', 22, '1506-08-22J11/1507-08-21J11'),
('Hen. 7', 23, '1507-08-22J11/1508-08-21J11'),
('Hen. 7', 24, '1508-08-22J11/1509-04-21J11'),
('Hen. 8', 1, '1509-04-22J11/1510-04-21J11'),
('Hen. 8', 2, '1510-04-22J11/1511-04-21J11'),
('Hen. 8', 3, '1511-04-22J11/1512-04-21J11'),
('Hen. 8', 4, '1512-04-22J11/1513-04-21J11'),
('Hen. 8', 5, '1513-04-22J11/1514-04-21J11'),
('Hen. 8', 6, '1514-04-22J11/1515-04-21J11'),
('Hen. 8', 7, '1515-04-22J11/1516-04-21J11'),
('Hen. 8', 8, '1516-04-22J11/1517-04-21J11'),
('Hen. 8', 9, '1517-04-22J11/1518-04-21J11'),
('Hen. 8', 10, '1518-04-22J11/1519-04-21J11'),
('Hen. 8', 11, '1519-04-22J11/1520-04-21J11'),
('Hen. 8', 12, '1520-04-22J11/1521-04-21J11'),
('Hen. 8', 13, '1521-04-22J11/1522-04-21J11'),
('Hen. 8', 14, '1522-04-22J11/1523-04-21J11'),
('Hen. 8', 15, '1523-04-22J11/1524-04-21J11'),
('Hen. 8', 16, '1524-04-22J11/1525-04-21J11'),
('Hen. 8', 17, '1525-04-22J11/1526-04-21J11'),
('Hen. 8', 18, '1526-04-22J11/1527-04-21J11'),
('Hen. 8', 19, '1527-04-22J11/1528-04-21J11'),
('Hen. 8', 20, '1528-04-22J11/1529-04-21J11'),
('Hen. 8', 21, '1529-04-22J11/1530-04-21J11'),
('Hen. 8', 22, '1530-04-22J11/1531-04-21J11'),
('Hen. 8', 23, '1531-04-22J11/1532-04-21J11'),
('Hen. 8', 24, '1532-04-22J11/1533-04-21J11'),
('Hen. 8', 25, '1533-04-22J11/1534-04-21J11'),
('Hen. 8', 26, '1534-04-22J11/1535-04-21J11'),
('Hen. 8', 27, '1535-04-22J11/1536-04-21J11'),
('Hen. 8', 28, '1536-04-22J11/1537-04-21J11'),
('Hen. 8', 29, '1537-04-22J11/1538-04-21J11'),
('Hen. 8', 30, '1538-04-22J11/1539-04-21J11'),
('Hen. 8', 31, '1539-04-22J11/1540-04-21J11'),
('Hen. 8', 32, '1540-04-22J11/1541-04-21J11'),
('Hen. 8', 33, '1541-04-22J11/1542-04-21J11'),
('Hen. 8', 34, '1542-04-22J11/1543-04-21J11'),
('Hen. 8', 35, '1543-04-22J11/1544-04-21J11'),
('Hen. 8', 36, '1544-04-22J11/1545-04-21J11'),
('Hen. 8', 37, '1545-04-22J11/1546-04-21J11'),
('Hen. 8', 38, '1546-04-22J11/1547-01-28J11'),
('Edw. 6', 1, '1547-01-28J11/1548-01-27J11'),
('Edw. 6', 2, '1548-01-28J11/1549-01-27J11'),
('Edw. 6', 3, '1549-01-28J11/1550-01-27J11'),
('Edw. 6', 4, '1550-01-28J11/1551-01-27J11'),
('Edw. 6', 5, '1551-01-28J11/1552-01-27J11'),
('Edw. 6', 6, '1552-01-28J11/1553-01-27J11'),
('Edw. 6', 7, '1553-01-28J11/1553-07-06J11'),
('Mary', 1, '1553-07-06J11/1554-07-05J11'),
('Mary', 2, '1554-07-06J11/1554-07-24J11'),
('Phil. & M.', 1, '1554-07-25J11/1555-07-24J11'),
('Phil. & M.', 2, '1555-07-25J11/1556-07-24J11'),
('Phil. & M.', 3, '1556-07-25J11/1557-07-24J11'),
('Phil. & M.', 4, '1557-07-25J11/1558-07-24J11'),
('Phil. & M.', 5, '1558-07-25J11/1558-11-17J11'),
('Eliz.', 1, '1558-11-17J11/1559-11-16J11'),
('Eliz.', 2, '1559-11-17J11/1560-11-16J11'),
('Eliz.', 3, '1560-11-17J11/1561-11-16J11'),
('Eliz.', 4, '1561-11-17J11/1562-11-16J11'),
('Eliz.', 5, '1562-11-17J11/1563-11-16J11'),
('Eliz.', 6, '1563-11-17J11/1564-11-16J11'),
('Eliz.', 7, '1564-11-17J11/1565-11-16J11'),
('Eliz.', 8, '1565-11-17J11/1566-11-16J11'),
('Eliz.', 9, '1566-11-17J11/1567-11-16J11'),
('Eliz.', 10, '1567-11-17J11/1568-11-16J11'),
('Eliz.', 11, '1568-11-17J11/1569-11-16J11'),
('Eliz.', 12, '1569-11-17J11/1570-11-16J11'),
('Eliz.', 13, '1570-11-17J11/1571-11-16J11'),
('Eliz.', 14, '1571-11-17J11/1572-11-16J11'),
('Eliz.', 15, '1572-11-17J11/1573-11-16J11'),
('Eliz.', 16, '1573-11-17J11/1574-11-16J11'),
('Eliz.', 17, '1574-11-17J11/1575-11-16J11'),
('Eliz.', 18, '1575-11-17J11/1576-11-16J11'),
('Eliz.', 19, '1576-11-17J11/1577-11-16J11'),
('Eliz.', 20, '1577-11-17J11/1578-11-16J11'),
('Eliz.', 21, '1578-11-17J11/1579-11-16J11'),
('Eliz.', 22, '1579-11-17J11/1580-11-16J11'),
('Eliz.', 23, '1580-11-17J11/1581-11-16J11'),
('Eliz.', 24, '1581-11-17J11/1582-11-16J11'),
('Eliz.', 25, '1582-11-17J11/1583-11-16J11'),
('Eliz.', 26, '1583-11-17J11/1584-11-16J11'),
('Eliz.', 27, '1584-11-17J11/1585-11-16J11'),
('Eliz.', 28, '1585-11-17J11/1586-11-16J11'),
('Eliz.', 29, '1586-11-17J11/1587-11-16J11'),
('Eliz.', 30, '1587-11-17J11/1588-11-16J11'),
('Eliz.', 31, '1588-11-17J11/1589-11-16J11'),
('Eliz.', 32, '1589-11-17J11/1590-11-16J11'),
('Eliz.', 33, '1590-11-17J11/1591-11-16J11'),
('Eliz.', 34, '1591-11-17J11/1592-11-16J11'),
('Eliz.', 35, '1592-11-17J11/1593-11-16J11'),
('Eliz.', 36, '1593-11-17J11/1594-11-16J11'),
('Eliz.', 37, '1594-11-17J11/1595-11-16J11'),
('Eliz.', 38, '1595-11-17J11/1596-11-16J11'),
('Eliz.', 39, '1596-11-17J11/1597-11-16J11'),
('Eliz.', 40, '1597-11-17J11/1598-11-16J11'),
('Eliz.', 41, '1598-11-17J11/1599-11-16J11'),
('Eliz.', 42, '1599-11-17J11/1600-11-16J11'),
('Eliz.', 43, '1600-11-17J11/1601-11-16J11'),
('Eliz.', 44, '1601-11-17J11/1602-11-16J11'),
('Eliz.', 45, '1602-11-17J11/1603-03-24J11'),
('Jac.', 1, '1603-03-25J11/1604-03-24J11'),
('Jac.', 2, '1604-03-25J11/1605-03-24J11'),
('Jac.', 3, '1605-03-25J11/1606-03-24J11'),
('Jac.', 4, '1606-03-25J11/1607-03-24J11'),
('Jac.', 5, '1607-03-25J11/1608-03-24J11'),
('Jac.', 6, '1608-03-25J11/1609-03-24J11'),
('Jac.', 7, '1609-03-25J11/1610-03-24J11'),
('Jac.', 8, '1610-03-25J11/1611-03-24J11'),
('Jac.', 9, '1611-03-25J11/1612-03-24J11'),
('Jac.', 10, '1612-03-25J11/1613-03-24J11'),
('Jac.', 11, '1613-03-25J11/1614-03-24J11'),
('Jac.', 12, '1614-03-25J11/1615-03-24J11'),
('Jac.', 13, '1615-03-25J11/1616-03-24J11'),
('Jac.', 14, '1616-03-25J11/1617-03-24J11'),
('Jac.', 15, '1617-03-25J11/1618-03-24J11'),
('Jac.', 16, '1618-03-25J11/1619-03-24J11'),
('Jac.', 17, '1619-03-25J11/1620-03-24J11'),
('Jac.', 18, '1620-03-25J11/1621-03-24J11'),
('Jac.', 19, '1621-03-25J11/1622-03-24J11'),
('Jac.', 20, '1622-03-25J11/1623-03-24J11'),
('Jac.', 21, '1623-03-25J11/1624-03-24J11'),
('Jac.', 22, '1624-03-25J11/1625-03-24J11'),
('Jac.', 23, '1625-03-25J11/1625-03-27J11'),
('Car.', 1, '1625-03-27J11/1626-03-26J11'),
('Car.', 2, '1626-03-27J11/1627-03-26J11'),
('Car.', 3, '1627-03-27J11/1628-03-26J11'),
('Car.', 4, '1628-03-27J11/1629-03-26J11'),
('Car.', 5, '1629-03-27J11/1630-03-26J11'),
('Car.', 6, '1630-03-27J11/1631-03-26J11'),
('Car.', 7, '1631-03-27J11/1632-03-26J11'),
('Car.', 8, '1632-03-27J11/1633-03-26J11'),
('Car.', 9, '1633-03-27J11/1634-03-26J11'),
('Car.', 10, '1634-03-27J11/1635-03-26J11'),
('Car.', 11, '1635-03-27J11/1636-03-26J11'),
('Car.', 12, '1636-03-27J11/1637-03-26J11'),
('Car.', 13, '1637-03-27J11/1638-03-26J11'),
('Car.', 14, '1638-03-27J11/1639-03-26J11'),
('Car.', 15, '1639-03-27J11/1640-03-26J11'),
('Car.', 16, '1640-03-27J11/1641-03-26J11'),
('Car.', 17, '1641-03-27J11/1642-03-26J11'),
('Car.', 18, '1642-03-27J11/1643-03-26J11'),
('Car.', 19, '1643-03-27J11/1644-03-26J11'),
('Car.', 20, '1644-03-27J11/1645-03-26J11'),
('Car.', 21, '1645-03-27J11/1646-03-26J11'),
('Car.', 22, '1646-03-27J11/1647-03-26J11'),
('Car.', 23, '1647-03-27J11/1648-03-26J11'),
('Car.', 24, '1648-03-27J11/1649-01-30J11'),
('Car. 2', 1, '1649-01-30J11/1650-01-29J11'),
('Car. 2', 2, '1650-01-30J11/1651-01-29J11'),
('Car. 2', 3, '1651-01-30J11/1652-01-29J11'),
('Car. 2', 4, '1652-01-30J11/1653-01-29J11'),
('Car. 2', 5, '1653-01-30J11/1654-01-29J11'),
('Car. 2', 6, '1654-01-30J11/1655-01-29J11'),
('Car. 2', 7, '1655-01-30J11/1656-01-29J11'),
('Car. 2', 8, '1656-01-30J11/1657-01-29J11'),
('Car. 2', 9, '1657-01-30J11/1658-01-29J11'),
('Car. 2', 10, '1658-01-30J11/1659-01-29J11'),
('Car. 2', 11, '1659-01-30J11/1660-01-29J11'),
('Car. 2', 12, '1660-01-30J11/1661-01-29J11'),
('Car. 2', 13, '1661-01-30J11/1662-01-29J11'),
('Car. 2', 14, '1662-01-30J11/1663-01-29J11'),
('Car. 2', 15, '1663-01-30J11/1664-01-29J11'),
('Car. 2', 16, '1664-01-30J11/1665-01-29J11'),
('Car. 2', 17, '1665-01-30J11/1666-01-29J11'),
('Car. 2', 18, '1666-01-30J11/1667-01-29J11'),
('Car. 2', 19, '1667-01-30J11/1668-01-29J11'),
('Car. 2', 20, '1668-01-30J11/1669-01-29J11'),
('Car. 2', 21, '1669-01-30J11/1670-01-29J11'),
('Car. 2', 22, '1670-01-30J11/1671-01-29J11'),
('Car. 2', 23, '1671-01-30J11/1672-01-29J11'),
('Car. 2', 24, '1672-01-30J11/1673-01-29J11'),
('Car. 2', 25, '1673-01-30J11/1674-01-29J11'),
('Car. 2', 26, '1674-01-30J11/1675-01-29J11'),
('Car. 2', 27, '1675-01-30J11/1676-01-29J11'),
('Car. 2', 28, '1676-01-30J11/1677-01-29J11'),
('Car. 2', 29, '1677-01-30J11/1678-01-29J11'),
('Car. 2', 30, '1678-01-30J11/1679-01-29J11'),
('Car. 2', 31, '1679-01-30J11/1680-01-29J11'),
('Car. 2', 32, '1680-01-30J11/1681-01-29J11'),
('Car. 2', 33, '1681-01-30J11/1682-01-29J11'),
('Car. 2', 34, '1682-01-30J11/1683-01-29J11'),
('Car. 2', 35, '1683-01-30J11/1684-01-29J11'),
('Car. 2', 36, '1684-01-30J11/1685-01-29J11'),
('Car. 2', 37, '1685-01-30J11/1685-02-06J11'),
('Jac. 2', 1, '1685-02-06J11/1686-02-05J11'),
('Jac. 2', 2, '1686-02-06J11/1687-02-05J11'),
('Jac. 2', 3, '1687-02-06J11/1688-02-05J11'),
('Jac. 2', 4, '1688-02-06J11/1688-12-11J11'),
('W. & M.', 1, '1689-02-13J11/1690-02-12J11'),
('W. & M.', 2, '1690-02-13J11/1691-02-12J11'),
('W. & M.', 3, '1691-02-13J11/1692-02-12J11'),
('W. & M.', 4, '1692-02-13J11/1693-02-12J11'),
('W. & M.', 5, '1693-02-13J11/1694-02-12J11'),
('W. & M.', 6, '1694-02-13J11/1694-12-27J11'),
('Will. 3', 1, '1694-12-28J11/1695-12-27J11'),
('Will. 3', 2, '1695-12-28J11/1696-12-27J11'),
('Will. 3', 3, '1696-12-28J11/1697-12-27J11'),
('Will. 3', 4, '1697-12-28J11/1698-12-27J11'),
('Will. 3', 5, '1698-12-28J11/1699-12-27J11'),
('Will. 3', 6, '1699-12-28J11/1700-12-27J11'),
('Will. 3', 7, '1700-12-28J11/1701-12-27J11'),
('Will. 3', 8, '1701-12-28J11/1702-03-08J11'),
('Ann.', 1, '1702-03-08J11/1703-03-07J11'),
('Ann.', 2, '1703-03-08J11/1704-03-07J11'),
('Ann.', 3, '1704-03-08J11/1705-03-07J11'),
('Ann.', 4, '1705-03-08J11/1706-03-07J11'),
('Ann.', 5, '1706-03-08J11/1707-03-07J11'),
('Ann.', 6, '1707-03-08J11/1708-03-07J11'),
('Ann.', 7, '1708-03-08J11/1709-03-07J11'),
('Ann.', 8, '1709-03-08J11/1710-03-07J11'),
('Ann.', 9, '1710-03-08J11/1711-03-07J11'),
('Ann.', 10, '1711-03-08J11/1712-03-07J11'),
('Ann.', 11, '1712-03-08J11/1713-03-07J11'),
('Ann.', 12, '1713-03-08J11/1714-03-07J11'),
('Ann.', 13, '1714-03-08J11/1714-08-01J11'),
('Geo.', 1, '1714-08-01J11/1715-07-31J11'),
('Geo.', 2, '1715-08-01J11/1716-07-31J11'),
('Geo.', 3, '1716-08-01J11/1717-07-31J11'),
('Geo.', 4, '1717-08-01J11/1718-07-31J11'),
('Geo.', 5, '1718-08-01J11/1719-07-31J11'),
('Geo.', 6, '1719-08-01J11/1720-07-31J11'),
('Geo.', 7, '1720-08-01J11/1721-07-31J11'),
('Geo.', 8, '1721-08-01J11/1722-07-31J11'),
('Geo.', 9, '1722-08-01J11/1723-07-31J11'),
('Geo.', 10, '1723-08-01J11/1724-07-31J11'),
('Geo.', 11, '1724-08-01J11/1725-07-31J11'),
('Geo.', 12, '1725-08-01J11/1726-07-31J11'),
('Geo.', 13, '1726-08-01J11/1727-06-11J11'),
('Geo. 2', 1, '1727-06-11J11/1728-06-10J11'),
('Geo. 2', 2, '1728-06-11J11/1729-06-10J11'),
('Geo. 2', 3, '1729-06-11J11/1730-06-10J11'),
('Geo. 2', 4, '1730-06-11J11/1731-06-10J11'),
('Geo. 2', 5, '1731-06-11J11/1732-06-10J11'),
('Geo. 2', 6, '1732-06-11J11/1733-06-10J11'),
('Geo. 2', 7, '1733-06-11J11/1734-06-10J11'),
('Geo. 2', 8, '1734-06-11J11/1735-06-10J11'),
('Geo. 2', 9, '1735-06-11J11/1736-06-10J11'),
('Geo. 2', 10, '1736-06-11J11/1737-06-10J11'),
('Geo. 2', 11, '1737-06-11J11/1738-06-10J11'),
('Geo. 2', 12, '1738-06-11J11/1739-06-10J11'),
('Geo. 2', 13, '1739-06-11J11/1740-06-10J11'),
('Geo. 2', 14, '1740-06-11J11/1741-06-10J11'),
('Geo. 2', 15, '1741-06-11J11/1742-06-10J11'),
('Geo. 2', 16, '1742-06-11J11/1743-06-10J11'),
('Geo. 2', 17, '1743-06-11J11/1744-06-10J11'),
('Geo. 2', 18, '1744-06-11J11/1745-06-10J11'),
('Geo. 2', 19, '1745-06-11J11/1746-06-10J11'),
('Geo. 2', 20, '1746-06-11J11/1747-06-10J11'),
('Geo. 2', 21, '1747-06-11J11/1748-06-10J11'),
('Geo. 2', 22, '1748-06-11J11/1749-06-10J11'),
('Geo. 2', 23, '1749-06-11J11/1750-06-10J11'),
('Geo. 2', 24, '1750-06-11J11/1751-06-10J11'),
('Geo. 2', 25, '1751-06-11J11/1752-06-10J11'),
('Geo. 2', 26, '1752-06-11J11/1753-06-10'),
('Geo. 2', 27, '1753-06-11/1754-06-10'),
('Geo. 2', 28, '1754-06-11/1755-06-10'),
('Geo. 2', 29, '1755-06-11/1756-06-10'),
('Geo. 2', 30, '1756-06-11/1757-06-10'),
('Geo. 2', 31, '1757-06-11/1758-06-10'),
('Geo. 2', 32, '1758-06-11/1759-06-10'),
('Geo. 2', 33, '1759-06-11/1760-06-10'),
('Geo. 2', 34, '1760-06-11/1760-10-25'),
('Geo. 3', 1, '1760-10-25/1761-10-24'),
('Geo. 3', 2, '1761-10-25/1762-10-24'),
('Geo. 3', 3, '1762-10-25/1763-10-24'),
('Geo. 3', 4, '1763-10-25/1764-10-24'),
('Geo. 3', 5, '1764-10-25/1765-10-24'),
('Geo. 3', 6, '1765-10-25/1766-10-24'),
('Geo. 3', 7, '1766-10-25/1767-10-24'),
('Geo. 3', 8, '1767-10-25/1768-10-24'),
('Geo. 3', 9, '1768-10-25/1769-10-24'),
('Geo. 3', 10, '1769-10-25/1770-10-24'),
('Geo. 3', 11, '1770-10-25/1771-10-24'),
('Geo. 3', 12, '1771-10-25/1772-10-24'),
('Geo. 3', 13, '1772-10-25/1773-10-24'),
('Geo. 3', 14, '1773-10-25/1774-10-24'),
('Geo. 3', 15, '1774-10-25/1775-10-24'),
('Geo. 3', 16, '1775-10-25/1776-10-24'),
('Geo. 3', 17, '1776-10-25/1777-10-24'),
('Geo. 3', 18, '1777-10-25/1778-10-24'),
('Geo. 3', 19, '1778-10-25/1779-10-24'),
('Geo. 3', 20, '1779-10-25/1780-10-24'),
('Geo. 3', 21, '1780-10-25/1781-10-24'),
('Geo. 3', 22, '1781-10-25/1782-10-24'),
('Geo. 3', 23, '1782-10-25/1783-10-24'),
('Geo. 3', 24, '1783-10-25/1784-10-24'),
('Geo. 3', 25, '1784-10-25/1785-10-24'),
('Geo. 3', 26, '1785-10-25/1786-10-24'),
('Geo. 3', 27, '1786-10-25/1787-10-24'),
('Geo. 3', 28, '1787-10-25/1788-10-24'),
('Geo. 3', 29, '1788-10-25/1789-10-24'),
('Geo. 3', 30, '1789-10-25/1790-10-24'),
('Geo. 3', 31, '1790-10-25/1791-10-24'),
('Geo. 3', 32, '1791-10-25/1792-10-24'),
('Geo. 3', 33, '1792-10-25/1793-10-24'),
('Geo. 3', 34, '1793-10-25/1794-10-24'),
('Geo. 3', 35, '1794-10-25/1795-10-24'),
('Geo. 3', 36, '1795-10-25/1796-10-24'),
('Geo. 3', 37, '1796-10-25/1797-10-24'),
('Geo. 3', 38, '1797-10-25/1798-10-24'),
('Geo. 3', 39, '1798-10-25/1799-10-24'),
('Geo. 3', 40, '1799-10-25/1800-10-24'),
('Geo. 3', 41, '1800-10-25/1801-10-24'),
('Geo. 3', 42, '1801-10-25/1802-10-24'),
('Geo. 3', 43, '1802-10-25/1803-10-24'),
('Geo. 3', 44, '1803-10-25/1804-10-24'),
('Geo. 3', 45, '1804-10-25/1805-10-24'),
('Geo. 3', 46, '1805-10-25/1806-10-24'),
('Geo. 3', 47, '1806-10-25/1807-10-24'),
('Geo. 3', 48, '1807-10-25/1808-10-24'),
('Geo. 3', 49, '1808-10-25/1809-10-24'),
('Geo. 3', 50, '1809-10-25/1810-10-24'),
('Geo. 3', 51, '1810-10-25/1811-10-24'),
('Geo. 3', 52, '1811-10-25/1812-10-24'),
('Geo. 3', 53, '1812-10-25/1813-10-24'),
('Geo. 3', 54, '1813-10-25/1814-10-24'),
('Geo. 3', 55, '1814-10-25/1815-10-24'),
('Geo. 3', 56, '1815-10-25/1816-10-24'),
('Geo. 3', 57, '1816-10-25/1817-10-24'),
('Geo. 3', 58, '1817-10-25/1818-10-24'),
('Geo. 3', 59, '1818-10-25/1819-10-24'),
('Geo. 3', 60, '1819-10-25/1820-01-29'),
('Geo. 4', 1, '1820-01-29/1821-01-28'),
('Geo. 4', 2, '1821-01-29/1822-01-28'),
('Geo. 4', 3, '1822-01-29/1823-01-28'),
('Geo. 4', 4, '1823-01-29/1824-01-28'),
('Geo. 4', 5, '1824-01-29/1825-01-28'),
('Geo. 4', 6, '1825-01-29/1826-01-28'),
('Geo. 4', 7, '1826-01-29/1827-01-28'),
('Geo. 4', 8, '1827-01-29/1828-01-28'),
('Geo. 4', 9, '1828-01-29/1829-01-28'),
('Geo. 4', 10, '1829-01-29/1830-01-28'),
('Geo. 4', 11, '1830-01-29/1830-06-26'),
('Will. 4', 1, '1830-06-26/1831-06-25'),
('Will. 4', 2, '1831-06-26/1832-06-25'),
('Will. 4', 3, '1832-06-26/1833-06-25'),
('Will. 4', 4, '1833-06-26/1834-06-25'),
('Will. 4', 5, '1834-06-26/1835-06-25'),
('Will. 4', 6, '1835-06-26/1836-06-25'),
('Will. 4', 7, '1836-06-26/1837-06-20'),
('Vict.', 1, '1837-06-20/1838-06-19'),
('Vict.', 2, '1838-06-20/1839-06-19'),
('Vict.', 3, '1839-06-20/1840-06-19'),
('Vict.', 4, '1840-06-20/1841-06-19'),
('Vict.', 5, '1841-06-20/1842-06-19'),
('Vict.', 6, '1842-06-20/1843-06-19'),
('Vict.', 7, '1843-06-20/1844-06-19'),
('Vict.', 8, '1844-06-20/1845-06-19'),
('Vict.', 9, '1845-06-20/1846-06-19'),
('Vict.', 10, '1846-06-20/1847-06-19'),
('Vict.', 11, '1847-06-20/1848-06-19'),
('Vict.', 12, '1848-06-20/1849-06-19'),
('Vict.', 13, '1849-06-20/1850-06-19'),
('Vict.', 14, '1850-06-20/1851-06-19'),
('Vict.', 15, '1851-06-20/1852-06-19'),
('Vict.', 16, '1852-06-20/1853-06-19'),
('Vict.', 17, '1853-06-20/1854-06-19'),
('Vict.', 18, '1854-06-20/1855-06-19'),
('Vict.', 19, '1855-06-20/1856-06-19'),
('Vict.', 20, '1856-06-20/1857-06-19'),
('Vict.', 21, '1857-06-20/1858-06-19'),
('Vict.', 22, '1858-06-20/1859-06-19'),
('Vict.', 23, '1859-06-20/1860-06-19'),
('Vict.', 24, '1860-06-20/1861-06-19'),
('Vict.', 25, '1861-06-20/1862-06-19'),
('Vict.', 26, '1862-06-20/1863-06-19'),
('Vict.', 27, '1863-06-20/1864-06-19'),
('Vict.', 28, '1864-06-20/1865-06-19'),
('Vict.', 29, '1865-06-20/1866-06-19'),
('Vict.', 30, '1866-06-20/1867-06-19'),
('Vict.', 31, '1867-06-20/1868-06-19'),
('Vict.', 32, '1868-06-20/1869-06-19'),
('Vict.', 33, '1869-06-20/1870-06-19'),
('Vict.', 34, '1870-06-20/1871-06-19'),
('Vict.', 35, '1871-06-20/1872-06-19'),
('Vict.', 36, '1872-06-20/1873-06-19'),
('Vict.', 37, '1873-06-20/1874-06-19'),
('Vict.', 38, '1874-06-20/1875-06-19'),
('Vict.', 39, '1875-06-20/1876-06-19'),
('Vict.', 40, '1876-06-20/1877-06-19'),
('Vict.', 41, '1877-06-20/1878-06-19'),
('Vict.', 42, '1878-06-20/1879-06-19'),
('Vict.', 43, '1879-06-20/1880-06-19'),
('Vict.', 44, '1880-06-20/1881-06-19'),
('Vict.', 45, '1881-06-20/1882-06-19'),
('Vict.', 46, '1882-06-20/1883-06-19'),
('Vict.', 47, '1883-06-20/1884-06-19'),
('Vict.', 48, '1884-06-20/1885-06-19'),
('Vict.', 49, '1885-06-20/1886-06-19'),
('Vict.', 50, '1886-06-20/1887-06-19'),
('Vict.', 51, '1887-06-20/1888-06-19'),
('Vict.', 52, '1888-06-20/1889-06-19'),
('Vict.', 53, '1889-06-20/1890-06-19'),
('Vict.', 54, '1890-06-20/1891-06-19'),
('Vict.', 55, '1891-06-20/1892-06-19'),
('Vict.', 56, '1892-06-20/1893-06-19'),
('Vict.', 57, '1893-06-20/1894-06-19'),
('Vict.', 58, '1894-06-20/1895-06-19'),
('Vict.', 59, '1895-06-20/1896-06-19'),
('Vict.', 60, '1896-06-20/1897-06-19'),
('Vict.', 61, '1897-06-20/1898-06-19'),
('Vict.', 62, '1898-06-20/1899-06-19'),
('Vict.', 63, '1899-06-20/1900-06-19'),
('Vict.', 64, '1900-06-20/1901-01-22'),
('Edw. 7', 1, '1901-01-22/1902-01-21'),
('Edw. 7', 2, '1902-01-22/1903-01-21'),
('Edw. 7', 3, '1903-01-22/1904-01-21'),
('Edw. 7', 4, '1904-01-22/1905-01-21'),
('Edw. 7', 5, '1905-01-22/1906-01-21'),
('Edw. 7', 6, '1906-01-22/1907-01-21'),
('Edw. 7', 7, '1907-01-22/1908-01-21'),
('Edw. 7', 8, '1908-01-22/1909-01-21'),
('Edw. 7', 9, '1909-01-22/1910-01-21'),
('Edw. 7', 10, '1910-01-22/1910-05-06'),
('Geo. 5', 1, '1910-05-06/1911-05-05'),
('Geo. 5', 2, '1911-05-06/1912-05-05'),
('Geo. 5', 3, '1912-05-06/1913-05-05'),
('Geo. 5', 4, '1913-05-06/1914-05-05'),
('Geo. 5', 5, '1914-05-06/1915-05-05'),
('Geo. 5', 6, '1915-05-06/1916-05-05'),
('Geo. 5', 7, '1916-05-06/1917-05-05'),
('Geo. 5', 8, '1917-05-06/1918-05-05'),
('Geo. 5', 9, '1918-05-06/1919-05-05'),
('Geo. 5', 10, '1919-05-06/1920-05-05'),
('Geo. 5', 11, '1920-05-06/1921-05-05'),
('Geo. 5', 12, '1921-05-06/1922-05-05'),
('Geo. 5', 13, '1922-05-06/1923-05-05'),
('Geo. 5', 14, '1923-05-06/1924-05-05'),
('Geo. 5', 15, '1924-05-06/1925-05-05'),
('Geo. 5', 16, '1925-05-06/1926-05-05'),
('Geo. 5', 17, '1926-05-06/1927-05-05'),
('Geo. 5', 18, '1927-05-06/1928-05-05'),
('Geo. 5', 19, '1928-05-06/1929-05-05'),
('Geo. 5', 20, '1929-05-06/1930-05-05'),
('Geo. 5', 21, '1930-05-06/1931-05-05'),
('Geo. 5', 22, '1931-05-06/1932-05-05'),
('Geo. 5', 23, '1932-05-06/1933-05-05'),
('Geo. 5', 24, '1933-05-06/1934-05-05'),
('Geo. 5', 25, '1934-05-06/1935-05-05'),
('Geo. 5', 26, '1935-05-06/1936-01-20'),
('Edw. 8', 1, '1936-01-20/1936-12-11'),
('Geo. 6', 1, '1936-12-11/1937-12-10'),
('Geo. 6', 2, '1937-12-11/1938-12-10'),
('Geo. 6', 3, '1938-12-11/1939-12-10'),
('Geo. 6', 4, '1939-12-11/1940-12-10'),
('Geo. 6', 5, '1940-12-11/1941-12-10'),
('Geo. 6', 6, '1941-12-11/1942-12-10'),
('Geo. 6', 7, '1942-12-11/1943-12-10'),
('Geo. 6', 8, '1943-12-11/1944-12-10'),
('Geo. 6', 9, '1944-12-11/1945-12-10'),
('Geo. 6', 10, '1945-12-11/1946-12-10'),
('Geo. 6', 11, '1946-12-11/1947-12-10'),
('Geo. 6', 12, '1947-12-11/1948-12-10'),
('Geo. 6', 13, '1948-12-11/1949-12-10'),
('Geo. 6', 14, '1949-12-11/1950-12-10'),
('Geo. 6', 15, '1950-12-11/1951-12-10'),
('Geo. 6', 16, '1951-12-11/1952-02-05'),
('Eliz. 2', 1, '1952-02-06/1953-02-05'),
('Eliz. 2', 2, '1953-02-06/1954-02-05'),
('Eliz. 2', 3, '1954-02-06/1955-02-05'),
('Eliz. 2', 4, '1955-02-06/1956-02-05'),
('Eliz. 2', 5, '1956-02-06/1957-02-05'),
('Eliz. 2', 6, '1957-02-06/1958-02-05'),
('Eliz. 2', 7, '1958-02-06/1959-02-05'),
('Eliz. 2', 8, '1959-02-06/1960-02-05'),
('Eliz. 2', 9, '1960-02-06/1961-02-05'),
('Eliz. 2', 10, '1961-02-06/1962-02-05'),
('Eliz. 2', 11, '1962-02-06/1963-02-05'),
('Eliz. 2', 12, '1963-02-06/1964-02-05'),
('Eliz. 2', 13, '1964-02-06/1965-02-05'),
('Eliz. 2', 14, '1965-02-06/1966-02-05'),
('Eliz. 2', 15, '1966-02-06/1967-02-05'),
('Eliz. 2', 16, '1967-02-06/1968-02-05'),
('Eliz. 2', 17, '1968-02-06/1969-02-05'),
('Eliz. 2', 18, '1969-02-06/1970-02-05'),
('Eliz. 2', 19, '1970-02-06/1971-02-05'),
('Eliz. 2', 20, '1971-02-06/1972-02-05'),
('Eliz. 2', 21, '1972-02-06/1973-02-05'),
('Eliz. 2', 22, '1973-02-06/1974-02-05'),
('Eliz. 2', 23, '1974-02-06/1975-02-05'),
('Eliz. 2', 24, '1975-02-06/1976-02-05'),
('Eliz. 2', 25, '1976-02-06/1977-02-05'),
('Eliz. 2', 26, '1977-02-06/1978-02-05'),
('Eliz. 2', 27, '1978-02-06/1979-02-05'),
('Eliz. 2', 28, '1979-02-06/1980-02-05'),
('Eliz. 2', 29, '1980-02-06/1981-02-05'),
('Eliz. 2', 30, '1981-02-06/1982-02-05'),
('Eliz. 2', 31, '1982-02-06/1983-02-05'),
('Eliz. 2', 32, '1983-02-06/1984-02-05'),
('Eliz. 2', 33, '1984-02-06/1985-02-05'),
('Eliz. 2', 34, '1985-02-06/1986-02-05'),
('Eliz. 2', 35, '1986-02-06/1987-02-05'),
('Eliz. 2', 36, '1987-02-06/1988-02-05'),
('Eliz. 2', 37, '1988-02-06/1989-02-05'),
('Eliz. 2', 38, '1989-02-06/1990-02-05'),
('Eliz. 2', 39, '1990-02-06/1991-02-05'),
('Eliz. 2', 40, '1991-02-06/1992-02-05'),
('Eliz. 2', 41, '1992-02-06/1993-02-05'),
('Eliz. 2', 42, '1993-02-06/1994-02-05'),
('Eliz. 2', 43, '1994-02-06/1995-02-05'),
('Eliz. 2', 44, '1995-02-06/1996-02-05'),
('Eliz. 2', 45, '1996-02-06/1997-02-05'),
('Eliz. 2', 46, '1997-02-06/1998-02-05'),
('Eliz. 2', 47, '1998-02-06/1999-02-05'),
('Eliz. 2', 48, '1999-02-06/2000-02-05'),
('Eliz. 2', 49, '2000-02-06/2001-02-05'),
('Eliz. 2', 50, '2001-02-06/2002-02-05'),
('Eliz. 2', 51, '2002-02-06/2003-02-05'),
('Eliz. 2', 52, '2003-02-06/2004-02-05'),
('Eliz. 2', 53, '2004-02-06/2005-02-05'),
('Eliz. 2', 54, '2005-02-06/2006-02-05'),
('Eliz. 2', 55, '2006-02-06/2007-02-05'),
('Eliz. 2', 56, '2007-02-06/2008-02-05'),
('Eliz. 2', 57, '2008-02-06/2009-02-05'),
('Eliz. 2', 58, '2009-02-06/2010-02-05'),
('Eliz. 2', 59, '2010-02-06/2011-02-05'),
('Eliz. 2', 60, '2011-02-06/2012-02-05'),
('Eliz. 2', 61, '2012-02-06/2013-02-05'),
('Eliz. 2', 62, '2013-02-06/2014-02-05'),
('Eliz. 2', 63, '2014-02-06/2015-02-05'),
('Eliz. 2', 64, '2015-02-06/2016-02-05'),
('Eliz. 2', 65, '2016-02-06/2017-02-05'),
('Eliz. 2', 66, '2017-02-06/2018-02-05'),
('Eliz. 2', 67, '2018-02-06/2019-02-05'),
('Eliz. 2', 68, '2019-02-06/2020-02-05'),
('Eliz. 2', 69, '2020-02-06/2021-02-05'),
('Eliz. 2', 70, '2021-02-06/2022-02-05'),
('Eliz. 2', 71, '2022-02-06/2022-09-08');

INSERT INTO calendar.type VALUES
('B', 'Bahá''ic', 'gregorian', 6560, 1412, 19, 20, 4, 1461, 0, 3, 1, 19, 0, 0, 184, 274273, -50),
('C', 'Coptic', 'arithmetic', 4996, 124, 0, 13, 4, 1461, 0, 3, 1, 30, 0, 0, NULL, NULL, NULL),
('E', 'Egyptian', 'arithmetic', 3968, 47, 0, 13, 1, 365, 0, 0, 1, 30, 0, 0, NULL, NULL, NULL),
('F', 'French Republican', 'gregorian', 6504, 111, 0, 13, 4, 1461, 0, 3, 1, 30, 0, 0, 396, 578797, -51),
('G', 'Gregorian', 'default', 4716, 1401, 2, 12, 4, 1461, 0, 3, 5, 153, 2, 2, 184, 274277, -38),
('H', 'Hebrew', 'hebrew', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('I', 'Islamic', 'arithmetic', 5519, 7664, 0, 12, 30, 10631, 14, 15, 100, 2951, 51, 10, NULL, NULL, NULL),
('J', 'Julian', 'arithmetic', 4716, 1401, 2, 12, 4, 1461, 0, 3, 5, 153, 2, 2, NULL, NULL, NULL),
('S', 'Saka', 'saka', 4794, 1348, 1, 12, 4, 1461, 0, 3, 1, 31, 0, 0, 184, 274073, -36),
('T', 'Ethiopian', 'arithmetic', 4720, 124, 0, 13, 4, 1461, 0, 3, 1, 30, 0, 0, NULL, NULL, NULL);

--
-- ADD TABLE PRIMARY KEY CONSTRAINTS
--

ALTER TABLE ONLY calendar.hebrewmonth
    ADD CONSTRAINT hebrewmonth_pk PRIMARY KEY (k, m);

ALTER TABLE ONLY calendar.locale
    ADD CONSTRAINT locale_pk PRIMARY KEY (localeid);

ALTER TABLE ONLY calendar.monthday
    ADD CONSTRAINT monthday_pk PRIMARY KEY (type, monthinteger);

ALTER TABLE ONLY calendar.monthlong
    ADD CONSTRAINT monthlong_pk PRIMARY KEY (type, locale, monthinteger);

ALTER TABLE ONLY calendar.monthshort
    ADD CONSTRAINT monthshort_pk PRIMARY KEY (type, monthinteger);

ALTER TABLE ONLY calendar.part
    ADD CONSTRAINT part_pk PRIMARY KEY (partid);

ALTER TABLE ONLY calendar.qualifier
    ADD CONSTRAINT qualifier_pk PRIMARY KEY (qualifierid);

ALTER TABLE ONLY calendar.qualifierlocale
    ADD CONSTRAINT qualifierlocale_pk PRIMARY KEY (qualifier, locale);

ALTER TABLE ONLY calendar.regnalyear
    ADD CONSTRAINT regnalyear_pk PRIMARY KEY (monarch, regnalyearnumber);

ALTER TABLE ONLY calendar.type
    ADD CONSTRAINT type_pk PRIMARY KEY (typeid);

--
-- ADD TABLE FOREIGN KEY CONSTRAINTS AND INDEXES
--

CREATE INDEX fki_monthlong_locale_fk ON calendar.monthlong USING btree (locale);

ALTER TABLE ONLY calendar.monthlong
    ADD CONSTRAINT monthlong_locale_fk FOREIGN KEY (locale) REFERENCES calendar.locale(localeid) NOT VALID;

CREATE INDEX fki_part_type_fk ON calendar.part USING btree (type);

ALTER TABLE ONLY calendar.part
    ADD CONSTRAINT part_type_fk FOREIGN KEY (type) REFERENCES calendar.type(typeid) NOT VALID;

CREATE INDEX fki_qualifierlocale_locale_fk ON calendar.qualifierlocale USING btree (locale);

ALTER TABLE ONLY calendar.qualifierlocale
    ADD CONSTRAINT qualifierlocale_locale_fk FOREIGN KEY (locale) REFERENCES calendar.locale(localeid) NOT VALID;

CREATE INDEX fki_qualifierlocale_qualifier_fk ON calendar.qualifierlocale USING btree (qualifier);

ALTER TABLE ONLY calendar.qualifierlocale
    ADD CONSTRAINT qualifierlocale_qualifier_fk FOREIGN KEY (qualifier) REFERENCES calendar.qualifier(qualifierid) NOT VALID;

--
-- CREATE CASTS
--

CREATE CAST (calendar.historicdate AS date)
    WITH FUNCTION calendar.date(historicdate calendar.historicdate)
    AS ASSIGNMENT;

CREATE CAST (calendar.historicdate AS text)
    WITH FUNCTION calendar.historicdatetext(historicdate calendar.historicdate)
    AS ASSIGNMENT;

CREATE CAST (calendar.historicdaterange AS daterange)
    WITH FUNCTION calendar.daterange(historicdaterange calendar.historicdaterange)
    AS ASSIGNMENT;

CREATE CAST (calendar.historicdaterange AS text)
    WITH FUNCTION calendar.historicdaterangetext(historicdaterange calendar.historicdaterange)
    AS ASSIGNMENT;

CREATE CAST (text AS calendar.historicdate)
    WITH FUNCTION calendar.historicdate(datetext text)
    AS ASSIGNMENT;

CREATE CAST (text AS calendar.historicdaterange)
    WITH FUNCTION calendar.historicdaterange(daterangetext text)
    AS ASSIGNMENT;

--
-- CREATE CAST CHECKS
--

CREATE FUNCTION calendar.is_historicdate(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

DECLARE
  qualifierisinstant boolean;

BEGIN
  PERFORM $1::calendar.historicdate;
  SELECT qualifier.qualifierisinstant
  INTO qualifierisinstant
  FROM calendar.qualifier
  WHERE qualifier.qualifierid = ($1::calendar.historicdate).qualifier;
  RETURN qualifierisinstant;
EXCEPTION WHEN OTHERS THEN
  RETURN FALSE;
end;
$$;

CREATE FUNCTION calendar.is_historicdaterange(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$

BEGIN
  PERFORM $1::calendar.historicdaterange;
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RETURN FALSE;
end;
$$;

--
-- CREATE DOMAINS
--

CREATE DOMAIN calendar.historicdatetext AS text
    CONSTRAINT historicdatetext_check CHECK (calendar.is_historicdate(VALUE));

CREATE DOMAIN calendar.historicdaterangetext AS text
    CONSTRAINT historicdaterangetext_check CHECK (calendar.is_historicdaterange(VALUE));

$_pg_tle_$
);

