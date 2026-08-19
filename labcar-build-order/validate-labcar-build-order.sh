#!/usr/bin/env bash
set -euo pipefail

readonly endpoint='https://elemental.app.usubv.plant.scoutway.io/elemental/graphql'
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
  operationName: "GetLabcarBuildOrder",
  query: "query GetLabcarBuildOrder($vin: String!) { metadataPage(serialNoContains: $vin, limit: 1, offset: 0) { records { serialNo vehicleId optionCodes data model modelYear } limit offset } }",
  variables: {vin: $vin}
}')"

response="$(curl -fsS -X POST "$endpoint" \
  -H 'Content-Type: application/json' \
  --data "$request")"

if jq -e '.errors | length > 0' >/dev/null <<<"$response"; then
  jq '.errors' <<<"$response" >&2
  exit 1
fi

record_count="$(jq '[.data.metadataPage.records[] | select(.serialNo == $vin)] | length' \
  --arg vin "$vin" <<<"$response")"

if [[ "$record_count" != '1' ]]; then
  printf 'Expected one build-order record for VIN %s; found %s.\n' "$vin" "$record_count" >&2
  exit 1
fi

record="$(jq '.data.metadataPage.records[] | select(.serialNo == $vin)' \
  --arg vin "$vin" <<<"$response")"

if ! jq -e '.data.data[0].orderData.prNumbers | type == "array" and length > 0' \
  >/dev/null <<<"$record"; then
  printf 'The build-order record does not contain orderData.prNumbers.\n' >&2
  exit 1
fi

if ! jq -e '.optionCodes | type == "array" and length > 0' >/dev/null <<<"$record"; then
  printf 'The build-order record does not contain optionCodes.\n' >&2
  exit 1
fi

jq '{
  serialNo,
  vehicleId,
  model,
  modelYear,
  optionCodeCount: (.optionCodes | length),
  prNumberCount: (.data.data[0].orderData.prNumbers | length),
  hasAed30Q: ([.data.data[0].orderData.prNumbers[] | select(.family == "AED" and .number == "30Q")] | length == 1),
  optionCodes,
  prNumbers: .data.data[0].orderData.prNumbers
}' <<<"$record"
