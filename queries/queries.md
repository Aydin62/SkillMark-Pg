<!-- The SQL query log and analytical checklist -->

# SkillMark Query Matrix

> This document is a structured and extensive SQL query log.
> It demonstrates the full spectrum of query types supported by PostgreSQL 9.5+,
> organized by "conceptual tiers", and grouped analytically.

The purpose is to show the mastery of: 

- Relational data modeling
- Aggregate queries
- JOINS
- Window functions (and windowed aggregate functions)
- Analytics-driven thinking

All queries are based on the `SkillMark` database schema.

---

## Tier 1 - Basic Aggregates (Using `GROUP BY`)

This tier includes core aggregate functions applied to group data.

| ID  | Description | SQL Function | Grouped By | Notes |
|---|---|---|---|---|
|T1-01|Count logs per user| `COUNT(*)`|`user_id`||
|T1-02|Average score per module|`AVG(score)`|`module_id`||
|T1-03|Total time per user|`SUM(time)`|`user_id`||
|T1-04|Highest score per course|`MAX(score)`|`title`|Needs JOIN|
|T1-05|Lowest score per user|`MIN(score)`|`user_id`||

### T1-01. Count logs per user

This query shows how many progress log entries each user has in the system. A basic measure of their activity level.

```sql
-- T1-01
SELECT user_id, COUNT(*) AS log_count
FROM progress_logs
GROUP BY user_id;
```

#### Output:

| user_id | log_count |
|---------|-----------|
| 3       | 2         |
| 2       | 3         |
| 1       | 5         |
|||
---

### T1-02. Average score per module

Returns the average score gained for each module by all users.

```sql
-- T1-02
SELECT module_id, AVG(score) AS average_score
FROM progress_logs
GROUP BY module_id;
```

#### Output:

| module_id | average_score       |
|-----------|---------------------|
| 5         | 90.0000000000000000 |
| 4         | 91.0000000000000000 |
| 2         | 83.8333333333333333 |
| 7         | 95.6000000000000000 |
| 1         | 80.5000000000000000 |
|||
---

### T1-03. Total time per user

The total time each user has spent (in minutes).

```sql
-- T1-03
SELECT user_id, SUM(time_spent_minutes) AS total_time
FROM progress_logs
GROUP BY user_id;
```

#### Output:

| user_id | total_time |
|---------|------------|
| 3       | 90         |
| 2       | 150        |
| 1       | 225        |
|||
---

### T1-04. Highest score per course

(Needs `JOIN`, but the primary focus is on ***basic aggregation.***)

Gives the highest score achieved per each course. This requires joining the following three tables: `progress_logs` → `modules` → `courses`

```sql
-- T1-04
SELECT c.title, MAX(l.score) AS max_score
FROM progress_logs l
JOIN modules m ON l.module_id = m.module_id
JOIN courses c ON m.course_id = c.course_id
GROUP BY c.title;
```

#### Output:

| title          | max_score |
|----------------|-----------|
| Physics        | 91.0      |
| Healthcare     | 95.6      |
| Linear Algebra | 95.0      |
|||
---

### T1-05. Lowest score per user

Shows the lowest score each user has gained during the progress.

```sql
-- T1-05
SELECT user_id, MIN(score) as min_score
FROM progress_logs
GROUP BY user_id;
```

#### Output:

| user_id | min_score |
|---------|-----------|
| 3       | 90.0      |
| 2       | 70.0      |
| 1       | 78.0      |
|||
---
---

<br>

## Tier 2 - Join + Grouping

This tier includes queries that require:
- Aggregation (`AVG`, `SUM`, etc.),
- Grouping, and
- `JOIN`-ing across two or more tables,

with a focus on **multi-table design reasoning** and **relational analytics.**
These queries demonstrate relational integrity and entity-level analysis across the schema.

|ID|Description|SQL Concept|Tables Involved|Notes|
|---|---|---|---|---|
|T2-01|Average score per course title|`JOIN` + `GROUP BY`|`progress_logs`, `modules`, `courses`||
|T2-02|Total time per category|`JOIN` + `GROUP BY`|`progress_logs` → `modules` → `courses`||
|T2-03|Number of modules per course|`JOIN` + `GROUP BY`|`modules`, `courses`|5 variants (and 3 subvariants)|
|T2-04|Number of users who took each course|`JOIN` + `COUNT DISTINCT`|`progress_logs` → `modules` → `courses`|Needs `DISTINCT`|

