# Backend API Contracts

**Version:** 1.0
**Status:** Draft
**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD

---

## Service Name

Brief description of this service's responsibilities.

### Endpoint: METHOD /path

**Description:** What this endpoint does

**Authentication:** Yes/No
**Authorization:** Required roles/permissions (if any)

**Request:**

```json
{
  "field1": "type (constraints)",
  "field2": "type (constraints)"
}
```

**Response 200 OK:**

```json
{
  "field1": "type",
  "field2": "type"
}
```

**Response 400 Bad Request:**

```json
{
  "error": "Error message",
  "details": [
    {"field": "field1", "message": "Validation error"}
  ]
}
```

**Response 401 Unauthorized:**

```json
{
  "error": "Invalid or missing authentication"
}
```

**Response 404 Not Found:**

```json
{
  "error": "Resource not found"
}
```

**Validations:**
- Field1: description of validation rules
- Field2: description of validation rules

**Rate Limiting:**
- X requests per minute/hour

**Derived from:**
- Screen: screen-id (version)
- Component: ComponentName
- Annotation: UI-XXX (ButtonName)

---

## Data Models

### ModelName

```json
{
  "id": "UUID",
  "field1": "type",
  "field2": "type",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

**Description:** What this model represents

**Validation Rules:**
- Field1: validation rules
- Field2: validation rules

---

## Error Codes

| Code | Description | When it occurs |
|------|-------------|----------------|
| 400 | Bad Request | Invalid input validation |
| 401 | Unauthorized | Missing/invalid auth token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource |
| 422 | Unprocessable Entity | Business logic error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

---

## Notes

Additional implementation notes, assumptions, or open questions.
