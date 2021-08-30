CREATE OR REPLACE FUNCTION coach_full_name(coach_row coaches)
RETURNS TEXT AS $$
DECLARE full_name text;
BEGIN

    full_name := coach_row.first_name;
    
    IF coach_row.middle_name IS NOT NULL THEN
        full_name := full_name || ' ' || coach_row.middle_name;
    END IF;
    
    full_name := full_name || ' ' || coach_row.last_name;
    
    IF coach_row.suffix IS NOT NULL THEN
        full_name := full_name || ' ' || coach_row.suffix;
    END IF;
    
    RETURN full_name;

END;
$$ LANGUAGE plpgsql STABLE;
