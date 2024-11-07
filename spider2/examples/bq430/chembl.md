### Data Sources:
Part tables of ChEMBL database:
- activity data: patents-public-data.ebi_chembl.activities_29
- compound structures: patents-public-data.ebi_chembl.compound_structures_29 
- compound properties: patents-public-data.ebi_chembl.compound_properties_29 
- publication documents: patents-public-data.ebi_chembl.docs_29 

### UUID Generation:
Activity Pair UUID (mmp_delta_uuid):
Generated using the MD5 hash of the JSON string of the pair's activity IDs:
to_hex(md5(to_json_string(struct(A, B))))
Both A and B can be activity id or canonical_smiles

### Standard Change Classification:
Determines whether the standard value between two molecules has increased, decreased, or stayed the same:
'decrease': If standard_value_1 >(>>) standard_value_2 and measurement relations do not conflict.
'increase': If standard_value_1 <(<<) standard_value_2 and measurement relations do not conflict.
'no-change': If standard_value_1 =(~) standard_value_2 and both standard relations indicate equality.
