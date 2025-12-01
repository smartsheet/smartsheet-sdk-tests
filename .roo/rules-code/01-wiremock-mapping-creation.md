## WireMock Mapping Creation

### Purpose

When creating WireMock mappings for Smartsheet SDK Tests, the Spec mode must generate comprehensive test case specifications based on Smartsheet's Public API Documentation and the project's testing guidelines.

### Required Input Documents

**User Must Provide**:
- The endpoints or group of endpoints for which mappings need to be created (e.g. the /users group).

### Additional Reference Sources

- [`CONTRIBUTING.md`](../../../CONTRIBUTING.md) - Guidance for creating wiremock mappings.
- [OpenAPI Specification](https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json) - Create mappings based on the Open API specification.

### Discovering Endpoints by Group

Endpoints in a group can be discovered by looking for the corresponding tag in the OpenAPI specification. Each endpoint group has an associated tag that identifies all endpoints belonging to that group.

**Example**: The Users group has a tag `"users"` in the OpenAPI spec.

**How to Find Endpoints by Tag**:

1. **List all endpoints with a specific tag** (e.g., "users"):
```bash
curl -s "https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json" | \
  jq '.paths | to_entries | map(select(.value | to_entries[] | select(.key != "parameters") | .value.tags[]? == "users")) | map(.key)'
```

2. **Get detailed information for endpoints with a specific tag**:
```bash
curl -s "https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json" | \
  jq '.paths | to_entries | map(select(.value | to_entries[] | select(.key != "parameters") | .value.tags[]? == "users")) | map({path: .key, methods: (.value | to_entries | map(select(.key != "parameters") | .key))})'
```

3. **List all available tags in the OpenAPI spec**:
```bash
curl -s "https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json" | \
  jq '.tags[] | .name'
```

**Common Tag-to-Group Mappings**:
- `"users"` → Users group
- `"webhooks"` → Webhooks group
- `"sharing"` → Sharing group
- `"workspaces"` → Workspaces group
- `"sheets"` → Sheets group

When starting work on a new endpoint group, always verify the tag name and use it to discover all endpoints that should be included in the specification.

### Deprecated Endpoint Exclusion

**CRITICAL RULE**: Mappings for deprecated endpoints MUST NOT be created.

When reviewing the API documentation and OpenAPI specification:
- **Identify deprecated endpoints** - Check for deprecation notices in the API documentation or `deprecated: true` in the OpenAPI spec
- **Exclude from specifications** - Do not include deprecated endpoints in test case specifications
- **Document exclusions** - If deprecated endpoints are found in the provided API group, explicitly note them in the specification with a reason for exclusion
- **Focus on current API** - Only create test cases for actively supported, non-deprecated endpoints

**Example Exclusion Note**:
```markdown
## Excluded Endpoints

The following endpoints were excluded from this specification because they are deprecated:

- `GET /2.0/legacy/endpoint` - Deprecated as of API v2.1, replaced by `/2.0/new/endpoint`
- `POST /2.0/old/resource` - Deprecated, no longer supported
```

### Deprecated Endpoint Identification

> **Note:** Replace workspaces with the endpoint group you are working on.

1. List All Workspace Endpoints with Deprecation Status
curl -s "https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json" | \
  jq '.paths | to_entries | map(select(.key | startswith("/workspaces"))) |
  map({path: .key, methods: (.value | to_entries |
  map(select(.key != "parameters") | {method: .key, deprecated: (.value.deprecated // false)}))})'

2. List Only Deprecated Workspace Endpoints
curl -s "https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json" | \
  jq '.paths | to_entries | map(select(.key | startswith("/workspaces"))) |
  map({path: .key, methods: (.value | to_entries |
  map(select(.key != "parameters") | {method: .key, deprecated: .value.deprecated}) |
  map(select(.deprecated == true)))}) | map(select(.methods | length > 0))'

3. Check Specific Endpoint Deprecation
curl -s "https://developers.smartsheet.com/_spec/api/smartsheet/openapi.json" | \
  jq '.paths["/workspaces/{workspaceId}"].get.deprecated'
