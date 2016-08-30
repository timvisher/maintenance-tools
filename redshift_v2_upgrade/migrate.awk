function convert_type(raw) {
	if (raw == "character") {
		return "string";
	}
	else if (raw ~ /numeric/) {
		return "decimal";
	} else {
		return raw;
	}
}
NR > 1 { printf(", ") }
BEGIN { printf "'%s' as _sdc_table_version, ", table_version; }
$2 == table {
	if($5 == "_rjm_batched_at") {
		f = "(TIMESTAMP 'epoch' + _rjm_batched_at / 1000 * INTERVAL '1 Second') as _sdc_batched_at";
	}
	else if($5 == "_rjm_received_at") {
		f = "(TIMESTAMP 'epoch' + _rjm_received_at / 1000 * INTERVAL '1 Second') as _sdc_received_at";
	}
	else if($5 == "_rjm_sequence") {
		f = "_rjm_sequence as _sdc_sequence"
	}
	else if($5 == "_rjm_replication_id") {
		f = "_rjm_replication_id as _sdc_replication_id"
	}
	else if($5 == "_rjm_source_key_message_id") {
		f = "_rjm_source_key_message_id as _sdc_source_key_message_id"
	}
	else if($5 ~ /_rjm_level_[0-9]+_id/) {
		converted = $5;
		sub(/^_rjm_/, "_sdc_", converted);
		f = $5 " as " converted;
	}
	else {
		split($5, parts, "#");
		short = parts[1]
		if (!(short in done)) {
			f = "\"" $5 "\"" " as " "\"" short "\"";
		} else {
			f = "\"" $5 "\"" " as " "\"" short "_" convert_type($6) "\"";
		}
		done[short] = true;
	}
	printf "%s", f
}
