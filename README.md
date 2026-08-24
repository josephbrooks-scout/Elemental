# Elemental

## Labcar build-order integration

The [`labcar-build-order/`](./labcar-build-order/) integration retrieves the
Labcar configuration stored in UAT legacy Elemental metadata. It provides the
option-code and vehicle-configuration data needed by the RiDE configuration flow.

### Blueprint creation docs

Blueprint implementation progress, wiring notes, and test readiness artifacts are
tracked in:

- [`labcar-build-order/blueprint-creation/`](./labcar-build-order/blueprint-creation/)

### Contents

- [`labcar-build-order-blueprint.json`](./labcar-build-order/labcar-build-order-blueprint.json):
  importable Elemental Blueprint that reads a Labcar build order.
- [`validate-labcar-build-order.sh`](./labcar-build-order/validate-labcar-build-order.sh):
  read-only end-to-end validation script.

### Blueprint behavior

The Blueprint obtains a VIN from the existing RiDE endpoint and queries:

```text
https://elemental.app-uat.usubv.plant.scoutway.io/elemental/graphql
```

It uses the UAT legacy metadata query:

```graphql
metadata(serialNo: $vin, useCache: false)
```

The relevant fields are:

```text
metadata.optionCodes
metadata.materials
metadata.data.vehicleConfiguration.configuration.buildOrder
metadata.data.vehicleConfiguration.configuration.ecuList
metadata.data.vehicleIdentification
metadata.primaryConfig
```

The primary configuration has an empty build order for the current Labcar test
record. The populated build order used by the recipe is in `metadata.data`.

### Validation

`curl` and `jq` are required. Run:

```bash
./labcar-build-order/validate-labcar-build-order.sh
```

To validate a specific VIN:

```bash
./labcar-build-order/validate-labcar-build-order.sh <VIN>
```

The validator fails when UAT legacy metadata, option codes, or the populated
build order are absent. It reports option-code, material, ECU, and build-order
counts and validates the known `AED` / `30Q` code.

### RiDE task wiring

The `vehicle/set_configuration` request body still must be confirmed before a
task POST can be added. Do not infer that contract from the stored metadata.
The Blueprint provides the complete UAT metadata inputs for the approved recipe
mapping.