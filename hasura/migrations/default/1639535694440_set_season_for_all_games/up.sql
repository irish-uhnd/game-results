select EXTRACT(YEAR from "date")::int+21 from games limit 10;
select id, EXTRACT(YEAR from "date") from games limit 10;

update games set season = EXTRACT(YEAR from "date")::int;
