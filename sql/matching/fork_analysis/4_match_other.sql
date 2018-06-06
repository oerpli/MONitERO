\echo '>>Outputs spent in XMR (pre fork) are also spent in forked currency'
WITH spent as (
	SELECT outid from ring natural join txout natural join tx where matched = 'real' and block < fork(:curr) 
)
UPDATE :ring
SET matched = 'mixin'
FROM spent
WHERE legacy -- legacy not necessary anymore
  and undecided(matched)
  and spent.outid = :ring.outid;
