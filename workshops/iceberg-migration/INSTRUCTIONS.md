# Workshop Instructions: Migrating to Apache Iceberg from Hive, Step-by-Step

This document contains the step-by-step instructions needed to complete the [Migrating to Apache Iceberg from Hive, Step-by-Step](./README.md) workshop.

## Setup

Follow the [Environment Setup](../ENV-SETUP.md) instructions prior to the next steps.

After those env instructions are completed, select `aws-us-east-1-free` in the server pulldown menu of the query editor before running the following to create and use a new schema in the `tmp_cat` catalog.

```sql
CREATE SCHEMA tmp_cat.hive2ice;
USE tmp_cat.hive2ice;
```

![Create schema](https://github.com/starburstdata/devrel/raw/master/workshops/iceberg-migration/schema-setup.png "Create schema")

Copy the content from [activities.sql](./activities.sql) into a query editor tab.

## Follow-along with presenter for hands-on activities

Presenter will land on slides titled "Hands-on" and/or "Demo" along the way and they will perform the activites along with you. They are in order inside the SQL source previously retrieved.

## Teardown

Be sure to follow the [teardown](../ENV-SETUP.md#teardown) instructions.
