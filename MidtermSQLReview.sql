#Find the titles of all movies directed by Steven Spielberg. 

select title 
from Movie where director = 'Steven Spielberg';

#Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
select distinct year 
from Movie, Rating 
where Movie.mID = Rating.mID and stars>=4 
order by year;

#Find the titles of all movies that have no ratings. 
select title 
from Movie 
where mID not in (select mID from Rating)

#Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
select name 
from Reviewer 
where rID in (select rID from Rating where ratingDate is Null);

#Write a query to return the ratings data in a more readable format:
#reviewer name, movie title, stars, and ratingDate. Also, sort the
#data, first by reviewer name, then by movie title, and lastly by
#number of stars.

select R.name, M.title, Ra.stars, Ra.ratingDate 
from Movie M, Reviewer R, Rating Ra 
where R.rID = Ra.rID and M.mID = Ra.mID 
order by R.name,
M.title, Ra.stars;

#For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 

select Re1.name, M1.title 
from Movie M1, Reviewer Re1, Rating Ra1, Rating Ra2 
where M1.mID = Ra1.mID and Re1.rID = Ra1.rID and Ra1.rID = Ra2.rID and Ra1.mID = Ra2.mID and Ra1.ratingDate < Ra2.ratingDate and Ra1.stars < Ra2.stars;

select R.name, M.title
from Movie M, Reviewer R, Rating Ra1, Rating Ra2
where M.mID = Ra1.mID and R.rID = Ra1.rID and Ra1.mID = Ra2.mID and Ra1.rID = Ra2.rID
and Ra1.ratingDate < Ra2.ratingDate and Ra1.stars < Ra2.stars;

#For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

select M1.title, max(Ra1.stars) from Movie M1, Rating Ra1 where M1.mID = Ra1.mID group by M1.title order by M1.title;

#List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 

select title, avg(stars) as avg
from movie join rating using (mid)
group by title
order by avg desc, title

#Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) 

select name 
from reviewer r 
where 3<=(select count(*) 
          from rating 
          where rating.rid = r.rid)


#For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 

select movie.title, max(stars)-min(stars) as spread
from rating join movie on rating.mid=movie.mid
group by rating.mid
order by spread desc, title

#Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 

select max(a1)-min(a1) from
(select avg(av1) a1 from
(select avg(stars) av1 from rating r join movie m on r.mid=m.mid where m.year < 1980
group by r.mid)
union
select avg(av2) a1 from
(select avg(stars) av2 from rating r join movie m on r.mid=m.mid where m.year > 1980
group by r.mid))

#Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 

select title, director 
from movie 
where director in (select director 
                  from (select director, count(title) as s 
                        from movie 
                        group by director) as t
                  where t.s>1)
order by 2,1

#Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 

select m.title, avg(r.stars) as strs from rating r
join movie m on m.mid = r.mid group by r.mid
having strs = (select max(s.stars) as stars from (select mid, avg(stars) as stars from rating
group by mid) as s)

#Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 

select m.title, avg(r.stars) as strs from rating r
join movie m on m.mid = r.mid group by r.mid
having strs = (select min(s.stars) as stars from (select mid, avg(stars) as stars from rating
group by mid) as s)

#For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 

select director, title, stars
from movie m, rating r
where m.mid = r.mid and director is not null
group by director 
order by stars desc

#Social Networking
------------------
#Find the names of all students who are friends with someone named Gabriel. 

select name from Highschooler
where id in (
  select ID1 from friend where id1 = id and
  id2 IN (select id from Highschooler where name="Gabriel")
)

#For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 

select h1.name, h1.grade, h2.name, h2.grade
from highschooler as h1
join likes as l on l.id1 = h1.id
join highschooler as h2 on h2.id = l.id2
where h2.grade <= h1.grade - 2

#For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 

select n2, g2, n1, g1 from
( select h1.id+h2.id as mult, h1.name as n1, h1.grade as g1, h2.name as n2, h2.grade as g2
  from likes as l
  join highschooler as h1 on h1.id = l.id1
  join highschooler as h2 on h2.id = l.id2
  where exists (select * from likes where id1=h2.id and id2=h1.id)
  order by  mult asc , h1.name < h2.name desc
) as t
group by mult

#Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 

select  h1.name, h1.grade
from highschooler as h1
join friend as f on f.id1=h1.id
join highschooler as h2 on h2.id = f.id2
where h1.grade=h2.grade
and not exists (select id from highschooler where id in (
  select id2 from friend where id1=h1.id) and grade <> h1.grade)
group by h1.name
order by h1.grade, h1.name

#Find the name and grade of all students who are liked by more than one other student. 

select name, grade from highschooler
where id in (
select id2
from likes
group by id2
having count(id1) > 1
)

#Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 

select name, grade
from highschooler
where id not in (select id1 from likes)
and id not in (select ID2 from likes)
order by 2,1

#For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 

select h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
from highschooler h1, highschooler h2, highschooler h3,
(select l.id1 as lid1, l.id2 as lid2, f2.id1 as f2id1 from likes l, friend f2, friend f3 where
not exists (select f.id1, f.id2 from friend f where f.id1 = l.id1 and f.id2 = l.id2)
and f2.id2 = l.id1 and f3.id2 = l.id2 and f2.id1 = f3.id1) as t
where h1.id = t.lid1 and h2.id = t.lid2 and h3.id = f2id1

#Find the difference between the number of students in the school and the number of different first names. 

select (select count(id) from Highschooler)-(select count(distinct name) from Highschooler)

#What is the average number of friends per student? (Your result should be just one number.) 

select avg(c) from (select id1, count(id2) c from friend group by id1)

#Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. 

select count(id2) from friend where id1 in (
  select id2 from friend where id1 in (select id from highschooler where name='Cassandra')
)
and id1 not in (select id from highschooler where name='Cassandra')

#Find the name and grade of the student(s) with the greatest number of friends. 

select h.name, h.grade from highschooler h, friend f where
h.id = f.id1 group by f.id1 having count(f.id2) = (
select max(r.c) from
(select count(id2) as c from friend group by id1) as r)

#Movie modification

--------------

#Add the reviewer Roger Ebert to your database, with an rID of 209. 

insert into Reviewer Values ('209','Roger Ebert');

#Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 

insert into Rating  ( rID, mID, stars, ratingDate )
select Reviewer.rID , Movie.mID, 5, null from Movie
left outer join Reviewer
where Reviewer.name='James Cameron'

#For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.) 

update movie set year = year + 25 where mID in (   select mID from (   select
AVG(stars) as astar, mID from Rating   where mID=rating.mID   group by mID
having astar >=4) )

#Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars. 

delete from rating
where mID in (select mID from movie where year <1970 or year > 2000)
and stars < 4

#It's time for the seniors to graduate. Remove all 12th graders from Highschooler. 

delete from Highschooler
where grade =12

#If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. 

delete from likes
where id1 in (select likes.id1 
              from friend join likes using (id1) 
              where friend.id2 = likes.id2) 
      and not id2 in (select likes.id1 
                      from friend join likes using (id1) 
                      where friend.id2 = likes.id2)

#For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.) 

insert into friend
select f1.id1, f2.id2
from friend f1 join friend f2 on f1.id2 = f2.id1
where f1.id1 <> f2.id2
except
select * from friend

#Return all reviewer names and movie names together in a single list, alphabetized. 
#(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 

select M.title, R.name
from Movie M, Reviewer R, Rating Ra
where M.mID = Ra.mID and R.rID = Ra.rID




select title
from Movie
where mID not in (select mID
from Rating
where rID in (select rID
from Reviewer
where name = "Chris Jackson") )

select title
from Movie
where mID not in (select mID 
	from Rating where rID in (select rID from Reviewer where name = "Chris Jackson"));


select nameFirst, nameSecond
from (select distinct nameFirst, nameSecond
from (select R1.rID as rIDFirst, R2.rID as rIDSecond
from Rating R1 join Rating R2 using(mID)
where R1.mID = R2.mID and R1.rID <> R2.rID)
join
(select rID as rIDFirst, name as nameFirst
from Reviewer) using(rIDFirst)
join
(select rID as rIDSecond, name as nameSecond
from Reviewer) using(rIDSecond)
order by nameFirst)
where nameFirst < nameSecond




