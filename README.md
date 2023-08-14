# smartsheet-sdk-tests
Mock test suite for all language SDKs

## Requirements
### For Packaging Scenarios
* Node 6.11+

### For Running/Modifying the Mock API Server
* Java 7+

## Overview
This repository provides a number of scripts that can be used to bundle a WireMock server with Smartsheet scenario configuration files. It also contains scripts that can be used by Github Actions to install and run a WireMock server bundle.

## Contents
* [Running the Test Server](#running-the-test-server)
* [Running Tests Locally](#running-tests-locally)
* [Creating Scenarios](#creating-scenarios)
* [Bundling Packages](#bundling-packages)
* [Releasing a Package](#releasing-a-package)
* [Using with GitHub Actions](#using-with-github-actions)

## Running the Test Server
To run the test server, navigate to the `sdk_tests_package` and run the provided launch script:

```bash
$ cd sdk_tests_package
$ ./launch.sh
```

Once the server is running, you can run the mock API tests for your SDK. See the SDK's documentation for more information.

You can check which scenarios are included in the package by referencing the package's [README](https://github.com/smartsheet/smartsheet-sdk-tests/blob/master/sdk_tests_package/README.md). This README includes information on how to run the server as well as descriptions of each scenario.

## Running Tests Locally
To run the tests locally you need to just set up a few scripts that start wiremock and then run the tests.

### Example start wire mock shell script locally.
```bash
#!/usr/bin/env sh
#This is just the install and start wiremock scripts combined. 
set -e
WIREMOCK_PACKAGE="./sdk_tests_package" #or path to sdk_tests_package directory
cp -r "$WIREMOCK_PACKAGE" .
WIREMOCK_PACKAGE_DIR='sdk_tests_package'

# run wiremock
(cd $WIREMOCK_PACKAGE_DIR; ./launch.sh &)

# wait for wiremock to start
sleep 10
```

### Running Tests Locally
```bash
#!/bin/bash

cd ../smartsheet-csharp-sdk/mock-api-test-sdk-net60/
dotnet restore
dotnet build --configuration Release --no-restore
dotnet test --no-restore
```

## Creating Scenarios
Scenarios can either be written by hand following the [scenario spec](#scenario-specification) or by [converting a Postman collections export file](#converting-postman-export-files). In order to use the new scenarios, the scenario file(s) must be added to the `data/scenarios` directory and the package must be rebundled - see [bundling packages](#bundling-packages).

### Scenario Defaults
Some scenario fields are added through the use of defaults. Look at the file `data/stub_defaults.json` to see which fields will be added. Defaults will only be added when the field does not exist in the scenario - they do not override existing values.

### Scenario Specification
Scenario files should have the following structure:

```json
[
  {
    "scenario": "The scenario name",
    "description": "A description of what you are testing. This will only appear in the generated docs.",
    "request": {
      "method": "The HTTP method: GET, POST, DELETE, etc",
      "urlPath": "The relative path of the url: /sheets/1",
      "queryParameters": {
        "some query key": "some query value"
      },
      "headers": {
        "some header key": "some header value"
      },
      "body": {
        "this is the full, expected JSON body.": 123
      }
    },
    "response": {
      "status": 200,
      "statusMessage": "OK",
      "headers": {
        "some header key": "some header value"
      },
      "jsonBody": {
        "this is the JSON body that will be returned.": 123
      }
    }
  }
]
```

Not all fields shown above are required. The minimal required fields are as follows:

```json
[
  {
    "scenario": "The scenario name",
    "request": {
      "method": "The HTTP method: GET, POST, DELETE, etc",
      "urlPath": "The relative path of the url: /sheets/1"
    },
    "response": {
      "status": 200,
      "statusMessage": "OK",
      "jsonBody": {
        "this is the JSON body that will be returned.": 123
      }
    }
  }
]
```



### Converting Postman Export Files
Scenario files can be created from Postman export files, version 2. See [here](https://www.getpostman.com/docs/postman/collections/data_formats) for information on how to export a Postman collection. Scenario files are converted using the `convert_from_postman.js` script:

```bash
$ node convert_from_postman.js --collection=path/to/collection.json --output=my_scenarios.json
```

Once the scenario file has been converted, you should verify that the scenarios look as expected. Make sure every request has a response, no Postman variables appear in the request, and all the data has been sanitized.

## Bundling Packages
Building a package requires the `diff-extension.jar`. By default, the packaging script will use the `jar` included in the bundle. (`sdk_tests_package/libs/diff-extension.jar`) Alternately, you can build the `jar` by following these [build instructions](https://github.com/smartsheet/smartsheet-sdk-tests/blob/master/wiremock/smartsheet-diff-extension/README.md).

To bundle a package, run the following in a bash terminal:

```bash
$ sh package.sh
```

If you built the `jar` yourself, run this command:
```bash
$ sh package.sh wiremock/smartsheet-diff-extension/build/libs/diff-extension-<VERSION>.jar
```

When called successfully, the new package will be created in `sdk_tests_package/` in the current directory. The package will include an auto generated `README.md` describing scenarios available to write SDK tests against. See [running the test server](#running-the-test-server) for information on how to start the new server.

## Releasing a Package
To release a package, commit your newly generated package and merge it into `master`. Once your commit has been merged, all Github Actions (in each SDK repository) will use it for mock API tests. Note that adding a new package will not trigger the Github Actions of the SDKs so it is a good idea to rerun the most recent Test Action for each SDK to verify that the tests pass.

## Using with GitHub Actions
GitHub Actions can use this package to run the Smartsheet WireMock mock API server. This package contains two scripts: an install script and a start script. The install script copies the package into the current directory. The start script starts WireMock in the background and waits for WireMock to warm-up.

### Configuring SDKs to Run the Mock API
Add the following to your SDK's GitHub Action configuration file (`under .github/workflows directory at the root of the repository`) to run the WireMock server:

```yaml
- name: Clone smartsheet/smartsheet-sdk-tests PUBLIC repository
  uses: GuillaumeFalourd/clone-github-repo-action@v2
  with:
    owner: 'smartsheet'
    repository: 'smartsheet-sdk-tests'
- name: Setup mock API
  run: |
    smartsheet-sdk-tests/ci_scripts/install_wiremock.sh
    smartsheet-sdk-tests/ci_scripts/start_wiremock.sh
```