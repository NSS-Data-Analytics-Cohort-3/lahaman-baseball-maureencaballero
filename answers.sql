/* 1. 1871-2016

SELECT Min(yearid), MAX(yearid)
FROM appearances

2. Find the name and height of the shortest player in the database. Eddie Gaedel
How many games did he play in? 1
What is the name of the team for which he played? St Louis Browns, 1 game pinch hitter

SELECT namefirst, namelast, height, a.G_all, t.name,
	G_batting      ,
G_defense      ,
G_p           ,
G_c           ,
G_1b          ,
G_2b           ,
G_3b           ,
G_ss           ,
G_lf   ,
G_cf        ,
G_rf       ,
G_of        ,
G_dh          ,
G_ph        ,
G_pr       
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
JOIN teams AS t
ON a.teamid=t.teamid AND a.yearid =t.yearid
WHERE height IN
	(SELECT MIN(height) 
	 FROM people) */
	 


	 
	 
/* 3. Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the 
total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors? David Price $81.85M 


HAVING ISSUES WITH DATA DUPLICATING, TRIPLING -- 
think it is summing salaries for each year played in college. 
Let's test by checking for just one player's actual salary sum:

TO FIGURE OUT DAVID PRICE's TOTAL AND AVERAGE: TOTAL $81M, AVG $5.8M
SELECT CONCAT(p.namefirst, ' ',p.namelast) AS player_name,
		s.yearid, 
		s.salary
FROM collegeplaying AS cp
JOIN people AS p
ON cp.playerid=p.playerid
JOIN salaries AS s
ON p.playerid=s.playerid
WHERE p.namefirst LIKE 'David' AND p.namelast LIKE 'Price'
GROUP BY player_name, s.yearid, s.salary
ORDER BY s.yearid

NOW, if I try to SUM this, let's see what happens (OK as long as I 
get rid of JOIN to collegeplaying table.)
SELECT CONCAT(p.namefirst, ' ',p.namelast) AS player_name,
		s.yearid, 
		SUM(s.salary)
FROM people AS p
JOIN salaries AS s
ON p.playerid=s.playerid 
WHERE p.namefirst LIKE 'David' AND p.namelast LIKE 'Price'
GROUP BY s.yearid, player_name
ORDER BY s.yearid

FINAL ANSWER: 

WITH college_players AS
	(SELECT DISTINCT cp.playerid
		 FROM collegeplaying AS cp
		 WHERE cp.schoolid ILIKE '%Vand%')
SELECT  CONCAT(p.namefirst, ' ',p.namelast) AS player_name,
		SUM(s.salary) AS total_salary_earned
FROM people AS p
JOIN college_players 
ON p.playerid=college_players.playerid
JOIN salaries AS s
ON p.playerid=s.playerid 
GROUP BY player_name
ORDER BY total_salary_earned DESC */

/* Actually 24 players listed from Vandy, but only 15 players show salary figures 
from salaries table. Checked one of them and not in table. Therefore,
if they don't show up in salaries, they never made it to majors.

SELECT  DISTINCT p.namefirst, p.namelast, p.playerid
FROM collegeplaying AS cp
JOIN people AS p
ON cp.playerid=p.playerid
WHERE schoolid ILIKE 'Vand%'

SELECT playerid, salary
FROM salaries
WHERE playerid LIKE 'richaan01'*/

/* 4. Using the fielding table, group players into three groups 
based on their position: label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.

position	put_out_sum
Infield	58934
Battery	41424
Outfield	29560  

SELECT 
CASE WHEN f.pos = 'OF' THEN 'Outfield'
	 WHEN f.pos IN('SS','1B','2B','3B') THEN 'Infield'
	 ELSE 'Battery' END AS position,
	 SUM(f.po) AS put_out_sum
FROM fielding AS f
WHERE yearid =2016
GROUP BY position
ORDER BY put_out_sum DESC */



