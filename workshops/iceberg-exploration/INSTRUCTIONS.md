# Workshop Instructions: Hands‑On with Apache Iceberg: Build, Evolve, Operate

This document contains the step-by-step instructions needed to complete the [Hands‑On with Apache Iceberg: Build, Evolve, Operate](./README.md) workshop.

## Setup

This workshop uses [Starburst Galaxy](https://www.starburst.io/starburst-galaxy/) for compute and AWS S3 for storage.

### Starburst Galaxy

If you do not already have a configured Starburst Galaxy environment, please [sign up](https://www.starburst.io/free-trial/) now. 

The registration process is self-explanatory, but *if needed*, there is a [Starburst Galaxy: Getting started](https://devcenter.starburst.io/tutorials/starburst-galaxy-getting-started) tutorial available. 

**Alternatively**, any [Trino](https://trino.io) environment, including [Starburst Enterprise](https://www.starburst.io/starburst-enterprise/), can be used.

### AWS S3

*For simplicity*, you can use the S3 bucket and credentials described in the [Configure a Starburst Galaxy data lake catalog and schema](https://devcenter.starburst.io/tutorials/configure-a-starburst-galaxy-data-lake-catalog-and-schema) tutorial.

**Alternatively**, any Trino catalog configured with the [Iceberg connector](https://trino.io/docs/current/connector/iceberg.html) can be used.

## [Create and populate Apache Iceberg tables](https://devcenter.starburst.io/tutorials/create-and-populate-apache-iceberg-tables)

For this step, follow the instructions in the tutorial linked above.

## [Explore data modifications, snapshots, and time travel with Apache Iceberg](https://devcenter.starburst.io/tutorials/explore-data-modifications-snapshots-and-time-travel-with-apache-iceberg)

For this step, follow the instructions in the tutorial linked above.

## [Explore advanced features of Apache Iceberg](https://devcenter.starburst.io/tutorials/explore-advanced-features-of-apache-iceberg)

For this step, follow the instructions in the tutorial linked above.

## BONUS STEP: [Exploring Iceberg v3 with Starburst](https://lestermartin.dev/tutorials/trino-iceberg-v3)

If time, energy, and interest are present, follow the tutorial link above for this optional step of this workshop. 

## Teardown

As indentifed in the [Configure a Starburst Galaxy data lake catalog and schema](https://devcenter.starburst.io/tutorials/configure-a-starburst-galaxy-data-lake-catalog-and-schema) tutorial, the S3 data will be removed within 24 hours & the credentials are regularly rotated, so it is highly recommended that you perform the following steps if you are using this configuration.

- Remove the `tmp_cat` catalog from all clusters it is connected to
- Delete the `tmp_cat` catalog from the system

If you need to use this S3 bucket again, repeat the configuration steps and be sure to delete the catalog after use.
