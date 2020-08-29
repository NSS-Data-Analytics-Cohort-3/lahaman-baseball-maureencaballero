/* 1. Find the name and height of the shortest player in the database. Eddie Gaedel
How many games did he play in? 1
What is the name of the team for which he played? St Louis Browns

SELECT namefirst, namelast, height, a.G_all, t.name
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
JOIN teams AS t
ON a.teamid=t.teamid AND a.yearid =t.yearid
WHERE height IN
	(SELECT MIN(height) 
	 FROM people) */
	 


	 
	 
/*Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the 
total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors? David Price $245,553,888 

player_name	total_salary_earned
David Price	245553888
Pedro Alvarez	62045112
Scott Sanderson	21500000
Mike Minor	20512500
Joey Cora	16867500
Mark Prior	12800000
Ryan Flaherty	12183000
Josh Paul	7920000
Sonny Gray	4627500
Mike Baxter	4188836
Jensen Lewis	3702000
Matt Kata	3180000
Nick Christiani	2000000
Jeremy Sowers	1154400
Scotti Madison	540000

SELECT  CONCAT(p.namefirst, ' ',p.namelast) AS player_name,
		SUM(s.salary) AS total_salary_earned
FROM collegeplaying AS cp
JOIN people AS p
ON cp.playerid=p.playerid
JOIN salaries AS s
ON p.playerid=s.playerid
WHERE schoolid ILIKE 'Vand%'
GROUP BY player_name
ORDER BY total_salary_earned DESC */

/* Actually 24 players listed from Vandy, but only 15 players show salary figures 
from salaries table. Checked one of them and not in table.

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
*/

WITH nlTSNs AS 
	(SELECT a.playerid
	FROM awardsmanagers AS a
	INNER JOIN people AS p
	ON a.playerid=p.playerid
	WHERE awardid LIKE '%TSN%' 
	AND a.lgid LIKE 'NL')


SELECT CONCAT(namefirst,' ', namelast) AS mgr_name,
		a.lgid, a.yearid, t.name
FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid = p.playerid 
INNER JOIN managers AS m
ON a.playerid = m.playerid AND a.yearid=m.yearid
INNER JOIN teams AS t
ON m.teamid = t.teamid AND a.yearid=t.yearid
WHERE awardid LIKE '%TSN' 
	AND a.lgid LIKE 'AL'
	AND a.playerid IN
		(SELECT a.playerid
	FROM awardsmanagers AS a
	INNER JOIN people AS p
	ON a.playerid=p.playerid
	WHERE awardid LIKE '%TSN%' 
	AND a.lgid LIKE 'NL')

ORDER BY mgr_name
	




