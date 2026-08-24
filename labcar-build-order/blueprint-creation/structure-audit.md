# Structure Audit

## Current blueprint snapshot

- Source: [`../labcar-build-order-blueprint.json`](../labcar-build-order-blueprint.json)
- Node count: 12
- Edge count: 22
- Entry node count: 1 (`Start`)
- Dangling edges: 0
- Terminal nodes:
  - `Prompt VIN`
  - `Promt POST Elemental`
  - `Extract Configuration Data`

## Comparison to provided example

- Example source: `/Users/joseph.brooks/Downloads/blueprint_example.json`
- Example node count: 20
- Example edge count: 38

### Missing (in current vs example)

- `Extract model Value`
- `Extract platform Value`
- `Extract productBrand Value`
- `Extract family_aed Value`
- `Prompt model`
- `Prompt platform`
- `Prompt productBrand`
- `Prompt family_aed`

### Present in current (not in example)

- `Build Query`
- `Insert operation name JSON`
- `Extract Metadata`
- `Extract Configuration Data`

## Interpretation

The current blueprint has a valid base pipeline (VIN -> query -> GraphQL -> parse)
and is ready for expansion branches once runtime verification can resume.