### T2-01. Average score per course title (in descending order)

For each course title, calculates the average score across all users and all modules. Also sorts the average scores in descending order.

```sql
-- T2-01
SELECT c.title, AVG(l.score) AS average_score
FROM progress_logs l
JOIN modules m ON l.module_id = m.module_id
JOIN courses c ON m.course_id = c.course_id
GROUP BY c.title
ORDER BY average_score DESC;
```

#### Output:

| title          | average_score       |
|----------------|---------------------|
| Healthcare     | 95.6000000000000000 |
| Physics        | 90.5000000000000000 |
| Linear Algebra | 83.3571428571428571 |
|||
---

### T2-02. Total time per category (in ascending order +  `NULL` filtering)

Calculates the total time that all users have spent for completing modules from each course category (*Science*, *Math*, etc.). Sorts the results in ascending order. Also, filters out any existing `NULL`-s.

```sql
-- T2-02
SELECT c.category, SUM(l.time_spent_minutes) AS total_minutes
FROM progress_logs l
JOIN modules m ON l.module_id = m.module_id
JOIN courses c ON m.course_id = c.course_id
WHERE l.time_spent_minutes IS NOT NULL
GROUP BY c.category 
ORDER BY total_minutes;
```

#### Output:

| category | total_minutes |
|----------|---------------|
| Science  | 180           |
| Math     | 285           |
|||
---

### T2-03. Number of modules per course (5 variants)

Here, the core question is:

> *How many modules does each course contain?*

This will be explored in the following five variants:

(A) basic count (the curriculum depth per course)

(B) including courses with zero modules (highlighting design gaps)

(C) ranking courses by module count (for quick comparison)

(D) min/max module order (for detecting missing sequence numbers)

(E) percentage of contribution (the share of total modules each course owns)

#### T2-03-A: Basic module count per course

Counts how many modules each course contains, showing the curriculum depth per course.

```sql
-- T2-03-A
SELECT c.title, COUNT(m.module_id) AS module_count
FROM modules m 
JOIN courses c ON m.course_id = c.course_id
GROUP BY c.title;
```

#### Output:

| title          | module_count |
|----------------|--------------|
| Physics        | 3            |
| Healthcare     | 3            |
| Linear Algebra | 3            |
|||

#### T2-03-B: Including courses with zero modules

Answers the following question: 

> *"For each course, how many modules are linked to it (possibly none)?"*

We use a `LEFT JOIN` for this. Also, remember that, equivalently, we could use a `RIGHT JOIN` provided that we started from the opposite direction (i.e. from table `modules`).

```sql
-- T2-03-B
SELECT c.title, COUNT(m.module_id) AS module_count
FROM courses c
LEFT JOIN modules m ON m.course_id = c.course_id
GROUP BY c.title;
```

#### Output:

| title          | module_count |
|----------------|--------------|
| Physics        | 3            |
| Healthcare     | 3            |
| Linear Algebra | 3            |
|||

#### T2-03-C: Ranking courses by module count

Includes zero counts just like the previous case. This time, we use `RIGHT JOIN`.

```sql
-- T2-03-C
SELECT c.title, COUNT(m.module_id) AS module_count
FROM modules m 
RIGHT JOIN courses c ON m.course_id = c.course_id
GROUP BY c.title
ORDER BY module_count DESC;
```

#### Output:

| title          | module_count |
|----------------|--------------|
| Physics        | 3            |
| Healthcare     | 3            |
| Linear Algebra | 3            |
|||

#### T2-03-D: Detecting sequence gaps via min/max order

Here, we compare the *actual number* of module orders to the *expected number* of them to find out whether any gap exists in the numbering. 

We do this using a **subquery (inner query).**

```sql
-- T2-03-D
SELECT 
	*,
	CASE
		WHEN actual_number < expected_number
		THEN 'Yes'
		ELSE 'No'
	END AS gap_exists
FROM (
	SELECT 
	c.title, 
	COUNT(m.module_id) AS actual_number, 
	MAX(m.order_in_course) - MIN(m.order_in_course) + 1 
		AS expected_number
	FROM courses c 
	LEFT JOIN modules m ON m.course_id = c.course_id
	GROUP BY c.title
) AS course_counts;
```

#### Output:

| title          | actual_number | expected_number | gap_exists |
|----------------|---------------|-----------------|------------|
| Physics        | 3             | 3               | No         |
| Healthcare     | 3             | 3               | No         |
| Linear Algebra | 3             | 3               | No         |
|||

