-- select EXTRACT(YEAR from "date")::int+21 from games limit 10;

-- select id, EXTRACT(YEAR from "date") from games limit 10;
-- update games set season = EXTRACT(YEAR from "date")::int

update games set season = EXTRACT(YEAR from "date")::int-1 where date in (
'2022-01-01',
'2021-01-01',
'2018-01-01',
'2016-01-01',
'2013-01-07',
'2007-01-03',
'2006-01-02',
'2003-01-01',
'2001-01-01',
'1999-01-01',
'1996-01-01',
'1995-01-02',
'1994-01-01',
'1993-01-01',
'1992-01-01',
'1991-01-01',
'1990-01-01',
'1989-01-02',
'1988-01-01',
'1981-01-01',
'1979-01-01',
'1978-01-02',
'1975-01-01',
'1973-01-01',
'1971-01-01',
'1970-01-01',
'1925-01-01'
);
