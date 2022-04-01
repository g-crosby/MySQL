CREATE DATABASE Youtube;
USE Youtube;
CREATE TABLE Creators (
    video_id VARCHAR(255),
    channelTitle VARCHAR(255),
    viewCount INT,
    likeCount INT,
    commentCount INT,
    duration VARCHAR(255),
    datePublished date,
    dayofMonth INT,
    durationSeconds INT,
    tagCount INT
);

-- All data was scraped via Python using the Youtube API, along with most of the preprocessing -- 

-- Taks CSV data and bulk add to the new Creators Table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/youtube.csv'
INTO TABLE Creators
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shashank1.csv'
INTO TABLE Creators
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Video Views by Upload Day--
select channelTitle, sum(viewCount) as Total_Views,  dayname(datePublished) as Weekday
from creators
group by 3,1
order by 2 desc;

-- Popular Upload Days --
select channelTitle, count(video_id) as Uploads, dayname(datePublished) as Weekday
from creators
group by 3,1
order by 2 desc;

-- Popular Upload Month --
select channelTitle, count(video_id) as Uploads, monthname(datePublished) as Month
from creators
group by 3,1 
order by 2 desc;

-- Views by Month -- 
select channelTitle, sum(viewCount) as Views, monthname(datePublished) as Month
from creators
group by 3,1
order by 2 desc;

-- Views by Time of Month -- 
select channelTitle, sum(viewCount) as Views, dayofMonth as Day_of_Month
from creators
group by 3,1
order by 2 desc;

-- Average Likes per video --
select channelTitle, round((sum(likeCount) / count(video_id)), 2) as Average_Likes, count(video_id) as NumberofVideos
from creators
group by 1; 

-- Average Video Duration -- 
select channelTitle, avg(durationSeconds) as AverageVideoLength
from creators
group by 1;

-- Views Per Video --
select channelTitle, round((sum(viewCount) / count(video_id))) as AverageViews
from creators
group by 1;

-- Average Comments -- 
select channelTitle, round((sum(commentCount) / count(video_id))) as AverageComments
from creators
group by 1;

-- Putting these all together into one query -- 
select 
channelTitle, 
count(video_id) as Number_of_Videos, 
round((sum(likeCount) / count(video_id)), 2) as Average_Likes, 
round(avg(durationSeconds)) as Average_Video_Length_Seconds,
round((sum(viewCount) / count(video_id))) as Average_Views,
round((sum(commentCount) / count(video_id))) as Average_Comments,
(select dayname(datePublished) from creators
group by 1,channelTitle
order by count(video_id) desc
limit 1) as Favorite_Upload_Day
from creators
group by 1;

-- Parse out Month from datePublished --
select
substring_index(substring_index(datePublished, '-',2), '-', -1) as month
from creators;

-- Add Month Column and set it -- 
ALTER TABLE Creators
ADD Month INT;

UPDATE Creators
SET Month = substring_index(substring_index(datePublished, '-',2), '-', -1);

ALTER TABLE Creators MODIFY COLUMN Month INT AFTER datePublished;

select * from creators;