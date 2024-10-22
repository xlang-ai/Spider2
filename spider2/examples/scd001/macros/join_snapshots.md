{% docs join_snapshots %}

Joins 2 snapshot or history tables together. 


The joining logic finds where the ids match and where the **timestamps overlap between the two tables**. We use the greatest valid_from and the least valid_to between the two tables to ensure that the new, narrowed timespan for the row is when the rows from both tables are valid. 

## Notes

- Requires any extra columns from table_join_on to be listed prior to using this macro.

```jinja
select
    table_join_on.column_name1,
    table_join_on.column_name2,
    \{\{ join_snapshots(...
```

- It also assumes you’ve replaced your valid_to = NULL with an actual date type with an actual date that indicates a row is currently valid.

Returns:
- **valid_to** the lest valid to date for the combined grain table
- **valid_from** the greatest valid from date for the combined grain table

{% enddocs %}