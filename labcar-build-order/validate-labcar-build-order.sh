#!/usr/bin/env bash
set -euo pipefail

readonly endpoint='https://elemental.app-uat.usubv.plant.scoutway.io/elemental/graphql'
readonly vin="${1:-7WARME221YY000001}"

command -v curl >/dev/null || {
  printf '%s\n' 'curl is required.' >&2
  exit 1
}
command -v jq >/dev/null || {
  printf '%s\n' 'jq is required.' >&2
  exit 1
}

request="$(jq -n --arg vin "$vin" '{
  operationName: "GetLabcarConfiguration",
  query: "query GetLabcarConfiguration($vin: String!) { metadata(serialNo: $vin, useCache: false) { serialNo optionCodes materials { bomItemName hardwareId partId } data primaryConfig { payload { vehicleConfiguration { configuration { buildOrder ecuList metadata { entity brand vehiclePlatform vehicleType verwendungszweck } } signature checksum } vehicleIdentification { brand carId homologationRegion model modelYear tenant vin } } } } }",
  variables: {vin: $vin}
}')"

response="$(curl -fsS -X POST "$endpoint" \
  -H 'Content-Type: application/json' \
  --data "$request")"

if jq -e '.errors | length > 0' >/dev/null <<<"$response"; then
  jq '.errors' <<<"$response" >&2
  exit 1
fi

record="$(jq '.data.metadata' <<<"$response")"

if ! jq -e --arg vin "$vin" '.serialNo == $vin' >/dev/null <<<"$record"; then
  printf 'No legacy metadata record found for VIN %s.\n' "$vin" >&2
  exit 1
fi

if ! jq -e '.data.vehicleConfiguration.configuration.buildOrder | type == "object" and length > 0' \
  >/dev/null <<<"$record"; then
  printf 'The metadata record does not contain a build order.\n' >&2
  exit 1
fi

if ! jq -e '.optionCodes | type == "array" and length > 0' >/dev/null <<<"$record"; then
  printf 'The build-order record does not contain optionCodes.\n' >&2
  exit 1
fi

jq '{
  serialNo,
  optionCodeCount: (.optionCodes | length),
  materialCount: (.materials | length),
  buildOrderFamilyCount: (.data.vehicleConfiguration.configuration.buildOrder | length),
  ecuCount: (.data.vehicleConfiguration.configuration.ecuList | length),
  hasAed30Q: (.data.vehicleConfiguration.configuration.buildOrder.AED == "30Q"),
  storedSnr: .data.vehicleConfiguration.configuration.buildOrder.SNR,
  vehicleIdentification: .data.vehicleIdentification,
  optionCodes,
  buildOrder: .data.vehicleConfiguration.configuration.buildOrder
}' <<<"$record"