#### T2-03-E: Percentage of contribution of each course to the total number of modules

This shows how much each course contributes to the entire curriculum. Useful in dashboards and reports.

For the first time, we are going to use a (trivial) **window function** for this purpose (more on window functions in Tier 3 queries).

***Subvariant 1. Using a trivial window funtion, but no subquery***

```sql
-- T2-03-E-1
SELECT 
	c.title,
	COUNT(m.module_id) AS module_count,
	COUNT(m.module_id) * 100.0 / SUM(COUNT(m.module_id)) 
		OVER () AS percent_of_total
FROM modules m
JOIN courses c ON m.course_id = c.course_id
GROUP BY c.title;
```

#### Output:

| title          | module_count | percent_of_total    |
|----------------|--------------|---------------------|
| Physics        | 3            | 33.3333333333333333 |
| Healthcare     | 3            | 33.3333333333333333 |
| Linear Algebra | 3            | 33.3333333333333333 |
|||

Here, the trivial window function `OVER ()` is used. The ***windowed aggregate function*** 

`... / SUM(COUNT(m.module_id)) OVER ()` 

sums all the `SUM(COUNT(m.module_id))` values ***across the grouped result.***

<br>

> ✳️ **Remark.** The composite function `SUM(COUNT(...))` may confuse beginners; *it's valid only due to how PostgreSQL allows **aggregate inside window over grouped result.***

<br>

We can well do the above with a subquery instead of a window function:

***Subvariant 2. Using a subquery, but no window funtion***


```sql
-- T2-03-E-2
SELECT 
	c.title,
	COUNT(m.module_id) AS module_count,
	COUNT(m.module_id) * 100.0 / total.total_count AS percent_of_total
FROM modules m
JOIN courses c ON m.course_id = c.course_id
CROSS JOIN (
	SELECT COUNT(*) AS total_count FROM modules
) AS total
GROUP BY c.title, total.total_count;
```

#### Output:

| title          | module_count | percent_of_total    |
|----------------|--------------|---------------------|
| Physics        | 3            | 33.3333333333333333 |
| Healthcare     | 3            | 33.3333333333333333 |
| Linear Algebra | 3            | 33.3333333333333333 |
|||

Here, we `CROSS JOIN` the subquery result because it is only **one row** (i.e., it is a ***scalar***), while we would like to attach that single value *to every grouped row.* In other words, we make the **Cartesian product** of the single row `total` with the grouped row of the outer query.


But even we can have both a window function and a subquery:

***Subvariant 3. Using a hybrid trivial window funtion plus a subquery***

```sql
-- T2-03-E-3
SELECT
	*,
	module_count * 100.0 / SUM(module_count)
		OVER () AS percent_of_total
FROM (
	SELECT
		c.course_id,
		c.title,
		COUNT(m.module_id) AS module_count
	FROM modules m
	JOIN courses c ON m.course_id = c.course_id
	GROUP BY c.course_id, c.title
) AS course_module_counts;
```

#### Output:

| course_id | title          | module_count | percent_of_total    |
|-----------|----------------|--------------|---------------------|
| 3         | Healthcare     | 3            | 33.3333333333333333 |
| 2         | Physics        | 3            | 33.3333333333333333 |
| 1         | Linear Algebra | 3            | 33.3333333333333333 |
|||

> - What this does:
> 	1. Subquery: pre-aggregates one row per course with `module_count`
> 
>	2. Outer query: uses the (trivially) windowed aggregate function `... / SUM(module_count) OVER ()` to get the total of module counts
>
> - Benefit: cleaner logic, and flexible for re-use (e.g. later window ranking, sorting, & filtering)
> 
> - Ideal for dashboards and reporting queries (since it *layers analytics cleanly*)

---

### T2-04. Number of (distinct) users who took each course

For each course, counts how many **distinct users** have interacted with at least one of its modules. Useful to gauge course popularity.

```sql
-- T2-04
SELECT 
	c.title,
	COUNT(DISTINCT l.user_id) AS user_count
FROM progress_logs l
LEFT JOIN modules m ON l.module_id = m.module_id
LEFT JOIN courses c ON m.course_id = c.course_id
GROUP BY c.title
ORDER BY user_count DESC;
```

#### Output:

| title          | user_count |
|----------------|------------|
| Linear Algebra | 3          |
| Healthcare     | 1          |
| Physics        | 1          |
|||

