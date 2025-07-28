# SkillMark SQL Portfolio

**SkillMark** is a structured SQL analytics showcase built on PostgreSQL 9.5+.
It demonstrates advanced querying, relational thinking, and analytics. 

It assumes a hypothetical scenario in which a number of students are enrolled in a number of courses, each course consisting of some modules. The uers, courses, modules, and progress logs are registered in four corresponding tables according to the following ERD:

<p align="center">
    <img src="/schema/ERD.svg" alt="SkillMark ERD" width="600"/>
</p>

Based on the above, then, the **SkillMark Query Matrix** is built as a single markdown file. This matrix organized across ***three conceptual tiers,*** from basic aggregation to full analytical pipelines using **window functions:**

- Tier 1. Basic Aggregates (Using `GROUP BY`)

- Tier 2. Join + Grouping

- Tier 3. Window Functions


## Purpose

This project serves as a **SQL mastery log** and a **portfolio-ready demonstration** of:

- relational data modeling
- aggregates and grouping
- multi-table joins
- window functions
- query design patterns for analytics
- ranking, moving averages, and score normalization

All queries are run against a mock **SkillMark Learning Management System** schema.

## Project Structure

<pre>
    <code>
        📁 SkillMark-Pg
        ├── 📄 LICENSE
        ├── 📄 .gitignore
        ├── 📄 README.md
        |
        ├── 📁 schema
        |   ├── 📄 ERD.svg
        |   └── 📄 table_maker.sql
        |
        ├── 📁 data
        |   └── 📄 mock_data_inserter.sql
        |
        └── 📁 queries
            └── 📄 skillmark_query_matrix.md
    </code>
</pre>

## Database Schema Overview

- `users`: Learners in the system

- `courses`: Courses such as *Linear Algebra,* etc.

- `modules`:  individual learning modules within courses

- `progress_logs`: User attempts, scores, and time logs

### Relational Design:

     ⋄ Each module belongs to a course.

     ⋄ Each progress log links a user to a module.

     ⋄ `score` and `time_spent` are tracked per attempt.

## Triple-Tiered Query Matrix

The `skillmark_query_matrix.md` file is organized by analytical depth:

|Tier|Focus|Examples|
|---|---|---|
|Tier 1|Aggregates & `GROUP BY`|`AVG`, `COUNT`, `SUM`|
|Tier 2|Joins + Aggregation|`JOIN` + `COUNT DISTINCT`, percent share|
|Tier 3|Window Functions + Aggregation| `RANK`, `LAG`, moving avg, z-score|

Each query:
- is tagged (`T1-01`, `T2-03-E-3`, etc.),

- includes SQL, markdown tables of results, and explanantion.

In addition, for construction of more complex qeuries, **subqueries** are introduced in Tier 2, and **CTEs (Common Table Expressions)** in Tier 3.

## Usage

To recreate and run this locally:

1. Install PostgreSQL 9.5+

2. Create a new database `SkillMark`

3. Run `table_maker.sql` (via `pgAdmin 4` GUI or from terminal) to create the schema

4. Run `mock_data_inserter.sql` to generate mock data

5. Run the queries and verify the results

## Why This Project?

Many SQL portfolios show individual queries in isolation. **SkillMark** goes further by:

- emphasizing ***tiered learning*** and ***conceptual mastery***

- integrating analytics into a ***cohesive query system***

- demonstrating ***clean documentation and result presentation***

- positioning SQL as a ***thinking tool***, not just a syntax

<br>

> ✳️  *Built for analysts, data scientists, and interviewers who care about clarity, rigor, and reproducibility.*


## License

MIT

## Support Me

Accomplishing useful, neat, and well-documented projects takes *lots* of effort and time. If you like what I do, please support me with your coins:

|Coin|Wallet Address|
|---|---|
|BTC|<code> 1D6jv2nMYNgMWXpv9CdGwkjZckSgviPbtp </code>|
|ETH|<code> 0x4f11e34e15325191f7784587e5a7c72b36ce473a </code>|
|XRP|<code> rL7SSjQs8jyFRtDQWmZozYTqdQ6qrQju5f </code>|
|SOL|<code> HEcchG6xJqr9K1JMJiE9brVNpQv1Y1DxAyyFYqP9sn4R </code>|
|TRX|<code> TLjPhCxokkkM3eymvdVauoQb6oCDf29v1n </code>|
|TON|<code> UQBVNDE0wmJMvMd5GL_M8Ot0dnSTQ228QB4dzEcGItMyMRW- </code>|
|PAXG (ETH)|<code> 0x4f11e34e15325191f7784587e5a7c72b36ce473a </code>|
|||

Thanks.

## Contact

If you'd like to collaborate, suggest improvements, or ask about design philosophy, feel free to reach out! 