/* 5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places.
Do the same for home runs per game. Do you see any trends?

decade	so_per_game	hr_per_game
1920s	2.32	0.01
1930s	2.83	0.05
1940s	3.05	0.03
1950s	3.84	0.27
1960s	5.19	0.22
1970s	4.67	0.11
1980s	4.88	0.16
1990s	5.65	0.41
2000s	6.07	0.62
2010s	7.03	0.44


SELECT CONCAT(LEFT(CAST(t.yearid AS varchar),3),'0s') AS decade,
	ROUND(AVG(t.so/t.g), 2)AS so_per_game,
	ROUND (AVG(t.hr/t.g),2) AS hr_per_game
FROM teams AS t
WHERE LEFT(CAST(t.yearid AS varchar),3)>'191'
GROUP BY decade
ORDER BY decade */

/* Another way to get decades:   (10*DATE_PART('decade', TO_DATE(h.yearid::text, 'YYYY'))) as decade */



/* 6.Find the player who had the most success stealing bases in 2016,
where success is measured as the percentage of stolen base attempts which are successful.
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.

SELECT b.playerid, p.namefirst, p.namelast, b.teamid,
	(b.sb*100/SUM(b.sb+b.cs)) AS stolen_base_percentage
FROM batting AS b
JOIN people AS p
ON b.playerid=p.playerid
WHERE yearid=2016
GROUP BY b.playerid, p.namefirst, p.namelast, b.sb, b.teamid, b.cs
HAVING (sb+cs)>=20
ORDER BY stolen_base_percentage DESC  */

/* 7.From 1970 – 2016, what is the largest number of wins for a team that 
did not win the world series? SEATTLE 116  Can't get year to print .

SELECT teamid,  MAX(w) AS max_wins
FROM teams AS t
WHERE (yearid BETWEEN 1970 AND 2016) 
	AND wswin ILIKE 'n'
GROUP BY teamid
ORDER BY max_wins DESC


What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a 
world series champion – determine why this is the case.  LA Dodgers 1981 63 wins

SELECT teamid, name, yearid, MIN(w) AS min_wins
FROM teams AS t
WHERE (yearid BETWEEN 1970 AND 2016) 
	AND wswin ILIKE 'y'
GROUP BY teamid, name,yearid
ORDER BY min_wins 

SELECT yearid, ROUND(AVG(g),0) AS avg_games_played
FROM teams as t
WHERE (yearid BETWEEN 1970 AND 2016)
GROUP BY yearid
ORDER BY avg_games_played 
----> Typical season is 162 games; 1981 only had average of 107 games played 
because of the six-week player's strike. 1994 also had an unusually small number
of games played, with an average of 114, also because of a strike. The only 
other outliers were 1995 with 144 games, and 1972 with 155 games.


FOR FUN, figure out the percentage of games won by world series winner.

Then redo your query, excluding the problem year. St Louis Cardinals 
in 2006 with 83 wins. Next minimum number of wins was 85, 87, 88; 
so 83 is not an unusually small number. 
BUT, 1994 doesn't show up in the data output. Why? 
World Series was cancelled due to strike.

SELECT teamid, name, yearid, wswin, MIN(w) AS min_wins
FROM teams AS t
WHERE (wswin ILIKE 'y')
	AND ((yearid BETWEEN 1970 AND 1980) 
	OR (yearid BETWEEN 1982 AND 2016)) 
GROUP BY teamid, name,yearid, wswin
ORDER BY min_wins 


How often from 1970 – 2016 was it the case that a team with the most 
wins also won the world series? 12


SELECT count(*)
FROM teams AS t
JOIN (SELECT t.yearid, 
	  MAX(w) AS max_wins
		 FROM teams AS t
	 GROUP BY yearid) AS subquery
ON t.yearid=subquery.yearid
WHERE (wswin ILIKE 'y')
	AND w=max_wins
	AND (t.yearid BETWEEN 1970 AND 2016) 

What percentage of the time? 26%

SELECT count(*), ROUND(count(*)::numeric/46,2) AS percent_won
FROM teams AS t
JOIN (SELECT t.yearid, 
	  MAX(w) AS max_wins
		 FROM teams AS t
	 GROUP BY yearid) AS subquery
ON t.yearid=subquery.yearid
WHERE (wswin ILIKE 'y')
	AND w=max_wins
	AND (t.yearid BETWEEN 1970 AND 2016)*/



