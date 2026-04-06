/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '/home/ayush/Downloads/SQL/csv_files/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '/home/ayush/Downloads/SQL/csv_files/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '/home/ayush/Downloads/SQL/csv_files/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '/home/ayush/Downloads/SQL/csv_files/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM '/home/ayush/Downloads/SQL/csv_files/company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM '/home/ayush/Downloads/SQL/csv_files/skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM '/home/ayush/Downloads/SQL/csv_files/job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM '/home/ayush/Downloads/SQL/csv_files/skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


SELECT 

    job_title_short as title,
    job_location as location,
    job_posted_date at time zone 'utc' AT TIME ZONE 'est' as date,
    extract(month from job_posted_date) as joining_month
    from job_postings_fact
    limit 5;
  


select 
    count(job_id) as job_posted_count,
    extract(month from 
        job_posted_date) as month
from 
    job_postings_fact
where 
    job_title_short='Data Analyst'
group by
     month
order by 
    job_posted_count desc




select 
job_schedule_type,
    avg(salary_year_avg) as year_sal,
     avg(salary_hour_avg) as hour_sal
from 
    job_postings_fact
where
    job_posted_date>'2023-06-01'
group by
    job_schedule_type;




select 
    count(job_id),
    extract(month from job_posted_date  at time zone 'utc' at time zone 'America/New_York') as month
from job_postings_fact
group by month
order by month ;





create table january_jobs as
    select  * 
    from job_postings_fact
    where extract(month from job_posted_date) = 1;


create table february_jobs as
    select *
    from job_postings_fact
    where extract(month from job_posted_date)=2;


create table march_jobs as
    select *
    from job_postings_fact
    where extract(month from job_posted_date)=3;


select job_posted_date 
from march_jobs
limit 10;



select 
    count(job_id) as no_of_jobs,
    CASE
        WHEN job_location='Anywhere' THEN 'remote'
        WHEN job_location='New York,NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
from job_postings_fact
where 
    job_title_short='Data Analyst'
group by location_category;


select * 
from (
    SELECT * from 
    job_postings_fact
    where extract(MONTH from job_posted_date) = 1
) as january_jobs;

with january_jobs as (
    select * from job_postings_fact
    where extract(month from job_posted_date)=1
) 
select * from january_jobs;




select name as company_name  
from company_dim
where company_id in(
    select company_id
    from 
        job_postings_fact
    where 
        job_no_degree_mention = true
)
with company_job_count as(
select 
    company_id,
    count(*) as total_jobs
from 
    job_postings_fact
group by company_id
)

select company_dim.name as company_name ,
company_job_count.total_jobs
from company_dim
left join company_job_count
on company_job_count.company_id = company_dim.company_id

order by total_jobs desc



select * 
from skills_dim; 

select * from job_postings_fact
limit 5;

select 
    s.skills,
    count(sjd.skill_id) as skill_count
from skills_job_dim sjd
join skills_dim s
on sjd.skill_id = s.skill_id
group by s.skills
order by skill_count desc
limit 5;




select 
    company_id,
    job_count,
    case 
        when job_count<10 then 'small'
        when job_count between 10 and 50  then 'Medium'
        else 'Large '
        end as size_category
from(
          select 
            company_id,
            count(*) as job_count
        from job_postings_fact
        group by company_id
)sub;

with remote_job_skills as(
select 

    skill_id,
    count(*) as skill_count
from 
    skills_job_dim as skills_to_job
inner join job_postings_fact as job_postings on job_postings.job_id = skills_to_job.job_id  

where 
    job_postings.job_work_from_home=true and job_postings.job_title_short= 'Data Analyst'
group by 
    skill_id)



select 
    skills.skill_id,
        skills as skill_name,
        skill_count
from remote_job_skills
inner join skills_dim as skills on skills.skill_id = remote_job_skills.skill_id

order by 
     skill_count desc
limit 5;



select 
    job_title_short,
    company_id,
    job_location
from january_jobs


UNION 

select 
    job_title_short,
    company_id,
    job_location
from february_jobs


select 
    job_title_short,
    skills,
    type
from january_jobs
left join skills_job_dim on january_jobs.job_id=skills_job_dim.job_id
join skills_dim on skills_job_dim.skill_id=skills_dim.skill_id 
where january_jobs.salary_year_avg>70000
    
select 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::date
from(
    select *
    from january_jobs
    union all
    select *
    from february_jobs
    union all
    select *
    from march_jobs
) as quarter1_job_postings

where 
    quarter1_job_postings.salary_year_avg>70000