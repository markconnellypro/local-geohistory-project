// Taken from http://fuzzytolerance.info/blog/2016/07/01/Printing-Mapbox-GL-JS-maps-in-Firefox/
function fixFirefoxPrint() {
return navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
}

var baseMapATT = 'Base map: <a href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>.';

<?php if (!empty($state)) { ?>
baseMapATT = baseMapATT + ' Hillshading: <a href="https://aws.amazon.com/public-datasets/terrain/">AWS</a> &copy; <a href="https://github.com/tilezen/joerd/blob/master/docs/attribution.md">Mapzen contributors</a>.';

var baseMapUrl = '/en/<?= $state ?>/map-base/';
var governmentOverlayMap = L.maplibreGL({
style: '/en/<?= $state ?>/map-overlay/',
preserveDrawingBuffer: fixFirefoxPrint(), // Taken from http://fuzzytolerance.info/blog/2016/07/01/Printing-Mapbox-GL-JS-maps-in-Firefox/
pane: 'overlayPane'
});
<?php } else { ?>
var baseMapUrl = 'https://api.maptiler.com/maps/outdoor-v2/style.json?key=<?= getenv('maptiler_key') ?>';
<?php } ?>

var baseMap = L.maplibreGL({
attribution: baseMapATT,
style: baseMapUrl,
preserveDrawingBuffer: fixFirefoxPrint(), // Taken from http://fuzzytolerance.info/blog/2016/07/01/Printing-Mapbox-GL-JS-maps-in-Firefox/
pane: 'tilePane'
});

