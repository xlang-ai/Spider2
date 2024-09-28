WITH BlackRace AS (
    SELECT CAST(Code AS INT64)
    FROM `spider2-public-data.death.Race` 
    WHERE LOWER(Description) LIKE '%black%'
)
select 
    v.Age, v.Total as Vehicle_Total, v.Black as Vehicle_Black,
    g.Total as Gun_Total, g.Black as Gun_Black
from (
  select 
      Age, count(*) as Total, COUNTIF(Race IN (SELECT * FROM BlackRace)) as Black
  from `spider2-public-data.death.DeathRecords` d,
     (
     select 
       distinct e.DeathRecordId as id 
       from 
         `spider2-public-data.death.EntityAxisConditions` e,
         (
            select * 
            from `spider2-public-data.death.Icd10Code` where LOWER(Description) like '%vehicle%'
         ) as c 
        where e.Icd10Code = c.code
     ) as f
    where d.id = f.id and Age between 12 and 18
    group by Age
) as v, -- Vehicle

(
  select 
      Age, count(*) as Total, COUNTIF(Race IN (SELECT * FROM BlackRace)) as Black
  from `spider2-public-data.death.DeathRecords` d,
      (select 
           distinct e.DeathRecordId as id 
           from 
              `spider2-public-data.death.EntityAxisConditions` e,
              (
                -- Every Firearm discharge, except Legal intervention
                select 
                   Code, Description 
                   from `spider2-public-data.death.Icd10Code`
                   where Description like '%firearm%' 
              ) as c 
          where e.Icd10Code = c.code
      ) as f
  where d.id = f.id and Age between 12 and 18
  group by Age
) as g
where g.Age = v.Age;