update games set season = EXTRACT(YEAR from "date")::int;
