BEGIN;
LOCK TABLE ring IN SHARE MODE;

SET LOCAL  work_mem = '2097151 kB';

CREATE TABLE ring_new AS 
SELECT inid,outid,'unknown'::input_type as matched, null::input_type as matched_merge, null::input_type as matched_newest FROM ring
ORDER  BY inid asc,outid asc;  -- optionally order rows favorably while being at it.

ALTER TABLE tbl_new
   ALTER COLUMN matched SET NOT NULL
 , ALTER COLUMN tbl_uuid SET DEFAULT 'unknown'
 , ADD CONSTRAINT UNIQUE(inid,outid);

-- more constraints, indices, triggers?

DROP TABLE ring;
ALTER TABLE ring_new RENAME ring;

-- recreate views etc. if any
COMMIT;