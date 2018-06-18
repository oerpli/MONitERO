\i :currency
drop table if exists :ring;
drop table if exists :txin;
drop table if exists :txout;
drop table if exists :tx;
drop table if exists :inputs;
drop table if exists :outputs;
drop materialized view if exists :txi;

-- deprecated
drop materialized view if exists :keyimg;
drop table if exists :matches;
