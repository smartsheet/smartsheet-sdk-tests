# Agent Documentation

## Project Overview

This repository provides a standalone WireMock server for contract testing Smartsheet SDKs. It validates SDK behavior against consistent mock API responses without relying on the live API. As an AI agent, you'll primarily create and review WireMock mapping files that simulate Smartsheet API endpoints.

## Quick Links

- **[README.md](README.md)** - How to run WireMock, project setup, basic concepts
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Full contribution guidelines, what we test, designing test cases, mapping creation details
- **[mappings/](mappings/)** - All WireMock mapping files organized by API group

## Available Skills

### `create-wiremock-mappings`
**When to use:** Creating new WireMock mappings for Smartsheet API endpoints
- User asks to create mappings for an API group
- User provides OpenAPI specs to generate tests from
- User requests test coverage for new endpoints

### `review-wiremock-mappings`
**When to use:** Reviewing WireMock mapping files for quality and correctness
- Code review requests for mapping PRs
- Verification before merge
- Quality checks on WireMock submissions

## Key Repository Structure

### Directory Organization
- `mappings/{api-group}/{api-endpoint-name}/` - Mapping files organized by API group and endpoint
- `mappings/errors/` - Common error response mappings (4XX, 5XX)
- `mappings/scenarios/` - Legacy scenarios (being migrated)

### Test Naming Convention
Format: `/{api-group}/{api-endpoint-name}/{test-case-name}`

Example: `/users/get-user/required-response-body-properties`

### Required Headers
Every mapping must include:
- **`x-test-name`** - Unique identifier for mapping matching (format: `/{api-group}/{api-endpoint-name}/{test-case-name}`)
- **`x-request-id`** - UUID for request tracing via WireMock Admin API
- **`Authorization`** - Pattern match to verify SDK sends auth (e.g., `"matches": "Bearer .*"`)

### Path Matching
Use `urlPathTemplate` wherever possible for path matching:
```json
"urlPathTemplate": "/2.0/users/{userId}"
```

## Common Workflows

### Creating New Mappings
1. Invoke `create-wiremock-mappings` skill
2. Follow CONTRIBUTING.md conventions for:
   - Test case naming
   - Directory structure
   - Required/optional response properties
   - Common test cases (all-properties, required-properties, errors)

### Reviewing Mappings
1. Invoke `review-wiremock-mappings` skill
2. Verify:
   - Correct directory structure
   - Proper test naming format
   - Required headers present
   - No request body/query param matching (verification done via Admin API)
   - Response bodies match OpenAPI spec

## Important Notes

- **Do not match request body or query parameters** in mappings - verification is done by fetching request details via `x-request-id`
- **Common test cases** cover 99% of scenarios - see CONTRIBUTING.md for the full table
- **Authorization header** must always be matched to ensure SDKs send credentials
- **Response variations** should test both all-properties and required-properties-only cases
