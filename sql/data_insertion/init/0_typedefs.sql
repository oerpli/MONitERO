-- TX input consists of ring, ring members are either real or mixin, though for some of them status is not yet known
-- Could be modelled by boolean (true,false, null) more efficiently, but maybe more confusing.
-- Thus this user-defined type and its cast from bool function:
DROP TYPE IF EXISTS input_type CASCADE;
CREATE TYPE input_type AS ENUM ('real', 'mixin','unknown','spent');

-- as there are only 3 values for bool but 4 values for input_type, spent does not have a mapping to bool. it's between real and mixin.
CREATE OR REPLACE FUNCTION bool_to_input(value boolean)
RETURNS input_type AS $BODY$
SELECT CASE
	WHEN $1 IS true THEN 'real'::input_type
	WHEN $1 IS false THEN 'mixin'::input_type
	ELSE 'unknown'::input_type
END;
$BODY$
LANGUAGE 'sql' IMMUTABLE;


-- maps 
CREATE OR REPLACE FUNCTION undecided(value input_type)
RETURNS bool as $BODY$
SELECT CASE
	WHEN $1 = 'unknown' THEN true
	WHEN $1 = 'spent' THEN true
	-- real and mixin are decided, return false
	ELSE false
END;
$BODY$
LANGUAGE 'sql' IMMUTABLE;
