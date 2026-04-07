with skills_demand as(
    SELECT 
    skills_dim.skill_id,
        skills_dim.skills,
        count(skills_job_dim.job_id) as demand_count
    from job_postings_fact
    INNER JOIN skills_job_dim on job_postings_fact.job_id  = skills_job_dim.job_id
    INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short='Data Analyst'
        AND salary_year_avg is not null
        AND job_work_from_home = true 
    GROUP BY
        skills_dim.skill_id


), average_salary as (
    SELECT 
       skills_job_dim.skill_id,
    round(avg(salary_year_avg),0) as avg_salary
    from job_postings_fact
    INNER JOIN skills_job_dim on job_postings_fact.job_id  = skills_job_dim.job_id
    INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short='Data Analyst'
        and salary_year_avg is not NULL
    GROUP BY
       skills_job_dim.skill_id
)

select 
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
from
    skills_demand
inner join average_salary on skills_demand.skill_id = average_salary.skill_id
WHERE 
    demand_count>10
ORDER BY 
    demand_count desc,
    avg_salary desc
limit 25