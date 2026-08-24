# Validation Checklist (Run When Lineside Is Back)

## Prerequisites

- Lineside is available.
- Access to the RiDE VIN endpoint.
- Access to Elemental UAT GraphQL endpoint.

## Test cases

1. Happy path VIN -> metadata fetch
   - VIN resolves from RiDE endpoint.
   - GraphQL request is formed with expected `query` and `operationName`.
   - Response contains `data.metadata`.
2. Missing VIN path
   - VIN extraction fails or returns empty.
   - `Prompt VIN` is triggered with useful context.
3. GraphQL transport failure
   - POST failure path triggers `Promt POST Elemental`.
   - Error message is surfaced from `error` output.
4. GraphQL success with partial payload
   - `data` present but missing expected nested keys.
   - Extraction nodes emit expected error/signal handling.
5. Data integrity checks
   - Confirm `optionCodes`, `materials`, `buildOrder`, and `ecuList` are available
     in expected branches.

## Validation evidence to capture

- Input VIN used
- Final GraphQL request body
- HTTP status and response payload
- Which signals fired per node (`Success`, `Fail`, `Error`, `Parsed`)
- Final extracted values for downstream mapping