/* 8.Using the attendance figures from the homegames table, 
find the teams and parks which had the top 5 average attendance per 
game in 2016 (where average attendance is defined as total attendance 
divided by number of games). Only consider parks where there were at 
least 10 games played. 
Report the park name, team name, and average attendance. 
name	park_name	avg_attendance
Los Angeles Dodgers	Dodger Stadium	45719
St. Louis Cardinals	Busch Stadium III	42524
Toronto Blue Jays	Rogers Centre	41877
San Francisco Giants	AT&T Park	41546
Chicago Cubs	Wrigley Field	39906

SELECT t.name, p.park_name, 
		ROUND(AVG(h.attendance/h.games),0)AS avg_attendance
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
JOIN teams AS t
ON h.team = t.teamid AND h.year=t.yearid
WHERE h.year = 2016
	AND g>=10
GROUP BY t.name, p.park_name, h.year
ORDER BY avg_attendance DESC
LIMIT 10


Repeat for the lowest 5 average attendance.
name	park_name	avg_attendance
Tampa Bay Rays	Tropicana Field	15878
Oakland Athletics	Oakland-Alameda County Coliseum	18784
Cleveland Indians	Progressive Field	19650
Miami Marlins	Marlins Park	21405
Chicago White Sox	U.S. Cellular Field	21559

SELECT t.name, p.park_name,
		ROUND(AVG(h.attendance/h.games),0)AS avg_attendance
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
JOIN teams AS t
ON h.team = t.teamid AND h.year=t.yearid
WHERE h.year = 2016
	AND h.games >=10
GROUP BY t.name, p.park_name, h.year
ORDER BY avg_attendance 
LIMIT 10

*/

/* 9. Which managers have won the TSN Manager of the Year award 
in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.
*//* Tried using a CTE first, but got zero results. Then tried as subquery, no luck. 




SELECT CONCAT(namefirst,' ', namelast) AS mgr_name,
	 a.yearid, t.franchname
FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid = p.playerid 
INNER JOIN managers AS m
ON a.playerid = m.playerid AND a.yearid=m.yearid
INNER JOIN teamsfranchises AS t
ON m.teamid = t.franchid

WHERE a.playerid IN 
	(SELECT a.playerid
	FROM awardsmanagers AS a
	WHERE awardid LIKE '%TSN%' 
	AND a.lgid LIKE 'NL'
	INTERSECT
	SELECT a.playerid
	FROM awardsmanagers AS a
	WHERE awardid LIKE '%TSN%'
	AND a.lgid LIKE 'AL')
GROUP BY mgr_name,  a.yearid, t.franchname
ORDER BY mgr_name */
	
	
/* 10. Analyze all the colleges in the state of Tennessee. 
Which college has had the most success in the major leagues. 
Use whatever metric for success you like - number of players, 
number of games, salaries, world series wins, etc.

a.BY Number of Players in Majors


SELECT s.schoolname, COUNT (c.playerid)
FROM collegeplaying AS C
JOIN schools AS s
ON s.schoolid = c.schoolid
WHERE schoolstate LIKE 'TN'
GROUP BY s.schoolname
ORDER BY count DESC

schoolname	count
University of Tennessee	92
Vanderbilt University	65
University of Memphis	35
Tennessee State University	24
Middle Tennessee State University	24
Austin Peay State University	23
Carson-Newman College	15
Maryville College	14
East Tennessee State University	12
Rhodes College	12



b. Trying to determine actual number of players who made it to majors... 
but I am getting triple the number of the first query. 
Then when added = on year, get no results.

WITH college_players AS
 	(SELECT DISTINCT c.playerid, s.schoolname, c.schoolid
	FROM collegeplaying AS C
	JOIN schools AS s
	ON s.schoolid = c.schoolid
WHERE schoolstate LIKE 'TN'
GROUP BY s.schoolname, c.schoolid,c.playerid)

SELECT s.schoolname, COUNT(DISTINCT (sal.playerid)) AS count
	FROM schools AS s
	JOIN college_players
	ON s.schoolid=college_players.schoolid
	JOIN salaries AS sal
	ON college_players.playerid = sal.playerid
GROUP BY s.schoolname
ORDER by count DESC

--->WHO MADE IT TO THE MAJORS:
University of Tennessee	22
Vanderbilt University	15
University of Memphis	8
Middle Tennessee State University	6
Austin Peay State University	5
Cleveland State Community College	3
Tennessee State University	2
Chattanooga State Technical Community College	2
Lincoln Memorial University	2
Southwest Tennessee Community College	1
Tennessee Technological University	1
Tennessee Wesleyan College	1
Union University	1
Columbia State Community College	1
Carson-Newman College	1
East Tennessee State University	1
Lambuth University	1
Lipscomb University	1
Motlow State Community College	1

-- NOW lets see what the average salary was of the players who made it to the majors:

WITH college_players AS
 	(SELECT DISTINCT c.playerid, s.schoolname, c.schoolid
	FROM collegeplaying AS C
	JOIN schools AS s
	ON s.schoolid = c.schoolid
WHERE schoolstate LIKE 'TN'
GROUP BY s.schoolname, c.schoolid,c.playerid)

SELECT s.schoolname,
		ROUND(AVG(sal.salary::numeric),0) AS avg_sal_in_majors
FROM schools AS s
LEFT JOIN college_players AS c
ON s.schoolid = c.schoolid
JOIN salaries AS sal
ON c.playerid =sal.playerid 
GROUP BY s.schoolname
ORDER BY avg_sal_in_majors DESC 

---> 
AVG SALARY BY COLLEGE IN TN:
Carson-Newman College	3087000
University of Tennessee	2440545
Lincoln Memorial University	2433889
University of Memphis	2169863
Vanderbilt University	2056685
Austin Peay State University	1662970
Tennessee Wesleyan College	1392778
Motlow State Community College	1392139
Lambuth University	1008750
Lipscomb University	718250
Cleveland State Community College	543585
East Tennessee State University	543333
Southwest Tennessee Community College	520833
Tennessee Technological University	492200
Middle Tennessee State University	405367
Columbia State Community College	387143
Tennessee State University	152000
Chattanooga State Technical Community College	126333
Union University	112750


awards: 

WITH college_players AS
 	(SELECT DISTINCT c.playerid, s.schoolname, c.schoolid
	FROM collegeplaying AS C
	JOIN schools AS s
	ON s.schoolid = c.schoolid
WHERE schoolstate LIKE 'TN'
GROUP BY s.schoolname, c.schoolid,c.playerid)

SELECT a.playerid, college_players.schoolname, a.yearid, a.awardid
FROM college_players
JOIN awardsplayers AS a
ON college_players.playerid = a.playerid
ORDER BY college_players.schoolname



*/

