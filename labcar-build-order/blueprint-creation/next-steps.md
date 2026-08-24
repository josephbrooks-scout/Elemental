# Next Steps

## Primary objective

Bring the current Blueprint to functional parity with the example where required by
the consuming workflow.

## Concrete add-next backlog

1. Add extraction nodes for:
   - `model`
   - `platform`
   - `productBrand`
   - `family_aed`
2. Add prompt nodes for each extracted value:
   - `Prompt model`
   - `Prompt platform`
   - `Prompt productBrand`
   - `Prompt family_aed`
3. Wire success and error paths for each new extraction branch.
4. Confirm naming conventions:
   - Keep current naming (`Build Query`, `Extract Metadata`), or
   - Normalize to example naming (`Concat Query`, `Extract JSON Value (metadata)`).
5. Preserve `Insert operation name JSON` unless a consuming contract explicitly
   requires removing it.

## Exit criteria

- New extraction branches are added and connected.
- No dangling edges.
- All branch outcomes are surfaced through explicit prompt/error wiring.
- End-to-end validation checklist is executed after Lineside recovery.
