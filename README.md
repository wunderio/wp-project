# Wunder template for WordPress projects

This repository builds a new WordPress project based on the popular [Bedrock boilerplate](https://github.com/roots/bedrock/), configured to automatically deploy code to a [Kubernetes](https://kubernetes.io/) cluster using [CircleCI](https://circleci.com/).

## Prerequisites

You need to have [Composer](https://getcomposer.org/), [jq](https://github.com/jqlang/jq) and [Lando](https://lando.dev/) installed before creating a project.

## Getting started

Create a new project using Composer:

```
$ composer create-project wunderio/wp-project project-name
```

The project automatically clones the latest version of the Bedrock boilerplate and adds Wunder-specific additions to it. The script also asks for some additional information like the wanted local domain name etc. during the creation.
