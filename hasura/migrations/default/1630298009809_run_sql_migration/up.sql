CREATE OR REPLACE FUNCTION coach_full_name(coach_row coaches)
RETURNS TEXT AS $$
DECLARE full_name text;
BEGIN
select first_name from coaches;
END;
$$ LANGUAGE plpgsql STABLE;