/* 11. Is there any correlation between number of wins and team salary? 
Use data from 2000 and later to answer this question. 
As you do this analysis, keep in mind that salaries across the whole
league tend to increase together, so you may want to look on a 
year-by-year basis.

WITH team_wins AS
	(SELECT yearid, name, teamid, SUM(w)::numeric AS total_wins
	  FROM teams AS t
	GROUP BY yearid,name,teamid),
team_salary AS
	(SELECT s.yearid, t.teamid,t.name, SUM(salary)::numeric AS total_salary
	FROM salaries AS s
	JOIN teams AS t
	ON s.teamid = t.teamid AND s.yearid=t.yearid
	GROUP BY s.yearid, t.teamid, t.name)
SELECT DISTINCT t.yearid, 
		ROUND(CORR(team_wins.total_wins, team_salary.total_salary) OVER(Partition by t.yearid)::numeric,2)
FROM teams AS t
JOIN team_wins
ON t.teamid = team_wins.teamid AND t.yearid=team_wins.yearid
JOIN team_salary
ON t.teamid= team_salary.teamid AND t.yearid=team_salary.yearid
WHERE t.yearid >= 2000 
GROUP BY t.yearid, t.name, total_wins, total_salary
*/




/* 12.In this question, you will explore the connection between 
number of wins and attendance.

a. Does there appear to be any correlation between attendance at home games 
and number of wins? Kept getting null.

WITH avg_attendance AS
	(SELECT yearid, name,
			ROUND(AVG(attendance),0)::integer AS avg_yearly_attend
	 FROM teams
	 GROUP BY yearid, name) ,
	 
yearly_wins AS
	(SELECT yearid, SUM(w)AS total_wins_per_year
	FROM teams
	GROUP BY yearid)
	
SELECT DISTINCT t.yearid, CORR(avg_yearly_attend, w) OVER(PARTITION by t.yearid)
FROM teams AS t
JOIN avg_attendance
ON t.yearid = avg_attendance.yearid
GROUP BY t.yearid, t.name, t.w, avg_yearly_attend



b. Do teams that win the world series see a boost in attendance 
the following year?    From 1980-2016, boost 16 times, decline 19 times, 46%;
From 1960 -2016, boosted 49% of time. 
From 1900-2016, boosted 46% of time. 

WITH boosted AS
(SELECT t.name,
		yearid,
		attendance,
		LEAD(attendance)OVER(ORDER BY yearid) AS next_years_attendance,
		CASE WHEN attendance <LEAD(attendance)OVER(ORDER BY yearid) THEN 'boost'
			 WHEN attendance > LEAD(attendance)OVER (ORDER BY yearid) THEN 'decline' 
			 ELSE 'N/A' END AS attendance_growth
 		
FROM teams AS t
WHERE wswin LIKE 'Y'
	AND yearid >=1900
GROUP BY t.name, yearid, attendance)

SELECT 	ROUND(AVG(CASE WHEN attendance_growth LIKE 'boost' THEN 1
					WHEN attendance_growth LIKE 'decline' THEN 0
					END), 2) AS pct_boost
		FROM boosted
		
/*What about teams that made the playoffs? 
Making the playoffs means either being a division winner or a wild card winner.
From 1900-2016, boosted 50% of the time vs. 46% of time for world series winners.

WITH boosted AS
(SELECT t.name,
		yearid,
		attendance,
		LEAD(attendance)OVER(ORDER BY yearid) AS next_years_attendance,
		CASE WHEN attendance <LEAD(attendance)OVER(ORDER BY yearid) THEN 'boost'
			 WHEN attendance > LEAD(attendance)OVER (ORDER BY yearid) THEN 'decline' 
			 ELSE 'N/A' END AS attendance_growth
 		
FROM teams AS t
WHERE divwin LIKE 'Y' 
	OR wcwin LIKE 'Y'
	AND yearid >=1900
GROUP BY t.name, yearid, attendance)

SELECT 	ROUND(AVG(CASE WHEN attendance_growth LIKE 'boost' THEN 1
					WHEN attendance_growth LIKE 'decline' THEN 0
					END), 2) AS pct_boost
		FROM boosted
*/		

