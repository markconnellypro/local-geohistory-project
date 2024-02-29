<?php

namespace App\Models;

use CodeIgniter\Model;

class GovernmentShapeModel extends Model
{
    // extra.ci_model_map_tile(v_state character varying, v_z integer, v_x integer, v_y integer)
    
    // FUNCTION: extra.governmentabbreviation
    // FUNCTION: extra.governmentcurrentleadstateid
    // FUNCTION: extra.governmentshort
    // VIEW: extra.giscountycache
    // VIEW: extra.gismunicipalitycache
    // VIEW: extra.gissubmunicipalitycache

    public function getTile($state, $z, $x, $y)
    {
        $query = <<<QUERY
            WITH mvtgeometrycounty AS (
                SELECT ST_AsMVTGeom(ST_Transform(giscountycache.geometry, 3857), ST_TileEnvelope(?, ?, ?), extent => 4096, buffer => 64) AS geometry,
                giscountycache.government AS name,
                extra.governmentshort(giscountycache.government) AS description
                FROM extra.giscountycache
                WHERE giscountycache.geometry && ST_Transform(ST_TileEnvelope(?, ?, ?, margin => (64.0 / 4096)), 4326)
                AND extra.governmentabbreviation(extra.governmentcurrentleadstateid(giscountycache.government)) = ?
            ),
            mvtgeometrymunicipality AS (
                SELECT ST_AsMVTGeom(ST_Transform(gismunicipalitycache.geometry, 3857), ST_TileEnvelope(?, ?, ?), extent => 4096, buffer => 64) AS geometry,
                gismunicipalitycache.government AS name,
                extra.governmentshort(gismunicipalitycache.government) AS description
                FROM extra.gismunicipalitycache
                WHERE ? >= 6 
                AND gismunicipalitycache.geometry && ST_Transform(ST_TileEnvelope(?, ?, ?, margin => (64.0 / 4096)), 4326)
                AND extra.governmentabbreviation(extra.governmentcurrentleadstateid(gismunicipalitycache.government)) = ?
            ),
            mvtgeometrysubmunicipality AS (
                SELECT ST_AsMVTGeom(ST_Transform(gissubmunicipalitycache.geometry, 3857), ST_TileEnvelope(?, ?, ?), extent => 4096, buffer => 64) AS geometry,
                gissubmunicipalitycache.government AS name,
                extra.governmentshort(gissubmunicipalitycache.government) AS description
                FROM extra.gissubmunicipalitycache
                WHERE ? >= 6 
                AND gissubmunicipalitycache.geometry && ST_Transform(ST_TileEnvelope(?, ?, ?, margin => (64.0 / 4096)), 4326)
                AND extra.governmentabbreviation(extra.governmentcurrentleadstateid(gissubmunicipalitycache.government)) = ?
            )
            SELECT ST_AsMVT(mvtgeometrycounty.*, 'county') AS mvt
            FROM mvtgeometrycounty
            UNION
            SELECT ST_AsMVT(mvtgeometrymunicipality.*, 'municipality') AS mvt
            FROM mvtgeometrymunicipality
            UNION
            SELECT ST_AsMVT(mvtgeometrysubmunicipality.*, 'submunicipality') AS mvt
            FROM mvtgeometrysubmunicipality;
        QUERY;

        $query = $this->db->query($query, [
            $z,
            $x,
            $y,
            $z,
            $x,
            $y,
            strtoupper($state),
            $z,
            $x,
            $y,
            $z,
            $z,
            $x,
            $y,
            strtoupper($state),
            $z,
            $x,
            $y,
            $z,
            $z,
            $x,
            $y,
            strtoupper($state),
        ])->getResult();

        return $query ?? [];
    }
}