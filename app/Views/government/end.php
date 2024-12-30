<?php
$layers ??= ['default' => 'default'];
$primaryLayer ??= '';
$showTimeline ??= false;
$updatedParts ??= (object) [
    'sortdate' => '',
    'sortdatetext' => '',
];
?>
var map = L.map("map", {
  layers: [baseMap, governmentOverlayMap<?php foreach ($layers as $key => $layer) {
      echo ', ', $key, 'layer';
  }?>]
});

map.fitBounds(<?= $primaryLayer ?>layer.getBounds());

var overlayMaps = {
  "Approximate Current Boundaries": governmentOverlayMap,
<?php
$i = 0;
if (is_array($layers) && $layers !== []) {
    foreach ($layers as $key => $layer) {
        if ($i > 0) {
            echo ",\n";
        } else {
            $i++;
        }
        echo "  ",'"', $layer, '": ', $key, 'layer';
    }
} ?>

};

Object.keys(stateOverlayMaps).forEach(function (element) {
  overlayMaps[element] = stateOverlayMaps[element];
});

L.control.layers(baseMaps, overlayMaps).addTo(map);

<?php foreach (array_keys(array_reverse($layers)) as $key) {
    echo $key, "layer.bringToFront();\n";
} ?>

var info = L.control({position: 'topright'});

info.onAdd = function(map) {
	this._div = L.DomUtil.create('div', 'info');
	this.update();
	return this._div;
};


infoRegularUpdate = function(props) {
  if(props) {
    t = '<div id="mapinfo">'
      + (props.plsstownshipshort !== '' ? '<div class="mapwidth">Survey Township: </div>'
      + '<div>' + (props.plsstownship !== '' ? '<a href="' + props.plsstownship + '">' : '')
      + props.plsstownshipshort + (props.plsstownship !== '' ? '</a>' : '') + '</div>' : '')
      + (props.submunicipalitylong !== '' ? '<div class="mapwidth">Sub-Municipality: </div>'
      + '<div><a href="/<?= \Config\Services::request()->getLocale() ?>/government/' + props.submunicipality + '/">'
      + props.submunicipalitylong + '</a></div>' : '')
      + '<div class="mapwidth">Municipality: </div>'
      + '<div>' + (props.municipality !== '' ? '<a href="/<?= \Config\Services::request()->getLocale() ?>/government/' + props.municipality + '/">' : '')
      + props.municipalitylong + (props.municipality !== '' ? '</a>' : '') + '</div>'
      + '<div class="mapwidth">County: </div>'
      + '<div>' + (props.county !== '' ? '<a href="/<?= \Config\Services::request()->getLocale() ?>/government/' + props.county + '/">' : '')
      + props.countyshort + (props.county !== '' ? '</a>' : '') + '</div>'
      + '<div class="mapwidth">Status: </div>'
      + '<div><a href="/<?= \Config\Services::request()->getLocale() ?>/key/#governmentmapstatus">'
      + dispositionColorName(props.disposition) + '</a></div>';
    for (i = 0; i < props.event.length; i++) {
      if (i == 0) {
        t += '<div class="mapwidth">Event' + (props.event.length > 1 ? 's' : '') + ': </div>';
      } else {
        t += '<div class="mapwidth"></div>';
      }
      t += '<div><a href="/<?= \Config\Services::request()->getLocale() ?>/event/' + props.event[i].eventslug + '/">'
        + props.event[i].eventdatetext + '</a></div>';
    }
    t += '<div class="mapwidth">Area: </div>'
      + '<div><a href="/<?= \Config\Services::request()->getLocale() ?>/area/' + props.governmentshapeslug + '/">View</a></div>';
    t += '</>'
  } else {
    t = '<div class="b">Click for more info.</span>';
  }
	this._div.innerHTML = t;
};

info.update = infoRegularUpdate;

info.addTo(map);

