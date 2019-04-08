/*Country_club is database containing information on a country club, in 3 tables: Bookings, Facilities, and Members.

Bookings columns: bookid, facid, memid, slots, starttime
Facilities columns: facid, guestcost, initialoutlay, membercost, monthlymaintenance, name
Members columns: address, firstname, joindate, memid, recommendedby, surname, telephone, zip code
*/

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name, membercost
FROM country_club.Facilities
WHERE membercost > 0.0

/* Q2: How many facilities do not charge a fee to members? */

SELECT membercost, COUNT(*) AS counts
FROM country_club.Facilities
GROUP BY membercost

SELECT COUNT(CASE WHEN membercost = 0.0 THEN 1 ELSE NULL END) AS counts
FROM country_club.Facilities

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,
       name,
       membercost,
       monthlymaintenance,
       membercost/monthlymaintenance AS pct
FROM country_club.Facilities
WHERE membercost/monthlymaintenance < 0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
       monthlymaintenance,
       CASE WHEN monthlymaintenance < 100 THEN 'cheap'
            ELSE 'expensive' END AS price_category
FROM country_club.Facilities
ORDER BY monthlymaintenance

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
       surname,
       joindate
FROM country_club.Members
WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT sub.surname, sub.firstname, sub.bookid, fac.name
FROM(
    SELECT mem.surname, mem.firstname, book.bookid, book.facid, book.starttime
    FROM country_club.Bookings book
    JOIN country_club.Members mem
    ON book.memid = mem.memid
    WHERE book.facid IN (0,1)
    ) sub
JOIN country_club.Facilities fac
ON sub.facid = fac.facid
ORDER BY sub.surname, sub.firstname, sub.bookid


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CASE WHEN mem.surname NOT LIKE 'GUEST' THEN CONCAT(mem.firstname, ' ', mem.surname)
            ELSE mem.surname END AS name,
       fac.name,
       CASE WHEN book.memid = 0 THEN book.slots*fac.guestcost
            ELSE book.slots*fac.membercost END AS cost
FROM country_club.Bookings book
JOIN country_club.Facilities fac
ON book.facid = fac.facid
JOIN country_club.Members mem
ON book.memid = mem.memid
WHERE book.starttime LIKE '2012-09-14%'
AND CASE WHEN book.memid = 0 THEN book.slots*fac.guestcost
            ELSE book.slots*fac.membercost END > 30
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT CASE WHEN sub2.surname NOT LIKE 'GUEST' THEN CONCAT(sub2.firstname, ' ', sub2.surname)
            ELSE sub2.surname END AS name,
       sub.name,
       sub.cost
FROM(
    SELECT book.memid, fac.name, 
           CASE WHEN book.memid = 0 THEN book.slots*fac.guestcost
           ELSE book.slots*fac.membercost END AS cost
    FROM country_club.Bookings book
    JOIN country_club.Facilities fac
    ON book.facid = fac.facid
    WHERE starttime LIKE '2012-09-14%'
    ) AS sub
JOIN (SELECT memid, surname, firstname
      FROM country_club.Members) AS sub2
ON sub.memid = sub2.memid
WHERE cost > 30
ORDER BY cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT sub.name, sub.total_revenue
FROM(
     SELECT fac.name, 
            SUM(CASE WHEN book.memid = 0 THEN book.slots*fac.guestcost
                     ELSE book.slots*fac.membercost END) AS total_revenue
     FROM country_club.Bookings book
     JOIN country_club.Facilities fac
     ON book.facid = fac.facid
     GROUP BY fac.name
    ) AS sub
WHERE sub.total_revenue < 1000
ORDER BY sub.total_revenue




