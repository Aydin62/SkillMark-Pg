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

|File|Discription|
|---|---|
|