# WireMock Mapping Creation Checklist

Use this checklist when creating WireMock mappings for Smartsheet SDK tests.

## Pre-Creation

- [ ] **OpenAPI spec source identified** - User provided local file path OR using published spec URL
- [ ] **Spec source verified accessible** - File exists (local) or URL reachable (remote)
- [ ] **Endpoint group tag identified** - Determined correct tag name from spec
- [ ] **All endpoints in group discovered** - Used tag-based discovery, not just user-mentioned endpoints
- [ ] **CONTRIBUTING.md reviewed** - Understand project conventions for mappings

## Deprecation Check (CRITICAL)

- [ ] **Deprecation status checked for ALL endpoints in group**
- [ ] **Deprecated endpoints identified** - List any found with deprecation status
- [ ] **Deprecated endpoints excluded from mappings** - No mappings created for deprecated endpoints
- [ ] **Exclusions documented** - If deprecated found, documented why excluded

## Schema Accuracy

- [ ] **Response schemas extracted from OpenAPI spec** - Not guessed or assumed
- [ ] **Property names match spec exactly** - No fictional properties added
- [ ] **Property types match spec** - String, number, boolean, object, array per spec
- [ ] **Required vs optional properties identified** - Parsed from schema definition
- [ ] **All response status codes considered** - 200, 400, 404, etc. from spec

## Mapping Structure

- [ ] **Directory structure correct** - `mappings/{group}/{endpoint-name}/`
- [ ] **File naming follows convention** - `{Group} - {Operation} {Case}.json`
- [ ] **Standard test cases created** - `all-response-body-properties` and `required-response-body-properties` for GET/DELETE
- [ ] **Request matching uses urlPathTemplate** - Not hardcoded IDs
- [ ] **Authorization header matcher included** - `"matches": "Bearer .*"`
- [ ] **x-test-name header unique** - Matches test case path
- [ ] **x-request-id header matcher included** - `"matches": ".*"`

## Verification

- [ ] **No request body matching** - Following CONTRIBUTING.md guidance
- [ ] **No query parameter matching** - Following CONTRIBUTING.md guidance
- [ ] **Response Content-Type header set** - `"application/json"`
- [ ] **Test data realistic** - Based on schema constraints and examples
- [ ] **All HTTP methods covered** - GET, POST, PUT, DELETE as defined in spec

## Final Review

- [ ] **Mappings generated for all non-deprecated endpoints**
- [ ] **Each endpoint has required test cases**
- [ ] **No assumptions or guesswork** - Everything derived from spec
- [ ] **Ready for SDK test execution**
