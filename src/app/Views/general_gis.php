	var <?= $element ?>data = {
	"type": "FeatureCollection",
	"features": [
	<?php $i = 0;
    foreach ($query as $row) {
        if ($element == 'line') {
            $geometry = $row->linegeometry;
            unset($row->linegeometry);
            $row = [
                'type' => 'Line',
                'line' => $row->line,
                'description' => $row->linedescription
            ];
        } elseif ($element == 'point') {
            $geometry = $row->pointgeometry;
            $row = [
                'type' => 'Point',
                'line' => $row->line,
                'description' => $row->pointdescription
            ];
        } elseif (empty($row->geometry)) {
            $geometry = NULL;
        } else {
            $geometry = $row->geometry;
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
        echo ($i == 0 ? '' : ',') ?>
	    {
	    "type": "Feature",
	    "properties":
	    <?= str_replace('"eventjson":"REPLACE_EVENT_JSON"', '"event":' . $eventJson, json_encode($row)) ?>

	    , "geometry":
	    <?= $geometry ?>

	    }<?php $i++;
        } ?>

	    ]
	    };

	    var <?= $element ?>layer = L.geoJson(<?= $element ?>data, {
	    title: '<?= $element ?>',
	    <?= ($onEachFeature ? 'onEachFeature: onEachFeature,' : '') ?>
	    <?= ($onEachFeature2 ? 'onEachFeature: onEachFeature2,' : '') ?>
	    <?= ($element == 'point' ? 'pointToLayer: function(feature, latlng) {
					return L.circleMarker(latlng,' : 'style:') ?> <?php if (!isset($customStyle)) { ?>{
	    weight: <?= $weight ?>,
	    color: "#<?= $color ?>",
	    opacity: <?= (isset($opacity) ? $opacity : '1') ?>,
	    fillOpacity: <?= $fillOpacity ?>
	    <?= (isset($radius) ? ', radius:' . $radius : '') ?>
	    <?= ((isset($attribution) and !empty($attribution)) ? ", attribution: '" . $attribution . "'" : '') ?>
	    <?= ($element == 'point' ? '});' : '') ?>
	    }<?php } else {
                                                                        echo $customStyle;
                                                                    } ?>
	    });