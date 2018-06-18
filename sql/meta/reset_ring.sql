-- If some error happens while linking, use this to reset all inputs to 'unknown'.
CREATE TABLE ring_new AS 
SELECT
      inid
    , outid,'unknown'::input_type as matched
    , null::input_type as matched_merge
    , null::input_type as matched_newest
FROM ring ORDER  BY inid asc,outid asc;

ALTER TABLE ring_new
   ALTER COLUMN matched SET NOT NULL
 , ALTER COLUMN matched SET DEFAULT 'unknown'::input_type;
-- more constraints, indices, triggers?

DROP TABLE ring;
-- ALTER TABLE ring RENAME TO ring_old; 
ALTER TABLE ring_new RENAME TO ring;

CREATE UNIQUE INDEX index_ring ON ring (inid, outid);
CREATE INDEX index_ring_in2 ON ring (inid);
CREATE INDEX index_ring_in ON ring USING HASH (inid);
CREATE INDEX index_ring_out ON ring USING HASH (outid);