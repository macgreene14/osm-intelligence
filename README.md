# OSM Intelligence

Interactive trail map for Montana built with OpenStreetMap data, served as static vector tiles.

**🗺️ Live:** [macgreene14.github.io/osm-intelligence](https://macgreene14.github.io/osm-intelligence/)

![MapLibre](https://img.shields.io/badge/MapLibre_GL-4.1-blue) ![PMTiles](https://img.shields.io/badge/PMTiles-3.0-green) ![License](https://img.shields.io/badge/license-MIT-gray)

## Features

- **Static vector tiles** — PMTiles served from GitHub, no tile server needed
- **Color-coded trails** — path, track, cycleway, footway, bridleway
- **4 base maps** — Dark, Topo, Satellite (Esri), Light
- **3D terrain** — AWS elevation tiles with 1.5x exaggeration
- **Click popups** — trail name, type, surface
- **Labels** — along-line trail names at zoom 12+
- **Zero API keys** — all tile sources are free and open

## Data Pipeline

```
Montana PBF (92MB)
  → osmium tags-filter (18MB) — trails & recreation features only
  → osmium export → GeoJSON (94MB)
  → tippecanoe → PMTiles (61MB) — zoom 5–14, drop-densest-as-needed
  → GitHub Release → served via HTTP range requests
```

### Filtered OSM Tags

- **highway:** path, track, bridleway, cycleway, footway
- **route:** hiking, foot, bicycle, mtb, ski

## Stack

- [MapLibre GL JS](https://maplibre.org/) — map rendering
- [PMTiles](https://protomaps.com/docs/pmtiles) — static vector tile format
- [tippecanoe](https://github.com/felt/tippecanoe) — tile generation
- [osmium](https://osmcode.org/osmium-tool/) — PBF filtering & export
- [CARTO](https://carto.com/basemaps/) / [OpenTopoMap](https://opentopomap.org/) / [Esri](https://www.esri.com/) — base map tiles
- [AWS Terrain Tiles](https://registry.opendata.aws/terrain-tiles/) — elevation DEM

## Local Development

```bash
# Serve locally (any static server)
python3 -m http.server 8000
# open http://localhost:8000
```

For local development, the PMTiles file needs to be in the root directory. Download from [Releases](https://github.com/macgreene14/osm-intelligence/releases).

## Regenerating Tiles

```bash
# Install tools
brew install tippecanoe osmium-tool

# Filter PBF for trails
osmium tags-filter data/montana-latest.osm.pbf \
  w/highway=path,track,bridleway,cycleway,footway \
  r/route=hiking,foot,bicycle,mtb,ski \
  -o data/montana-trails.osm.pbf

# Export to GeoJSON
osmium export data/montana-trails.osm.pbf -o data/montana-trails.geojson

# Generate PMTiles
tippecanoe -o data/montana-trails.pmtiles --force \
  --name="Montana Trails" --layer=trails \
  -z14 -Z5 --drop-densest-as-needed \
  data/montana-trails.geojson
```

## Deployment

GitHub Actions downloads the PMTiles from the release, bundles it with `index.html`, and deploys to GitHub Pages. No build step, no dependencies.
