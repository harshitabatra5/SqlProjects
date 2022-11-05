select * from project.dbo.data1;
select * from project.dbo.data2;

-- no of rows in dataset
select count(*) from project..data1;
select count(*) from project..data2;

-- delete null rows
delete from project..data1 where state in ('state');
delete from project..data2 where state is null;

-- dataset for jharkhand and bihar
select * from project..data1 where state in('jharkhand','bihar');

--population of india
select sum(population) as population from project..data2;

--avg populatipn growth percentage of india from previous census grouped by state

select state, avg(Growth)* 100 as growth from project..data1 group by state order by state;

-- avg sex ratio

select state, round(avg(Sex_Ratio),0) as Sexratio from project..data1 group by State order by State;

--avg literacy state

select state, round(avg(literacy),2) as literacyrate from project..data1 
group by State  having round(avg(literacy),2)>90 order by literacyrate desc;


-- top 3 state showing highest growth ratio
select top 3 state, avg(growth) * 100 as growth from project..data1 group by state order by growth desc;

-- bottom 3 state showing lowest sex ratio
select top 3 state,round(avg(sex_ratio),2) as sr from project..data1 group by state order by sr asc;

-- top and bottom 3 states in  literacy rate 

create table #topstate(state nvarchar(255),topstates float)
insert into #topstate
select top 3 state, round(avg(Literacy),0) as lr from project..data1 group by state order by lr desc;

select * from #topstate;

create table #bottomstate(state nvarchar(255),bs float)
insert into #bottomstate
select top 3 state, round(avg(Literacy),0) as lr from project..data1 group by state order by lr asc;

select * from #bottomstate;


-- union
select * from #topstate 
union
select * from #bottomstate;

--states starting with lETTER A
select * from project..data1 where state like 'a%';

-- joining both tables
select a.district,a.state,a.growth,a.sex_ratio,a.literacy,b.Area_km2,b.population
from project..data1 as a inner join project..data2 as b on a.district=b.district and a.state=b.state;

--no. of males and females in the population

/* formula used
females/males=sex ratio....1
females + males= population -> females=population- males....2
using 2 in 1
population-males=sex ratio * males
population=males(sex ratio + 1)
males=population/(sex ratio + 1) 
females=sex ratio * (population/(sex ratio +1))
*/
 
select a.district,a.state,round(b.population/(a.sex_ratio/1000 + 1),0) as males,
round((a.sex_ratio/1000) * (population/(sex_ratio/1000 +1)),0) as females
from project..data1 as a inner join project..data2 as b on a.district=b.district order by a.district desc;

-- total number of males and females in each state
select c.state,sum(c.males) as males,sum(c.females) as females from 
(select a.district,a.state,round(b.population/(a.sex_ratio/1000 + 1),0) as males,
round((a.sex_ratio/1000) * (population/(sex_ratio/1000 +1)),0) as females
from project..data1 as a inner join project..data2 as b on a.district=b.district) as c group by c.state;

-- total literacy rate of each state

/* formula used 
total literate people /population = literacy ratio
total literate people =literacy ratio * population
total illiterate people = (1-literacy ratio)* population
*/

select d.state,sum(d.total_literate_people) l,sum(d.total_illiterate_people) i from 
(select c.district ,c.state,round((c.Literacy_ratio)*(c.population),0) as total_literate_people,
round((1-c.Literacy_ratio)*c.population ,0) as total_illiterate_people from 
(select a.district,a.state,a.literacy/100 as Literacy_ratio,b.population from project..data1 a 
inner join project..data2 b on a.district=b.district) c ) d group by d.state;

--population in previous sensus
/* formula used
previous sensus +  growth * previous sensus= population 
previous sensus(1+growth)=population
previous sensus =population/(1+ growth)
*/

select c.district,c.state,round(c.p/(c.g +1 ),0) previous_census_population,c.p recent_population from(
select a.district,a.state,a.growth g,b.population p from project..data1 a inner join project..data2 b
on a.district=b.district) c ;

-- population vs area
-- select '1' as ,kp.* from(


select (finally.totalarea/finally.previous_census) as pcp_vs_area,(finally.totalarea/finally.new_census) as ncp_vs_area from 
(
select final.* from 
(
select c.*, d.totalarea  from 
(select '1' as link, sum(round(b.population/(a.growth +1 ),0)) previous_census,sum(b.population) new_census from project..data1 a
inner join  project..data2 b on a.district=b.district) as c
inner join 
(select '1' as link,sum(area_km2)as  totalarea from project..data2) as d 
on c.link=d.link 
) as final
) as finally;

-- top 3 district in every state having highest literacy rate using windows function
select a.* from (
select district,state,literacy, RANK() over( partition by state order by literacy desc) as ranking from project..data1)
as a where a.ranking in(1,2,3);




