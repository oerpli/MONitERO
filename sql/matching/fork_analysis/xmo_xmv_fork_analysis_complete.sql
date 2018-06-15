-- Run XMV analysis, import data etc
\set currency defs_xmv.sql
\i 0_run_fork_analysis.sql
-- Run XMO analysis, import data etc
\set currency defs_xmo.sql
\i 0_run_fork_analysis.sql

-- Run combination analysis of XMV and XMO
\i combine_forks.sql
-- This enables additional ZMR for both, so use DEFS again and call ZMR several times
\set currency defs_xmv.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
-- Newly found info can now be propagated to main chain:
\i 6_propagate_info.sql
\set currency defs_xmo.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
\i zmr_fork.sql
-- Newly found info can now be propagated to main chain:
\i 6_propagate_info.sql