* Also includes courses with zero users by applying `LEFT JOIN`s. (For nonzero-only courses, we could simply use inner joins instead.)

---
---

<br>

## Tier 3 - Window Functions

This tier is where SQL stops being just a *grouping and counting* tool and becomes a full-fledged **analytical language!**

<br>

> ***What does Tier 3 cover?***
> 
> - Adds *new columns;* doesn't collapse rows; keeps full details in the result
>
> - Uses `OVER (...)`, the *defining clause* of window functions
>
> - Computes **rankings, totals, moving stats** on a *per-row* basis
>
> - Subsumes ***windowed aggregate functions*** such as `SUM(...) OVER (...)`, etc.

<br>

### Tier 3 Essentials

|ID|Technique|Common Use Cases|
|---|---|---|
|T3-01|`ROW_NUMBER()`|Get the **most recent attempt** or **first appearance** per user/module|
|T3-02|`RANK()` vs `DENSE_RANK()`|Build **leaderboards**, assign **positions** with or without gaps|
|T3-03|`SUM(...) OVER (PARTITION BY ...)`|Compute **cumulative time/score per user or course,** without collapsing|
|T3-04|`AVG(...) OVER (ORDER BY ...)`|**Moving averages,** smoothing score trends over time|
|T3-05|`LAG()` / `LEAD()`|Compare **previous or next attempts**--e.g. to detect improvement|
|T3-06|**Mix of aggregation + windowing**|Calculate the **percent of total, relative ranking, group normalization**|

---

### T3-01. The most recent attempt per user per module

Uses a **subquery with a window function** to partition logs by each user-module pair and to identify their most recent attempt.

```sql
-- T3-01
SELECT * 
FROM (
	SELECT 
		u.user_name,
		c.title,
		m.module_title,
		l.log_id,
		l.started_at,
		l.completed_at,
		l.score,
		ROW_NUMBER() OVER (
			PARTITION BY l.user_id, l.module_id
			ORDER BY l.log_id DESC
		) AS rn
	FROM progress_logs l
	JOIN modules m ON l.module_id = m.module_id
	JOIN courses c ON m.course_id = c.course_id
	JOIN users u ON l.user_id = u.user_id
) AS ranked_logs
WHERE rn = 1
ORDER BY user_name, title, module_title;
```

#### Output:

| user_name | title          | module_title           | log_id | started_at          | completed_at        | score | rn |
|-----------|----------------|------------------------|--------|---------------------|---------------------|-------|----|
| B J       | Linear Algebra | Linear Transformations | 8      | 2023-01-20 10:00:00 | 2023-01-20 10:25:00 | 95.0  | 1  |
| B J       | Linear Algebra | Vector Spaces          | 1      | 2025-03-15 10:00:00 | 2025-03-15 11:00:00 | 80.5  | 1  |
| K H E     | Linear Algebra | Linear Transformations | 9      | 2023-01-16 11:00:00 | 2023-01-16 11:30:00 | 70.0  | 1  |
| K H E     | Physics        | Newtonian Mechanics    | 2      | 2025-03-15 10:00:00 | 2025-03-15 11:00:00 | 91.0  | 1  |
| K H E     | Physics        | Thermodynamics         | 5      | 2025-03-23 14:00:00 | 2025-03-23 15:00:00 | 90.0  | 1  |
| O S       | Healthcare     | Human Body             | 3      | 2025-03-15 10:00:00 | 2025-03-15 11:00:00 | 95.6  | 1  |
| O S       | Linear Algebra | Linear Transformations | 10     | 2023-01-16 11:00:00 | 2023-01-16 11:30:00 | 90.0  | 1  |
|||

What the snippet does:

- **The inner query:** joins all relevant tables, and groups progress logs by each unique `(user_id, module_id)` pair. It then ranks the logs within each group using a `ROW_NUMBER()` window function ordered by `log_id DESC`, so that the most recent entry gets `rn = 1`, the second most recent gets `rn = 2`, and so on. Picks user names, course titles, module titles, log id's, timestamps, and scores from all the available columns.

- **The outer query:** filters out only the most recent attempt for each user-module combination using the filtering condition `WHERE rn = 1`. Also, orders the results by user name, course title, and module title.

---

### T3-02. Ranking users by average score: `RANK()` vs `DENSE_RANK()`

