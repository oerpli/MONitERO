\timing on
-- Import both fork datasets
-- Import XMV data
\set currency defs_xmv.sql
\i 0_import_fork.sql
-- Import XMO data
\set currency defs_xmo.sql
\i 0_import_fork.sql


-- Now for each pair, do pairwise analysis
\set xmo ./defs_xmo.sql
\set xmv ./defs_xmv.sql
\set xmr ./defs_xmr.sql

-- Remove new outputs from rings with matching keyimg:
\set one :xmv
\set two :xmo
\i ./4_remove_fork_inputs.sql
\set one :xmo
\set two :xmv
\i ./4_remove_fork_inputs.sql
\set one :xmv
\set two :xmr
\i ./4_remove_fork_inputs.sql
\set one :xmo
\set two :xmr
\i ./4_remove_fork_inputs.sql
-- (XMV, XMO)
\set one :xmv
\set two :xmo
\i ./5_reduce_common_rings.sql

-- (XMR, XMV)
\set one :xmr
\set two :xmv
\i ./5_reduce_common_rings.sql

-- (XMR, XMO)
\set one :xmr
\set two :xmo
\i ./5_reduce_common_rings.sql

-- Call ZMR a few times on XMV and XMO. Does not take long, so nvm the primitive implementation
\i :xmv
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql

\i :xmo
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql

