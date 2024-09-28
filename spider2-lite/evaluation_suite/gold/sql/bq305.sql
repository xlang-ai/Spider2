select
       sum(ifnull(p.view_count,0)) as reached
     , rp.owner_user_id
from `bigquery-public-data.stackoverflow.posts_questions` p
inner join (
    
    (Select id, owner_user_id 
    From `bigquery-public-data.stackoverflow.posts_questions` 
    Where post_type_id = 1 
    and owner_user_id is not null)
  
    Union DISTINCT
    
    (Select parent_id, owner_user_id 
     From `bigquery-public-data.stackoverflow.posts_answers`
     Where post_type_id = 2
     And id in (select accepted_answer_id from `bigquery-public-data.stackoverflow.posts_questions`)
     and owner_user_id is not null)
    
    Union DISTINCT
    
    (Select parent_id, owner_user_id
    From `bigquery-public-data.stackoverflow.posts_answers`
   Where post_type_id = 2
     And score > 5
     and owner_user_id is not null)
     
    Union DISTINCT
    
    (Select a.parent_id, a.owner_user_id
    From `bigquery-public-data.stackoverflow.posts_answers` a
         Join `bigquery-public-data.stackoverflow.posts_questions` q On a.parent_id = q.id
   Where a.post_type_id = 2
     And a.score > 0.20 * (select sum(score) from `bigquery-public-data.stackoverflow.posts_answers` where parent_id=q.id)
     And a.score > 0
     and a.owner_user_id is not null)
     
    Union DISTINCT
    
    (Select x.parent_id, x.owner_user_id 
    From (Select a.parent_id , a.owner_user_id, Rank() Over(Partition By a.parent_id, a.owner_user_id Order By ta.score Desc) AnswerRank
            From `bigquery-public-data.stackoverflow.posts_answers` a
                 Join `bigquery-public-data.stackoverflow.posts_answers` ta On ta.parent_id = a.parent_id
           Where a.post_type_id = 2
             And a.score > 0
             and a.owner_user_id is not null
          ) x
          Where AnswerRank <= 3)
    
   )
rp on rp.id = p.id
group by rp.owner_user_id
order by sum(ifnull(p.view_count,0)) desc
LIMIT 10
