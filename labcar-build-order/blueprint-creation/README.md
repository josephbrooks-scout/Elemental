# Labcar Blueprint Creation

This section documents the ongoing creation of the Labcar Blueprint flow in:

- [`../labcar-build-order-blueprint.json`](../labcar-build-order-blueprint.json)

It is intended to support collaboration while runtime validation is blocked.

## Current implementation status

The current Blueprint flow includes:

1. `GET vin from Ride` to retrieve VIN input.
2. `Extract VIN Value` from the RiDE response payload.
3. `Build Query` to construct the `GetLabcarConfiguration` GraphQL request.
4. JSON body assembly:
   - `Insert key (query) JSON`
   - `Insert operation name JSON`
5. `POST Elemental` to UAT GraphQL.
6. Response parsing chain:
   - `Extract JSON Value (data)`
   - `Extract Metadata`
   - `Extract Configuration Data`
7. Prompt/error nodes:
   - `Prompt VIN`
   - `Promt POST Elemental`

## Current blocker

End-to-end runtime verification is currently blocked because Lineside is down.

## Supporting docs

- [`structure-audit.md`](./structure-audit.md): current node/edge structure and
  parity gap against the provided example blueprint.
- [`next-steps.md`](./next-steps.md): concrete add-next backlog for missing
  extraction branches.
- [`validation-checklist.md`](./validation-checklist.md): runbook to execute once
  Lineside is available again.