Ranks users based on their average scores across modules, considering only the **most recent attempt per user per module.** Demonstrates the difference between `RANK()` and `DENSE_RANK()`.

For this task, we re-use the inner query from T3-01, and apply the above two window functions in the outer query.

```sql
-- T3-02
SELECT 
	user_name,
	ROUND(AVG(score), 2) AS avg_score,
	RANK() OVER (ORDER BY AVG(score) DESC) AS rank_r,
	DENSE_RANK() OVER (ORDER BY AVG(score) DESC) AS rank_dr
FROM (
	SELECT 
		u.user_name,
		l.score,
		ROW_NUMBER() OVER (
			PARTITION BY l.user_id, l.module_id
			ORDER BY l.log_id DESC
		) AS rn
	FROM progress_logs l
	JOIN modules m ON l.module_id = m.module_id
	JOIN courses c ON m.course_id = c.course_id
	JOIN users u ON l.user_id = u.user_id
) AS recent_logs
WHERE rn = 1
GROUP BY user_name
ORDER BY avg_score DESC;
```

#### Output:

| user_name | avg_score | rank_r | rank_dr |
|-----------|-----------|--------|---------|
| O S       | 92.80     | 1      | 1       |
| B J       | 87.75     | 2      | 2       |
| K H E     | 83.67     | 3      | 3       |
|||

> **What it does:**
>
> - **Inner query** (`recent_logs`)
> 	- for every unique user-module pair, keeps only the *the most recent attempt,* using `ROW_NUMBER()`.
>
> - **Outer query**
> 	- groups by user name;
> 
> 	- computes the *average score;*
> 
> 	- applies both `RANK()` and `DENSE_RANK()` window functions to show:
> 		- `RANK()` introduces gaps if users have the same score,
> 		- `DENSE_RANK()` makes no gaps between tied ranks.

---

### T3-03. Duration per module attempt and total time spent per course

Claculates the time (in seconds) each user spent on a module, and shows the total time spent across all modules in the same course.

> - This time, we define a **CTE** (Common Table Expression). CTEs are defined using the `WITH` clause.
>
> - Also, we apply a **windowed aggregate function** `SUM() OVER (PARTITION BY)` to calculate the **cumulative time spent** (in seconds) on each course across all users' module attempts. Unlike grouped queries, this apporach retains *one row per log entry,* while showing the *total duration per course* on each row.

<br>

> ✳️ Uses `EXTRACT(EPOCH FROM ...)` to retrieve the duration. 
> 
> ⚠️ ***Note**. Be aware that the `EPOCH` unit is for **PostgreSQL, Redshift, Snowflake, and QuestDB** only! For other DB systems, you have to use equivalent syntaxes.*

```sql
-- T3-03
WITH logs_with_duration AS (
	SELECT 
		u.user_name,
		c.course_id,
		c.title AS course_title,
		m.module_title,
		l.started_at,
		l.completed_at,
		EXTRACT(EPOCH FROM l.completed_at - l.started_at) 
			AS duration_seconds
	FROM progress_logs l
	JOIN modules m ON l.module_id = m.module_id
	JOIN courses c ON m.course_id = c.course_id
	JOIN users u ON l.user_id = u.user_id
)
SELECT
	user_name,
	module_title,
	duration_seconds,
	course_title,
	SUM(duration_seconds) OVER (PARTITION BY course_id) 
		AS course_total_time
FROM logs_with_duration;
```

#### Output:

| user_name | module_title           | duration_seconds | course_title   | course_total_time |
|-----------|------------------------|------------------|----------------|-------------------|
| O S       | Linear Transformations | 1800.000000      | Linear Algebra | 17100.000000      |
| B J       | Linear Transformations | 1500.000000      | Linear Algebra | 17100.000000      |
| K H E     | Linear Transformations | 1800.000000      | Linear Algebra | 17100.000000      |
| B J       | Vector Spaces          | 3600.000000      | Linear Algebra | 17100.000000      |
| B J       | Linear Transformations | 5400.000000      | Linear Algebra | 17100.000000      |
| B J       | Linear Transformations | 1800.000000      | Linear Algebra | 17100.000000      |
| B J       | Linear Transformations | 1200.000000      | Linear Algebra | 17100.000000      |
| K H E     | Newtonian Mechanics    | 3600.000000      | Physics        | 7200.000000       |
| K H E     | Thermodynamics         | 3600.000000      | Physics        | 7200.000000       |
| O S       | Human Body             | 3600.000000      | Healthcare     | 3600.000000       |
|||

