{% docs __overview__ %}

<div style="position: center; background: #FEFAE8; border: 3px solid #F29D41; margin: 10px; padding: 10px; text-align: center">
    <h2 style="color: #F29D41"> dbt_ Intro</h2>
    <p style="font-size: 16px; font-style: italic;">Want to learn more about dbt?<br>
    Check out [the presentation I gave for Data Council KL #6](https://dc-dbt.1bk.dev)!</p> &#128515;
</div>

# Simple Airports Analysis - Malaysia 

### Github Repository
- [Simple Airports Analysis]

### Structure
```
M  D  ./models
      ├── base
T [x] │   ├── base_airports
T [x] │   └── base_arrivals__malaysia
      ├── core
T [x] │   ├── fct_airports__malaysia_distances_km
T [x] │   └── fct_arrivals__malaysia_summary
      └── staging
V [ ]     └── stg_airports__malaysia_distances
```
#### Descriptions
Documentation (`D`):
- `[x]` = Documented
- `[ ]` = Not Documented

Materialization (`M`):
- `T` = Table
- `E` = Ephemeral
- `V` = View (non-binding)


### More information

#### dbt_
- [What is dbt]?
- [Installation]?

[Simple Airports Analysis]:<https://github.com/1bk/simple-airports-analysis/>
[What is dbt]:<https://docs.getdbt.com/docs/overview>
[Installation]:<https://docs.getdbt.com/docs/installation>

{% enddocs %}