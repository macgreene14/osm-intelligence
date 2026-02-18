#!/bin/bash
set -e

# Build PMTiles for MT + ID + WA + OR
# Downloads PBFs from Geofabrik, filters trails, merges, builds PMTiles

WORKDIR="/tmp/osm-pnw-build"
OUTDIR="$(dirname "$0")/../public/data"
mkdir -p "$WORKDIR" "$OUTDIR"

STATES=("montana" "idaho" "washington" "oregon")
BASE_URL="https://download.geofabrik.de/north-america/us"

# Trail/recreation tags to keep
TAGS="w/highway=path,track,cycleway,footway,bridleway,steps w/highway=tertiary w/route=hiking,bicycle,mtb w/natural=peak w/tourism=camp_site,viewpoint w/leisure=park,nature_reserve"

echo "=== Downloading state PBFs ==="
for state in "${STATES[@]}"; do
  PBF="$WORKDIR/${state}-latest.osm.pbf"
  if [ ! -f "$PBF" ]; then
    echo "Downloading $state..."
    curl -L -o "$PBF" "${BASE_URL}/${state}-latest.osm.pbf"
  else
    echo "$state already downloaded"
  fi
done

echo "=== Filtering trails from each state ==="
FILTERED_FILES=()
for state in "${STATES[@]}"; do
  PBF="$WORKDIR/${state}-latest.osm.pbf"
  FILTERED="$WORKDIR/${state}-trails.osm.pbf"
  if [ ! -f "$FILTERED" ]; then
    echo "Filtering $state..."
    osmium tags-filter "$PBF" $TAGS -o "$FILTERED" --overwrite
    echo "  $(du -h "$FILTERED" | cut -f1)"
  fi
  FILTERED_FILES+=("$FILTERED")
  # Remove raw PBF to save disk
  rm -f "$PBF"
done

echo "=== Merging all states ==="
MERGED="$WORKDIR/pnw-trails.osm.pbf"
osmium merge "${FILTERED_FILES[@]}" -o "$MERGED" --overwrite
echo "Merged: $(du -h "$MERGED" | cut -f1)"

echo "=== Exporting to GeoJSON ==="
GEOJSON="$WORKDIR/pnw-trails.geojson"
osmium export "$MERGED" -f geojson -o "$GEOJSON" --overwrite
echo "GeoJSON: $(du -h "$GEOJSON" | cut -f1)"

# Clean up merged PBF and filtered files
rm -f "$MERGED"
rm -f "${FILTERED_FILES[@]}"

echo "=== Building PMTiles ==="
tippecanoe \
  -o "$OUTDIR/pnw-trails.pmtiles" \
  --force \
  --name "PNW Trails" \
  --description "Trails & recreation: MT, ID, WA, OR" \
  --layer trails \
  --minimum-zoom 5 \
  --maximum-zoom 14 \
  --drop-densest-as-needed \
  --extend-zooms-if-still-dropping \
  --simplification 10 \
  "$GEOJSON"

echo "PMTiles: $(du -h "$OUTDIR/pnw-trails.pmtiles" | cut -f1)"

# Clean up
rm -f "$GEOJSON"
rm -rf "$WORKDIR"

echo "=== Done! ==="
echo "Output: $OUTDIR/pnw-trails.pmtiles"