What is does:

- `duration_seconds`: shows how long each module attempt took,
- `course_total_time`: sums these durations across all modules.

---

### T3-04. Moving average of scores (3-row rolling window)

Calculates a **rolling average of scores** for each user, using a window of the *current row and the two preceeding attempts* (if available), ordered by when the module was started.

- Helps track **short-term learning trends** for each user.
- The moving average **partitioned by user** to calculate scores independently.
- Only **the latest three attempts** are used at each step to smooth performance trends.

This type of query is ideal for *real-time feedback systems.*

```sql
-- T3-04
WITH moving_avgs AS (
	SELECT 
		u.user_id,
		u.user_name,
		c.title AS course_title,
		m.module_title,
		l.started_at,
		l.score
	FROM progress_logs l
	JOIN modules m ON l.module_id = m.module_id
	JOIN courses c ON m.course_id = c.course_id
	JOIN users u ON l.user_id = u.user_id
)
SELECT
	user_name,
	module_title,
	course_title,
	AVG(score) OVER (
				PARTITION BY user_id 
				ORDER BY started_at
				ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
				) AS cumulative_avg_score
FROM moving_avgs
ORDER BY user_name, started_at;
```

#### Output:

| user_name | module_title           | course_title   | cumulative_avg_score |
|-----------|------------------------|----------------|----------------------|
| B J       | Linear Transformations | Linear Algebra | 80.0000000000000000  |
| B J       | Linear Transformations | Linear Algebra | 85.0000000000000000  |
| B J       | Linear Transformations | Linear Algebra | 88.3333333333333333  |
| B J       | Vector Spaces          | Linear Algebra | 88.5000000000000000  |
| B J       | Linear Transformations | Linear Algebra | 84.5000000000000000  |
| K H E     | Linear Transformations | Linear Algebra | 70.0000000000000000  |
| K H E     | Newtonian Mechanics    | Physics        | 80.5000000000000000  |
| K H E     | Thermodynamics         | Physics        | 83.6666666666666667  |
| O S       | Linear Transformations | Linear Algebra | 90.0000000000000000  |
| O S       | Human Body             | Healthcare     | 92.8000000000000000  |
|||

> ***Note.** In the above window function, `ROWS BETWEEN` must come **after** `ORDER BY`.*

---

### T3-05. Compare each attempt with the previous and the next

Analyzes how each user's module scores change over time by retrieving their **previous** (`LAG`) and **next** (`LEAD`) scores, ordered chronologically. This allows us to detect learning patterns such as *improvement, decline, or fluctuations* across modules within a course.

> Key points:
>
> - uses `PARTITION BY user_id` to scope the analysis per user;
>
> - orders by `started_at` to track progression;
>
> - also calculates `lag_delta` and `lead_delta`, the differences between the current score and its respective sequential neighbors.

<br>

```sql
-- T3-05
WITH lag_lead AS (
	SELECT 
		u.user_id,
		u.user_name,
		c.title AS course_title,
		m.module_title,
		l.started_at,
		l.score,
		LAG(score) OVER (
				PARTITION BY u.user_id 
				ORDER BY started_at
				) AS score_lag,
		LEAD(score) OVER (
				PARTITION BY u.user_id 
				ORDER BY started_at
				) AS score_lead
	FROM progress_logs l
	JOIN modules m ON l.module_id = m.module_id
	JOIN courses c ON m.course_id = c.course_id
	JOIN users u ON l.user_id = u.user_id
)
SELECT
	user_name,
	module_title,
	course_title,
	score,
	score_lag,
	score - score_lag AS lag_delta,
	score_lead,
	score_lead - score AS lead_delta
FROM lag_lead
ORDER BY user_name, started_at;
```

#### Output:

