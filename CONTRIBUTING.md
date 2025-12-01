# Contributing to Smartsheet SDK Tests

## Did you write a patch that fixes a bug?

- **First, ensure there is a GitHub issue** describing the bug (see above).

- Open a new GitHub pull request with the patch, referencing the issue number.

- Ensure the PR description clearly describes the problem and solution. Include the relevant issue number.

- A maintainer should review your PR within the next few days. If the PR has been dormant for more than a week, consider sending an email to <sdk-python@smartsheet.com>

## Did you fix whitespace, format code, or make a purely cosmetic patch?

Changes that are cosmetic in nature and do not add anything substantial to the stability, functionality, or testability may take longer to review, but are still welcome. Please create an issue first describing the cosmetic changes you'd like to make.

## What are we testing?

It is important to understand what we aim to cover with these Wiremock tests:
* Request body - We want to verify the request body sent to the API is correctly serialized.
* Request path - We want to verify that the request path is correctly generated.
* Request query - We want to verify that the request's query is correctly generated.
* Response body - We want to verify that the response body is correctly deserialized.
* Authorization - We want to verify that the SDK sends the Authorization header.
* Error handling - We want to verify that the SDK handles 4XX and 5XX response codes correctly.

Wiremock tests should not cover:
* Business Logic.
* Response variations due to query parameter values.

## Do you want to create mock mappings for endpoints?

> **_TIP:_**  You can make use of Roo Code or Claude Code to generate Wiremock mappings.
> Example prompt: "Create WireMock mappings for the workspaces API group"

### Using Smartsheet's Public API Documentation

Smartsheet's Public API Documentation should be used to create Wiremock mappings. There are 2 useful resources there:
* A link to a concrete group of APIs (e.g. [Users](https://developers.smartsheet.com/api/smartsheet/openapi/users))
* A link to [download the Open API specification](https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json?download).

> **_NOTE:_**  Always make sure to compare the specification with requests to the API to make sure there are no errors in the documentation.

### Matching Requests

There are several important aspects of matching requests with Wiremock.

#### Test Name

Each mapping must be matched uniquely by Wiremock. To achieve that we use the `x-test-name` HTTP header. This is the name of the test case.
A test name should be named as follows: `/{api-group}/{api-endpoint-name}/{test-case-name}` where:
* `api-group` is the API Group as per the [API Documentation](https://developers.smartsheet.com/api/smartsheet/openapi). Example: [users](https://developers.smartsheet.com/api/smartsheet/openapi/users)

#### Request ID

Each request must be found uniquely by the API client using the Wiremock Admin API. To achieve that we use the `x-request-id` HTTP header. The value should be random UUID.

Finding a request can be done with the following request:

```shell
curl --location 'http://localhost:8082/__admin/requests/find' \
--header 'Content-Type: application/json' \
--data '{
    "headers": {
        "X-Request-Id": {
            "equalTo": "{request-id}"
        }
    }
}'
```

#### Authorization

Each mapping must match the `Authorization` HTTP header. This way we make sure that the SDK being tested actually sends authorization.

#### Path Pattern Matching

Wherever possible [urlPathTemplate](https://wiremock.org/docs/request-matching/#path-templates) should be used to match path.

#### Mapping With Test Name And Request ID

Here is an example mapping with a test name and request id:

```json
{
  "request": {
    "urlPathTemplate": "/2.0/users/{userId}",
    "method": "GET",
    "headers": {
      "Authorization": {
        "matches": "Bearer .*"
      },
      "x-test-name": {
        "equalTo": "/users/get-user/required-response-body-properties"
      },
      "x-request-id": {
        "matches": ".*"
      }
    }
  },
  "response": {
    "statusMessage": "OK",
    "status": 200,
    "jsonBody": {...}
  }
}
```

### Matching request body and query parameters

Wiremock mappings **should not match** request body and query parameters. Request body and query parameter verification is done by the client fetching request details using `x-request-id`.

### Designing Test Cases

Before creating Wiremock mappings one must design the appropriate test cases. There are 2 types of test cases.

#### Common Test Cases

These test cases are common for all endpoints and aim to cover 99% of tests. Here are the common test cases and their names:

| **HTTP Method** | **Test Case Name**                                                 | **Notes**                                                                                                                                               | **Response Code** |
|-----------------|--------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| GET/DELETE      | /{api-group}/{api-endpoint-name}/all-response-body-properties      | Simulate a response that includes all response body properties.<br>Verifies response body serialization.                                                | 2XX               |
| GET/DELETE      | /{api-group}/{api-endpoint-name}/required-response-body-properties | Simulate a response that includes only required response body properties (omitting optional ones).<br>Verifies response body serialization.             | 2XX               |
| POST/PUT/PATCH  | /{api-group}/{api-endpoint-name}/all-response-body-properties      | Simulates a response that includes all response body properties.<br>Verifies request and response body serialization.                                   | 2XX               |
| POST/PUT/PATCH  | /{api-group}/{api-endpoint-name}/required-response-body-properties | Simulate a response that includes only required response body properties (omitting optional ones).<br>Verifies request and response body serialization. | 2XX               |
| ANY             | /{api-group}/{api-endpoint-name}/all-response-body-properties      | Verify if the generated URL path is correct.                                                                                                            | 2XX               |
| ANY             | /{api-group}/{api-endpoint-name}/all-response-body-properties      | Verify if the generated query parameters are correct.                                                                                                   | 2XX               |
| ANY             | /errors/400-response                                               | Verify SDK error handling.                                                                                                                              | 4XX               |
| ANY             | /errors/500-response                                               | Verify SDK error handling.                                                                                                                              | 5XX               |

#### Custom Test Cases

Sometimes custom test cases must be created. Make sure to follow the naming conventions and folder organization rules.

### Organizing Wiremock Mappings

All Wiremock mappings reside in the [mappings](mappings) folder. Each test case is a JSON file created in subfolders using the test case naming conventions.
As a result this is the tree structure:
* [errors](mappings/errors/) - Contains mappings for 4XX and 5XX response codes.
* [{api-group}](mappings/users/) - Contains folders for each endpoint.
  * [{api-endpoint-name}](mappings/users/get-user/) - Contains mappings for the specific endpoint.
* [scenarios](mappings/scenarios/) - Legacy scenarios kept while we migrate all tests to the current approach.
