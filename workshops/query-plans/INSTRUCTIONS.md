# Workshop Instructions: Query Plan Analysis Deep-Dive with Starburst

This document contains the step-by-step instructions needed to complete the [Query Plan Analysis Deep-Dive with Starburst](./README.md) workshop.

## Setup

Follow the [Environment Setup](../ENV-SETUP.md) instructions prior to the next steps.

Create a location privilege pointing to `s3://starburst-tutorials/serverlogs/*` as explained in [Setting S3 location privilege in Starburst Galaxy](https://youtu.be/S437s-VX-bA).

Next, select `aws-us-east-1-free` in the server pulldown menu of the query editor and then copy the content from [seed-tables.sql](./seed-tables.sql) into a query editor tab. As the instructions in this file say, go ahead and execute all of these SQL statements.

Finally, open another query editor tab, select `aws-us-east-1-free` in the server pulldown menu of the query editor, and then copy the content from [activities.sql](./activities.sql) into a query editor tab.


## Follow-along with presenter for hands-on activities

Presenter will land on slides titled "Hands-on" and/or "Demo" along the way and they will perform the activites along with you. They are in order inside the SQL source previously retrieved.

## Teardown

Be sure to follow the [teardown](../ENV-SETUP.md#teardown) instructions.
