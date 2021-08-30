CREATE FUNCTION coach_full_name(coach_row coaches)
RETURNS TEXT AS $$
select first_name from coaches;
$$ LANGUAGE sql STABLE;
