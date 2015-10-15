#!/bin/bash

GEO_JSON=$1

# convert table to geojson at first
ogr2ogr -f 'GeoJSON' $GEO_JSON PG:"dbname='playground' host='localhost' port='5432' user='gis' password='gis'" -sql "select osm_id, name, railway, place, highway, way as geometry from planet_osm_point where name is not null"

INDEX=$2
TYPE=$3
MAPPING=$4

# create index
curl -X PUT http://localhost:9200/$INDEX

# mapping
curl -X PUT http://localhost:9200/$INDEX/_mapping/$TYPE --data @$4

# convert to bulk API format
cat $GEO_JSON | jq -c '.features[] | {"index": {"_index": "xian_points", "_type": "point", "_id": .properties.osm_id}}, .'  > exercise_data/xian-points-bulk.json

# feed
curl -XPOST http://localhost:9200/_bulk --data-binary @exercise_data/xian-points-bulk.json