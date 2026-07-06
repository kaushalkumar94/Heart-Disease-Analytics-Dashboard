-- Create the database
CREATE DATABASE IF NOT EXISTS HeartDiseaseDB;

-- Use the database
USE HeartDiseaseDB;

-- Create the table
CREATE TABLE HeartPatients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Age INT NOT NULL,
    Sex ENUM('M', 'F'),
    ChestPainType VARCHAR(10),
    RestingBP INT,
    Cholesterol INT,
    FastingBS TINYINT(1) CHECK (FastingBS IN (0 , 1)),
    RestingECG VARCHAR(10),
    MaxHR INT,
    ExerciseAngina ENUM('Y', 'N'),
    Oldpeak FLOAT,
    ST_Slope VARCHAR(10),
    HeartDisease TINYINT(1) CHECK (HeartDisease IN (0 , 1))
);

-- DATA CLEANING

-- 1. CHECKING FOR MISSING OR NULL VALUES
select 
	sum(case when Age is null then 1 else 0 end) as nullAge,
    sum(case when Sex is null then 1 else 0 end) as nullSex,
    sum(case when ChestPainType is null then 1 else 0 end) as nullChestPainType,
    sum(case when RestingBP is null then 1 else 0 end) as nullRestingBP,
    sum(case when Cholesterol is null then 1 else 0 end) as nullCholesterol,
    sum(case when FastingBS is null then 1 else 0 end) as nullFastingBS,
    sum(case when RestingECG is null then 1 else 0 end) as nullRestingECG,
    sum(case when MaxHR is null then 1 else 0 end) as nullMaxHR,
    sum(case when ExerciseAngina is null then 1 else 0 end) as nullExerciseAngina,
    sum(case when Oldpeak is null then 1 else 0 end) as nullOldpeak,
    sum(case when ST_Slope is null then 1 else 0 end) as nullST_Slope,
    sum(case when HeartDisease is null then 1 else 0 end) as nullHeartDisease
from HeartPatients;

-- 2. INVALID OR OUT-OF-RANGE VALUES
select * from HeartPatients where Age between 0 and 120;

select * from HeartPatients where RestingBP > 0 or Cholesterol > 0; 
delete from HeartPatients where RestingBP <= 0 AND Cholesterol <= 0;

select * from HeartPatients where FastingBS not in (0,1) or HeartDisease not in (0,1);

-- 3. DISTINCT VALUES

select distinct sex from HeartPatients;
ALTER TABLE HeartPatients MODIFY COLUMN Sex VARCHAR(10);
update HeartPatients set Sex = 'Male' where upper(Sex) = 'M';
update HeartPatients set Sex = 'Female' where upper(Sex) = 'F';
select distinct sex from HeartPatients;

select distinct ChestPainType from HeartPatients;
select distinct RestingECG from HeartPatients;
select distinct ExerciseAngina from HeartPatients;
select distinct ST_Slope from HeartPatients;

-- 4. OUTLIERS

select Cholesterol from HeartPatients where Cholesterol > 600;
delete from HeartPatients where Cholesterol > 600;

select Oldpeak from HeartPatients where Oldpeak > 5;
alter table HeartPatients add column OldpeakOutlier varchar(10);
UPDATE HeartPatients SET OldpeakOutlier = 'Yes' WHERE Oldpeak > 4;
UPDATE HeartPatients SET OldpeakOutlier = 'No' WHERE Oldpeak <= 4;


select * from HeartPatients;


-- EDA (EXPLORATARY DATA ANALYSIS)

-- 1. TOTAL PATIENTS AND HEART DISEASE DISTRIBUTION
select HeartDisease, count(*) as TotalPatients
from HeartPatients
group by HeartDisease;

-- 2. GENDER DITRIBUTION
select Sex, HeartDisease, count(*) as TotalPatients
from HeartPatients
group by Sex, HeartDisease
order by Sex asc;

-- 3. CHEST PAIN IN HEART PATIENTS
select ChestPainType, count(*) as TotalPatients
from HeartPatients
group by ChestPainType;

select ChestPainType, HeartDisease, count(*) as TotalPatients
from HeartPatients
where HeartDisease = 1 
group by ChestPainType;

-- 4. RESTINGECG RESULTS BY HEART DISEASE
select RestingECG, HeartDisease, count(*) as TotalPatients
from HeartPatients
group by RestingECG, HeartDisease;

-- 5. FASTING BLOOD SUGAR LEVELS
SELECT 
  FastingBS,
  COUNT(*) AS Total,
  SUM(HeartDisease) AS WithHeartDisease
FROM HeartPatients
GROUP BY FastingBS;

-- 6. EXERCISE INDUCED ANGINA VS HEART DISEASE
SELECT 
  ExerciseAngina,
  COUNT(*) AS Total,
  SUM(HeartDisease) AS WithHeartDisease,
  ROUND(SUM(HeartDisease) * 100.0 / COUNT(*), 2) AS DiseaseRatePercent
FROM HeartPatients
GROUP BY ExerciseAngina;


-- RISK FACTORS

-- 7. AVERAGE CHOLESTEROL AND MAXHR WITH VS WITHOUT HEART DISEASE
select 
	round(avg(Cholesterol), 2) as Avg_Cholesterol, 
	round(avg(MaxHR), 2) as Avg_MaxHR,
    HeartDisease
from HeartPatients
group by HeartDisease;

-- 8. HIGH CHOLESTEROL PATIENTS WITH HEART DISEASE
select 
	CholesterolLevel,
	count(*) as TotalPatients,
    sum(HeartDisease) as WithHeartDisease
from (
	select *,
		case 
			when Cholesterol > 240 then "High Cholesterol"
			else "Low Cholesterol"
		end as CholesterolLevel
	from HeartPatients
) as sub
group by CholesterolLevel;


-- 9. OLDPEAK LEVELS IN PATIENTS WITH HEART DISEASE
select 
	HeartDisease,
    round(avg(OldPeak),2) as Avg_OldPeak
from HeartPatients
where HeartDisease = 1;

--  10. AGE BUCKETING
SELECT 
  AgeGroup,
  COUNT(*) AS TotalPatients,
  SUM(HeartDisease) AS WithHeartDisease
FROM (
  SELECT *,
    CASE 
      WHEN Age < 40 THEN 'Under 40'
      WHEN Age BETWEEN 40 AND 60 THEN '40–60'
      ELSE 'Above 60'
    END AS AgeGroup
  FROM HeartPatients
) AS Sub
GROUP BY AgeGroup;
