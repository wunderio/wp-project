# Wunder template for WordPress projects

This repository builds a new WordPress project based on the popular [Bedrock boilerplate](https://github.com/roots/bedrock/), configured to automatically deploy code to a [Kubernetes](https://kubernetes.io/) cluster using [CircleCI](https://circleci.com/).

## Prequisites

You need to have [Lando](https://lando.dev/) installed before creating a project.

## Getting started

Just use `lando start` to initialize the project.

The project automatically clones the latest version of the Bedrock boilerplate and adds Wunder-specific additions to it.