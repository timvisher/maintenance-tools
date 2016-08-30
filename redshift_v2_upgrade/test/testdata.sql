create schema if not exists "_rjm";
create schema if not exists "v2_migration_test_segment";

create table _rjm."v2_migration_test_segment:page#b13ab3dd10fb6294c5b6a36e4b1cc75d:0" (
    _rjm_batched_at bigint
  , _rjm_received_at bigint
	, _rjm_sequence bigint
	, _rjm_level_0_id bigint
	, _rjm_replication_id varchar(32)
	, "anonymous_id#42e766cd9b362bad47647878ae9d8724" varchar(255)
	, "message_id#9e571e68676cc73d2fcc1033f9e5e27e" varchar(255)
	, "received_at#a592066ba6960add3692d6085358b0de" varchar(255)
  , "user_id#80571dc63ae42683d3015b123fb06967" bigint
  , "user_id#1d16a4bd0ac1ef94fd3c6da3faec4af5" numeric(38,6)
  , "user_id#750c32c0967d6ac296593c82233ad583" varchar(255)
);


create view v2_migration_test_segment.page
as
select *
from _rjm."v2_migration_test_segment:page#b13ab3dd10fb6294c5b6a36e4b1cc75d:0";


insert into _rjm."v2_migration_test_segment:page#b13ab3dd10fb6294c5b6a36e4b1cc75d:0"
values
(1472491791000, 1472491790000, 1472491780000, 0, 'e6f00f9009b5dc7357b277e9015e9c4d', 'mail1@domain.com', 'ab3675913add6fc5046625f9ae7b51ad', '2016-08-29T13:32:00Z', 101, null, null),
(1472491891000, 1472491890000, 1472491880000, 0, '991040a5532a743f1d14f1d6e6dfa0df', 'mail2@domain.com', '595c9737df7a6de0269e95df287d80cd', '2016-08-29T13:33:00Z', 102, null, null),
(1472491991000, 1472491990000, 1472491980000, 0, '97623bfb297d76a3819ad459aae472bb', 'mail3@domain.com', '5d161508f36b171be1c6b97a88db3929', '2016-08-29T13:33:00Z', 103, null, null),
(1472574880000, 1472574890000, 1472574891000, 0, '51fa30a09c7f5ccae2743eb866867da8', 'mail4@domain.com', '503475090be5d617bf0d06544e4c539f', '2016-08-30T12:33:00Z', null, null, '104'),
(1472574920000, 1472574930000, 1472574894000, 0, '48f80c6060ad5fb2fbf402116d088416', 'mail5@domain.com', '7d93ca300427df25bc4960aab8acf580', '2016-08-30T12:43:00Z', null, 105.1, null);
