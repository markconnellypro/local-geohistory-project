<?php
$attribution ??= '';
$color ??= 'ffffff';
$element ??= '';
$fillOpacity ??= 0.5;
$onEachFeature ??= true;
$onEachFeature2 ??= false;
$query ??= [];
$weight ??= 1;
?>
var <?= $element ?>data = {
	"type": "FeatureCollection",
	"features": [
	<?php $i = 0;
if (is_array($query) && $query !== []) {
    foreach ($query as $row) {
        if ($element === 'line') {
            $geometry = $row->linegeometry;
            unset($row->linegeometry);
            $row = [
                'type' => 'Line',
                'line' => $row->line,
                'description' => $row->linedescription,
            ];
        } elseif ($element === 'point') {
            $geometry = $row->pointgeometry;
            $row = [
                'type' => 'Point',
                'line' => $row->line,
                'description' => $row->pointdescription,
            ];
        } elseif (isset($row->geometry) && (is_null($row->geometry) || $row->geometry === '')) {
            $geometry = null;
        } else {
            $geometry = $row->geometry ?? null;
        }
        if (is_null($geometry)) {
            continue;
        }
        unset($row->geometry);
        if (isset($row->eventjson)) {
            $eventJson = $row->eventjson;
            $row->eventjson = 'REPLACE_EVENT_JSON';
        } else {
            $eventJson = '';
        }
        echo ($i === 0 ? '' : ',') ?>
	    {
	    "type": "Feature",
	    "properties":
	    <?= str_replace('"eventjson":"REPLACE_EVENT_JSON"', '"event":' . $eventJson, json_encode($row)) ?>

	    , "geometry":
	    <?= $geometry ?>

	    }<?php $i++;
    }
} ?>

	    ]
	    };

	    var <?= $element ?>layer = L.geoJson(<?= $element ?>data, {
	    title: '<?= $element ?>',
	    <?= ($onEachFeature ? 'onEachFeature: onEachFeature,' : '') ?>
	    <?= ($onEachFeature2 ? 'onEachFeature: onEachFeature2,' : '') ?>
	    <?= ($element === 'point' ? 'pointToLayer: function(feature, latlng) {
					return L.circleMarker(latlng,' : 'style:') ?> <?php if (!isset($customStyle)) { ?>{
	    weight: <?= $weight ?>,
	    color: "#<?= $color ?>",
	    opacity: <?= ($opacity ?? '1') ?>,
	    fillOpacity: <?= $fillOpacity ?>
	    <?= (isset($radius) ? ', radius:' . $radius : '') ?>
	    <?= ($attribution !== '' ? ", attribution: '" . $attribution . "'" : '') ?>
	    <?= ($element === 'point' ? '});' : '') ?>
	    }<?php } else {
	        echo $customStyle;
	    } ?>
	    });