<?php if (\App\Controllers\BaseController::isLive()) { ?>

var info2 = L.control({position: 'topleft'});

info2.onAdd = function(map) {
	this._div = L.DomUtil.create('div', 'info2');
	this.update();
	return this._div;
};

info2RegularUpdate = function(props) {
	this._div.innerHTML = (props ? '<div class="mapwidth">Event: </div><a href="/<?= \Config\Services::request()->getLocale() ?>/event/' + props.event + '/">'
    + props.metesdescriptionlong + '</a> <br>' : '<div class="b">Click for more info.</span>');
};

info2.update = info2RegularUpdate;

info2.addTo(map);

<?php } if (\App\Controllers\BaseController::isLive() || $showTimeline) { ?>

/* Timeline */

function toRegular() {
  info.update = infoRegularUpdate;
  info.update();
  shapelayer.eachLayer(function (layer) {
    layer.setStyle(dispositionStyleTemplate(dispositionColor(layer.feature.properties.disposition)));
		layer._events.click = layer._events.oldClick;
    layer._events.oldClick = null;
	});
}

function toTimeLine() {
  shapeTime = {};
  shapeTimeText = {};
  shapeNameText = {};
  shapeNameCount = 0;
  for (featureIndex in shapelayer._layers) {
  	try {
  		shapelayer._layers[featureIndex].feature.properties.event.forEach(function(item) {
  			try {
  				if (item.eventstatus == 'add' || item.eventstatus == 'name' || item.eventstatus == 'remove' ) {
  					if (!shapeTime.hasOwnProperty(item.eventsort)) {
  						shapeTime[item.eventsort] = {};
                        shapeTimeText[item.eventsort] = item.eventtextsortdate;
  					}
  					if (!shapeNameText.hasOwnProperty(item.eventsort)) {
                        shapeNameText[item.eventsort] = '';
  					}
                    if (item.eventgovernmentlong && shapeNameText[item.eventsort] != item.eventgovernmentlong) {
                        shapeNameText[item.eventsort] = item.eventgovernmentlong;
                        shapeNameCount++;
                    }
  					shapeTime[item.eventsort][featureIndex] = item.eventstatus;
  				}
  			} catch (err1) {
  			}
  		});
  	} catch (err2) {
  	}
  }
  if (!shapeNameText[<?= $updatedParts->sortdate ?>]) {
    shapeNameText[<?= $updatedParts->sortdate ?>] = '';
  }
  lastShapeNameText = '';
  for (shapeNameIndex in shapeNameText) {
    if (shapeNameText[shapeNameIndex] == '' || (shapeNameText[shapeNameIndex] !== '' && shapeNameCount == 1)) {
      shapeNameText[shapeNameIndex] = lastShapeNameText;
    } else if (shapeNameCount > 1) {
      lastShapeNameText = shapeNameText[shapeNameIndex];
    }
  }
  shapeTimeList = Object.keys(shapeTime);
  $('.leaflet-control-timelapse-range').val("0");
  $('.leaflet-control-timelapse-range').attr('max', (shapeTimeList.length));
  shapeTimeList.push("<?= $updatedParts->sortdate ?>");
  shapeTimeText["<?= $updatedParts->sortdate ?>"] = "<?= $updatedParts->sortdatetext ?>";
  timeString = '';
  nameString = '';
  infoTimeUpdate = function(props) {
    newTimeString = '<span class="b">Event Date <a href="/<?= \Config\Services::request()->getLocale() ?>/key/#date" aria-label="Date Key" title="Date Key"><span class="keyiconfill">vpn_key</span></a>:</span> ' + timeString;
    if (nameString) {
      newTimeString += '<br><span class="b">Government:</span> ' + nameString;
    }
    this._div.innerHTML = newTimeString;
  }
  info.update = infoTimeUpdate;
	shapelayer.eachLayer(function (layer) {
		layer.setStyle({fillOpacity: 0, fillColor: 'white'});
    layer._events.oldClick = layer._events.click;
		layer._events.click = null;
	});
	step = -1;
	stepForward();
}

function doStep() {
	shapelayer.eachLayer(function (layer) {
    timeString = shapeTimeText[shapeTimeList[step]];
    nameString = shapeNameText[shapeTimeList[step]];
    info.update();
    var layerAction;
    try {
      layerAction = shapeTime[shapeTimeList[step]][layer._leaflet_id];
    } catch (err) {
    }
		if (layerAction === undefined || layerAction == 'name') {
			if ((stepForwardDirection && layer.options.fillColor == '#C56C00') || (!stepForwardDirection && layer.options.fillColor == '#6F0381')) {
				layer.setStyle({fillOpacity: 0, fillColor: 'white'});
			} else if (layer.options.fillColor != 'white') {
				layer.setStyle({fillOpacity: 0.5, fillColor: '#07517D'});
			}
		} else if (layerAction == 'add') {
			layer.setStyle({fillOpacity: 0.5, fillColor: '#6F0381'});
		} else if (layerAction == 'remove') {
			layer.setStyle({fillOpacity: 0.5, fillColor: '#C56C00'});
		}
	});
}

function stepForward() {
	if (step + 1 < shapeTimeList.length && timeLineActive && !timelapseControlActive) {
		++step;
		stepForwardDirection = true;
		doStep();
    return true;
	} else {
    return false;
  }
}

function stepBackward() {
	if (step > 0 && timeLineActive && !timelapseControlActive) {
		--step;
		stepForwardDirection = false;
		doStep();
    return true;
	} else {
    return false;
  }
}

var timelapseControlActive = false;
var timelapseBox = L.control();
timelapseBox.onAdd = function(map) {
	this._div = L.DomUtil.create('div', 'timelapsebox');
  this._div.innerHTML = '<div class="info leaflet-control-timelapse"><input type="range" class="leaflet-bar-part leaflet-control-timelapse-range" name="leaflet-control-timelapse-range" value="0" min="0"></div>';
	return this._div;
};
timelapseBox.addTo(map);

$('.leaflet-control-timelapse').bind('touchstart mousedown', function () {
  map.dragging.disable();
});

$('.leaflet-control-timelapse').bind('touchend mouseup', function () {
  map.dragging.enable();
});

$('.leaflet-control-timelapse-range').on("<?= (\App\Controllers\BaseController::isInternetExplorer() ? 'change' : 'input') ?>", function () {
  var newValue = parseInt($('.leaflet-control-timelapse-range').val());
  if (newValue > step) {
    for (stepValue = step; stepValue < newValue; stepValue++) {
      stepForward();
    }
  } else if (newValue < step) {
    for (stepValue = step; newValue < stepValue; stepValue--) {
      stepBackward();
    }
  }
});

var timeLineActive = false;
L.Control.TimeLine = L.Control.extend({
	onAdd : function (map) {
		// Create control
		var controlDiv = L.DomUtil.create("div", "leaflet-bar leaflet-control");
		var controlUI = L.DomUtil.create("a", "leaflet-bar-part", controlDiv);
		controlUI.href = "#";
    controlUI.innerHTML = '<span class="leaflet-control-timelapse-button mapicon">timelapse</span>';
		this._button = controlUI;
    this._button.title = "View Timelapse";
		this._container = controlDiv;
		this._createTooltip();
		return controlDiv;
	},
	// CreateTooltip()
	_createTooltip : function () {
		L.DomEvent.on(this._button, "click", function (e) {
      L.DomEvent.stopPropagation(e);
			L.DomEvent.preventDefault(e);
			timeLineActive = !timeLineActive;
  		if (timeLineActive) {
				toTimeLine();
        $('.leaflet-control-timelapse-button').html('cancel');
        document.getElementsByClassName('timelapsebox')[0].style.display = 'flex';
        this.title = "Exit Timelapse";
			} else {
				toRegular();
        $('.leaflet-control-timelapse-button').html('timelapse');
        document.getElementsByClassName('timelapsebox')[0].style.display = 'none';
        this.title = "View Timelapse";
			}
			return false;
		});
	}
});
var timeLineControl = new L.Control.TimeLine();
map.addControl(timeLineControl);

/* End Timeline */

<?php } ?>