/* 13. It is thought that since left-handed pitchers are more rare, 
causing batters to face them less often, that they are more effective. 
Investigate this claim and present evidence to either support or dispute 
this claim. First, determine just how rare left-handed pitchers are 
compared with right-handed pitchers. 27% of pitchers are left-handed.

WITH throwing AS 
(SELECT p.namefirst, p.namelast,
		throws
FROM pitching AS pi
LEFT JOIN people AS p
ON pi.playerid = p.playerid
GROUP BY p.namefirst, p.namelast, throws)

SELECT ROUND(AVG(CASE WHEN throws LIKE 'L' THEN 1
					WHEN throws LIKE 'R' THEN 0
					END), 2) AS pct_left
FROM throwing


Are left-handed pitchers more likely to win the Cy Young Award?
Yes, they win it 31% of the time. 



WITH throwing AS 
(SELECT p.namefirst, p.namelast,
		throws, awardid
FROM pitching AS pi
LEFT JOIN people AS p
ON pi.playerid = p.playerid
JOIN awardsplayers AS a
ON pi.playerid = a.playerid
WHERE awardid ILIKE '%cy%'
GROUP BY p.namefirst, p.namelast, throws, a.awardid)

SELECT ROUND(AVG(CASE WHEN throws LIKE 'L' THEN 1
					WHEN throws LIKE 'R' THEN 0
					END), 2) AS pct_left
FROM throwing

Are they more likely to make it into the hall of fame? Yes, slightly more likely at 28%.

WITH throwing AS 
(SELECT p.namefirst, p.namelast,
		throws, pi.playerid
FROM pitching AS pi
LEFT JOIN people AS p
ON pi.playerid = p.playerid
GROUP BY p.namefirst, p.namelast, throws, pi.playerid)



SELECT ROUND(AVG(CASE WHEN throws LIKE 'L' THEN 1
					WHEN throws LIKE 'R' THEN 0
					END), 2) AS pct_left
FROM throwing
JOIN halloffame
ON throwing.playerid = halloffame.playerid
WHERE throwing.playerid IN
		(SELECT halloffame.playerid
			FROM halloffame)

