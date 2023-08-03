<?php

namespace Config;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/*
 * --------------------------------------------------------------------
 * Router Setup
 * --------------------------------------------------------------------
 */
$routes->setDefaultNamespace('App\Controllers');
// $routes->setDefaultController('Home');
// $routes->setDefaultMethod('index');
$routes->setTranslateURIDashes(false);
// $routes->set404Override();
// The Auto Routing (Legacy) is very dangerous. It is easy to create vulnerable apps
// where controller filters or CSRF protection are bypassed.
// If you don't want to define all routes, please use the Auto Routing (Improved).
// Set `$autoRoutesImproved` to true in `app/Config/Feature.php` and set the following to true.
// $routes->setAutoRoute(false);

/*
 * --------------------------------------------------------------------
 * Route Definitions
 * --------------------------------------------------------------------
 */

$routes->add('robots.txt', 'Bot::robotsTxt');

if (mb_strpos(base_url(), $_ENV['app_baseLocalGeohistoryProjectUrl']) !== FALSE) {
    if (ENVIRONMENT == 'development') {
        // Includes all US and Canadian provinces, states, and territories
        $stateProvinceRegex = '{locale}/(a[bklrsz]|bc|c[aot]|d[ce]|f[l]|g[au]|h[i]|i[adln]|k[sy]|l[a]|m[abdeinopst]|n[bcdehjlmstuvy]|o[hknr]|p[aer]|qc|r[i]|s[cdk]|t[nx]|u[t]|v[ait]|w[aivy]|yt)';

        // Adds USA and CAN
        $nationStateProvinceRegex = '{locale}/(a[bklrsz]|bc|c[aot]|can|d[ce]|f[l]|g[au]|h[i]|i[adln]|k[sy]|l[a]|m[abdeinost]|n[bcdehjlmstuvy]|o[hknr]|p[aer]|qc|r[i]|s[cdk]|t[nx]|u[t]|usa|v[ait]|w[aivy]|yt)';

        // Temporary
        $stateProvinceRegex = $nationStateProvinceRegex;
    } else {
        // Only selected states
        $stateProvinceRegex = '{locale}/('. $_ENV['app_jurisdiction'] . ')';
        $nationStateProvinceRegex = '{locale}/('. $_ENV['app_jurisdiction'] . ')';
    }

    $controllerRegex = ['adjudication', 'area', 'event', 'government', 'governmentsource', 'law', 'metes', 'reporter', 'source'];
    $mainSearchRegex = '(event|government|adjudication|law)';

    foreach ($controllerRegex as $c) {
        $routes->add($stateProvinceRegex . '/' . $c . '/(:segment)', ucwords($c) . '::view/$1/$2');
        $routes->add($stateProvinceRegex . '/' . $c, ucwords($c) . '::noRecord/$1');
    }

    $routes->add($stateProvinceRegex, 'Search::index/$1');
    $routes->add($stateProvinceRegex . '/search/' . $mainSearchRegex, 'Search::view/$1/$2');
    $routes->add($stateProvinceRegex . '/search/(:segment)', 'Search::noRecord/$1');

    $routes->add($stateProvinceRegex . '/address', 'Area::address/$1');
    $routes->add($stateProvinceRegex . '/point/(:segment)/(:segment)', 'Area::point/$1/$2/$3');
    $routes->add($stateProvinceRegex . '/point', 'Area::point/$1');

    $routes->add('{locale}/governmentidentifier/(:segment)/(:segment)', 'Governmentidentifier::view/$1/$2');

    $routes->add($stateProvinceRegex . '/leaflet', 'Map::leaflet/$1');

    $routes->add($stateProvinceRegex . '/about', 'About::index/$1');
    $routes->add($stateProvinceRegex . '/map-base', 'Map::baseStyle/$1');
    $routes->add($stateProvinceRegex . '/map-overlay', 'Map::overlayStyle/$1');
    $routes->add($stateProvinceRegex . '/map-tile/(:num)/(:num)/(:num)', 'Map::tile/$2/$3/$4/$1');
    $routes->add('{locale}/about', 'About::index');
    $routes->add('{locale}/bot', 'Bot::index');
    $routes->add('{locale}/disclaimer', 'Disclaimer');
    $routes->add('{locale}/key', 'Key::index');

    $routes->add($stateProvinceRegex . '/statistics/report/', 'Statistics::view/$1');
    $routes->add($stateProvinceRegex . '/statistics/', 'Statistics::index/$1');
    $routes->add('{locale}/statistics/report/', 'Statistics::view');
    $routes->add('{locale}/statistics/', 'Statistics::index');

    $routes->add($stateProvinceRegex . '/lookup/government/(:segment)', 'Search::governmentlookup/$1/$2/government');
    $routes->add($stateProvinceRegex . '/lookup/governmentparent/(:segment)', 'Search::governmentlookup/$1/$2/governmentparent');
    $routes->add($stateProvinceRegex . '/lookup/tribunal/(:num)', 'Search::tribunallookup/$1');
}

/*
 * --------------------------------------------------------------------
 * Additional Routing
 * --------------------------------------------------------------------
 *
 * There will often be times that you need additional routing and you
 * need it to be able to override any defaults in this file. Environment
 * based routes is one such time. require() additional route files here
 * to make that happen.
 *
 * You will have access to the $routes object within that file without
 * needing to reload it.
 */
if (is_file(APPPATH . 'Config/' . ENVIRONMENT . '/Routes.php')) {
    require APPPATH . 'Config/' . ENVIRONMENT . '/Routes.php';
}

if (mb_strpos(base_url(), $_ENV['app_baseLocalGeohistoryProjectUrl']) !== FALSE) {
    $routes->add('{locale}', 'Welcome');
    $routes->add('/', 'Welcome::language');
    $routes->set404Override('App\Controllers\Fourofour');
    $routes->add('(:any)', 'Fourofour');
}
