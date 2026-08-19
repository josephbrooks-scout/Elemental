# Elemental

## Labcar build-order integration

The [`labcar-build-order/`](./labcar-build-order/) integration stores and retrieves
complete Labcar build orders in Elemental's `MetadataNew` model. It provides the
option-code data required to build a RiDE `vehicle/set_configuration` request.

### Contents

- [`labcar-build-order-blueprint.json`](./labcar-build-order/labcar-build-order-blueprint.json):
  importable Elemental Blueprint that reads a Labcar build order.
- [`validate-labcar-build-order.sh`](./labcar-build-order/validate-labcar-build-order.sh):
  read-only end-to-end validation script.

### Blueprint behavior

The Blueprint obtains a VIN from the existing RiDE endpoint and queries:

```text
https://elemental.app.usubv.plant.scoutway.io/elemental/graphql
```

It uses the `metadataPage` query because Labcar build orders written by
`upsertMetadata` are `MetadataNew` records. The legacy
`metadata(serialNo: ...)` query reads another model and does not retrieve these
records.

The final Blueprint result is a one-record array at:

```text
data.metadataPage.records
```

After checking that the sole record's `serialNo` exactly matches the requested
VIN, consume either:

```text
records[0].optionCodes
records[0].data.data[0].orderData.prNumbers
```

`optionCodes` contains task-ready strings such as `AED30Q`; `prNumbers`
preserves the original `{ family, number }` build-order representation.

### Validation

`curl` and `jq` are required. Run:

```bash
./labcar-build-order/validate-labcar-build-order.sh
```

To validate a specific VIN:

```bash
./labcar-build-order/validate-labcar-build-order.sh <VIN>
```

The validator fails when it cannot find exactly one record matching the VIN, or
when the record lacks option codes or PR numbers. It also reports the count of
each and validates the known `AED` / `30Q` option for the current test vehicle.

### RiDE task wiring

The `vehicle/set_configuration` request contract was not included in this
repository. Do not send an inferred payload to a vehicle. Once the accepted
parameter schema is confirmed, connect a node after the Blueprint's final Calc
node that verifies the exact VIN, maps the documented option-code shape, posts
to `/api/v1/tasks/vehicle/set_configuration`, and surfaces failures.