| user_name | module_title           | course_title   | score | score_lag | lag_delta | score_lead | lead_delta |
|-----------|------------------------|----------------|-------|-----------|-----------|------------|------------|
| B J       | Linear Transformations | Linear Algebra | 80.0  | NULL      | NULL      | 90.0       | 10.0       |
| B J       | Linear Transformations | Linear Algebra | 90.0  | 80.0      | 10.0      | 95.0       | 5.0        |
| B J       | Linear Transformations | Linear Algebra | 95.0  | 90.0      | 5.0       | 80.5       | -14.5      |
| B J       | Vector Spaces          | Linear Algebra | 80.5  | 95.0      | -14.5     | 78.0       | -2.5       |
| B J       | Linear Transformations | Linear Algebra | 78.0  | 80.5      | -2.5      | NULL       | NULL       |
| K H E     | Linear Transformations | Linear Algebra | 70.0  | NULL      | NULL      | 91.0       | 21.0       |
| K H E     | Newtonian Mechanics    | Physics        | 91.0  | 70.0      | 21.0      | 90.0       | -1.0       |
| K H E     | Thermodynamics         | Physics        | 90.0  | 91.0      | -1.0      | NULL       | NULL       |
| O S       | Linear Transformations | Linear Algebra | 90.0  | NULL      | NULL      | 95.6       | 5.6        |
| O S       | Human Body             | Healthcare     | 95.6  | 90.0      | 5.6       | NULL       | NULL       |
|||

> ✳️ Here, purposefully, `NULL` entries are kept, so that you can observe the mathematical structure of the resulting table clearly. Of course, many other additional refinements may be applied to the query.

---

### T3-06. Score analytics with percent share, ranking, and z-score

Analyzes users' scores across modules and courses by calculating

- **Percent of total score:** each score as a percentage of the total sum of all scores
- **Rank within course:** a dense rank of each score within its course, from highest to lowest
- **Z-score normalization:** standardized score within its course to highlight relative performance

```sql
-- T3-06
WITH raw AS (
	SELECT 
		u.user_name,
		c.course_id,
		c.title AS course_title,
		m.module_title,
		l.score
	FROM progress_logs l
	JOIN modules m ON l.module_id = m.module_id
	JOIN courses c ON m.course_id = c.course_id
	JOIN users u ON l.user_id = u.user_id
)
SELECT
	user_name,
	course_title,
	module_title,
	score,
	(score * 100.0) / SUM(score) OVER () AS percent_of_total_score,
	DENSE_RANK() OVER (
		PARTITION BY course_id
		ORDER BY score DESC
		) AS rank_within_course,
	(score - AVG(score) OVER (PARTITION BY course_id)) /
		NULLIF(STDDEV_POP(score) OVER (PARTITION BY course_id), 0) 
			AS z_score
FROM raw
WHERE score IS NOT NULL
ORDER BY course_title, rank_within_course;
```

#### Output:

| user_name | course_title   | module_title           | score | percent_of_total_score | rank_within_course | z_score                 |
|-----------|----------------|------------------------|-------|------------------------|--------------------|-------------------------|
| O S       | Healthcare     | Human Body             | 95.6  | 11.1149866294616905    | 1                  | NULL                    |
| B J       | Linear Algebra | Linear Transformations | 95.0  | 11.0452272991512615    | 1                  | 1.4515435193000200      |
| O S       | Linear Algebra | Linear Transformations | 90.0  | 10.4638995465643530    | 2                  | 0.82818127174786414924  |
| B J       | Linear Algebra | Linear Transformations | 90.0  | 10.4638995465643530    | 2                  | 0.82818127174786414924  |
| B J       | Linear Algebra | Vector Spaces          | 80.5  | 9.3593768166492268     | 3                  | -0.35620699860123188450 |
| B J       | Linear Algebra | Linear Transformations | 80.0  | 9.3012440413905360     | 4                  | -0.41854322335644746523 |
| B J       | Linear Algebra | Linear Transformations | 78.0  | 9.0687129403557726     | 5                  | -0.66788812237730978812 |
| K H E     | Linear Algebra | Linear Transformations | 70.0  | 8.1385885362167190     | 6                  | -1.6652677184607591     |
| K H E     | Physics        | Newtonian Mechanics    | 91.0  | 10.5801650970817347    | 1                  | 1.00000000000000000000  |
| K H E     | Physics        | Thermodynamics         | 90.0  | 10.4638995465643530    | 2                  | -1.00000000000000000000 |
|||

> **Use Case.** Particularly helpful for comparing performance across different course modules in a fair, normalized way, while also showing how much each score contributes to the global score distribution.

<br>

> ✳️ ***Remark.*** The **z-score** of the first row is `NULL` because:
>
> - Healthcare course *has only 1 entry,*
>
> - so, **standard deviation = 0** (no variation),
>
> - `NULLIF(..., 0)` prevents division by zero by returning `NULL` if the denominator is 0,
>
> - therefore, the z-score becomes ```(anything) / NULL```, which is again `NULL`.

---

