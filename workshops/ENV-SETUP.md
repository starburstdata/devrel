# Workshop Environment Setup (and Teardown)

The hands-on environment used in the [Starburst Workshops](./README.md) series is the Trino-based Starburst Galaxy hosted solution with a writeable Apache Iceberg catalog available. 

## SETUP

This video provides a narrated walkthrough of this setup section with a focus on performing the minimal steps needed for Starburst Workshops.

[![Setup video](http://img.youtube.com/vi/_joJC7bAoak/0.jpg)](http://www.youtube.com/watch?v=_joJC7bAoak)

### Starburst Galaxy

If you do not already have a configured Starburst Galaxy environment, please [sign up](https://www.starburst.io/free-trial/) now. 

The registration process is self-explanatory, but *if needed*, there is a [Starburst Galaxy: Getting started](https://devcenter.starburst.io/tutorials/starburst-galaxy-getting-started) tutorial available. 

**Alternatively**, any [Trino](https://trino.io) environment, including [Starburst Enterprise](https://www.starburst.io/starburst-enterprise/), can be used.

### AWS S3

*For simplicity*, you can use the general instructions described in the [Configure a Starburst Galaxy data lake catalog and schema](https://devcenter.starburst.io/tutorials/configure-a-starburst-galaxy-data-lake-catalog-and-schema) tutorial. The workshop facilitator will provide the S3 bucket and credentials to use. *For on-demand use*, request the S3 connection details from [devrel@starburst.io](mailto:devrel%40starburst.io?subject=need%20S3%20details%20for%20workshops).

**Alternatively**, any Trino catalog configured with the [Iceberg connector](https://trino.io/docs/current/connector/iceberg.html) can be used.

## TEARDOWN

As indentifed in the [Configure a Starburst Galaxy data lake catalog and schema](https://devcenter.starburst.io/tutorials/configure-a-starburst-galaxy-data-lake-catalog-and-schema) tutorial, the S3 data will be removed within 24 hours & the credentials are regularly rotated, so it is highly recommended that you perform the following steps if you are using this configuration.

- Remove the `tmp_cat` catalog from all clusters it is connected to
- Delete the `tmp_cat` catalog from the system

If you need to use this S3 bucket again, repeat the configuration steps and be sure to delete the catalog after use.
