# 🗺️ OSM Intelligence

This project provides an end-to-end framework for extracting trail and geographic features from **OpenStreetMap**, serving them as **vector tiles** via **Tegola**, and enabling **semantic search** and **AI-assisted trail discovery**.

## 📦 What’s Included

- ✅ **Task automation** to:
  - Download `.osm.pbf` files
  - Ingest OSM data into PostgreSQL/PostGIS
- ✅ **Dockerized infrastructure** for:
  - PostgreSQL with PostGIS and `pgvector` for semantic search
  - Tegola vector tile server for high-performance map serving
- ✅ **Data enrichment** with text embeddings to support semantic trail search
- 🧠 **(Coming soon)**: LLM integration (e.g., Vanna.ai) to interpret user queries like:
  - _“Show me an intermediate mountain biking trail with a scenic overlook”_
  - _“I want a short forest walk near the river”_
- 🗺️ A **Mapbox GL / MapLibre frontend** will display results interactively.

---

## 🚀 Quickstart

### 1. Clone the Repository

```bash
git clone https://github.com/your-user/osm-trail-intelligence.git
cd osm-intelligence
```

### 2. Download OSM `.pbf` Region File

Use the Taskfile to download a region from Geofabrik:

```bash
task download-osm
```

_(Default: `montana-latest.osm.pbf` — can be customized in `Taskfile.yml`)_

### 3. Run the Stack

```bash
docker compose up -d
```

This starts:

- `postgres` with PostGIS + pgvector
- `tegola` vector tile server

### 4. Import and ETL OSM Data

```bash
task import-osm
```

This runs `osm2pgsql` to load the `.pbf` file into PostGIS and transforms trails and path data.

---

## 🧬 Semantic Search: Vector Field Augmentation

Once the raw OSM data is loaded:

1. **Trail metadata** is enriched using a combination of OSM tags (e.g., `highway=path`, `surface=dirt`, `sac_scale=mountain_hiking`) to form human-readable descriptions like:

   > _“Steep dirt trail, moderate length, scenic mountain views, foot access only”_

2. Each description is passed through an **embedding model** (e.g., OpenAI `text-embedding-ada-002` or open-source equivalent) to generate a **vector representation** of its semantic meaning.

3. This embedding is stored in a `vector(768)` column using the [`pgvector`](https://github.com/pgvector/pgvector) extension.

4. **Similarity search** is now possible:

   ```sql
   SELECT * FROM trails
   ORDER BY embedding <-> '[user_embedding]'
   LIMIT 10;
   ```

---

## 🧠 Future Direction: AI Trail Discovery

We plan to integrate a **natural language interface** using [Vanna.ai](https://vanna.ai/) or similar LLMs. This will allow users to:

- Search trails by typing freeform prompts
- Ask for specific terrain, elevation, duration, or skill level
- Discover places to visit based on vague or subjective criteria
- Get results highlighted live in Mapbox/MapLibre

---

## 🧱 Dependencies

- [taskfile] (https://taskfile.dev/installation/)
- [osm2pgsql](https://osm2pgsql.org/)
- [Tegola](https://tegola.io/)
- [PostGIS](https://postgis.net/)
- [pgvector](https://github.com/pgvector/pgvector)
- [Mapbox GL JS](https://docs.mapbox.com/mapbox-gl-js/) or [MapLibre](https://maplibre.org/)
- [OpenAI](https://platform.openai.com/) or local embedding model

---

## 📜 License

MIT — see `LICENSE`.

---

## 💡 Credits

Inspired by the power of open data, open tools, and curiosity-driven exploration of the outdoors.
