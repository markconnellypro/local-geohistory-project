<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

if (mb_strpos(base_url(), $_ENV['app_baseLocalGeohistoryProjectUrl']) !== false) {
    $routes->get('robots.txt', 'Bot::robotsTxt');

    $controllerRegex = ['adjudication', 'area', 'event', 'government', 'governmentsource', 'law', 'metes', 'reporter', 'source'];
    $mainSearchRegex = '(event|government|adjudication|law)';

    foreach ($controllerRegex as $c) {
        $routes->get('{locale}/' . $c . '/(:segment)', ucwords($c) . '::view/$1');
        if ($_ENV['app_jurisdiction'] !== '') {
            $routes->get('{locale}/(' . $_ENV['app_jurisdiction'] . ')/' . $c . '/(:segment)', ucwords($c) . '::redirect/$2');
        }
        $routes->get('{locale}/' . $c, ucwords($c) . '::noRecord');
    }

    if ($_ENV['app_jurisdiction'] !== '') {
        $routes->get('{locale}/(' . $_ENV['app_jurisdiction'] . ')/about', 'About::redirect/$1');
        $routes->get('{locale}/(' . $_ENV['app_jurisdiction'] . ')/statistics', 'Statistics::redirect');
        $routes->get('{locale}/(' . $_ENV['app_jurisdiction'] . ')', 'Search::redirect');
    }

    $routes->get('{locale}/lookup/government/(:segment)', 'Search::governmentlookup/$1/');
    $routes->get('{locale}/lookup/government-jurisdiction/(:segment)', 'Search::governmentlookup/$1/jurisdiction');
    $routes->get('{locale}/lookup/government-parent/(:segment)', 'Search::governmentlookup/$1/parent');
    $routes->get('{locale}/lookup/tribunal/(:num)', 'Search::tribunallookup');

    $routes->get('{locale}/search', 'Search::index');
    $routes->post('{locale}/search/' . $mainSearchRegex, 'Search::view/$1');
    $routes->get('{locale}/search/(:segment)', 'Search::noRecord');

    $routes->post('{locale}/address', 'Area::address');
    $routes->get('{locale}/point/(:segment)/(:segment)', 'Area::point/$1/$2');
    $routes->post('{locale}/point', 'Area::point');

    $routes->get('{locale}/about/(:segment)', 'About::index/$1');
    $routes->get('{locale}/about', 'About::index');
    $routes->get('{locale}/bot', 'Bot::index');
    $routes->get('{locale}/disclaimer', 'Disclaimer');
    $routes->get('{locale}/key', 'Key::index');

    $routes->get('{locale}/governmentidentifier/(:segment)/(:segment)', 'Governmentidentifier::view/$1/$2');

    $routes->get('{locale}/leaflet', 'Map::leaflet');
    $routes->get('{locale}/map-base', 'Map::baseStyle');
    $routes->get('{locale}/map-overlay', 'Map::overlayStyle');
    $routes->get('{locale}/map-tile/(:num)/(:num)/(:num)', 'Map::tile/$1/$2/$3');

    $routes->get('{locale}/statistics/report/', 'Statistics::view');
    $routes->get('{locale}/statistics/', 'Statistics::index');
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

if (mb_strpos(base_url(), $_ENV['app_baseLocalGeohistoryProjectUrl']) !== false) {
    $routes->get('{locale}', 'Welcome');
    $routes->get('/', 'Welcome::language');
    $routes->set404Override(\App\Controllers\Fourofour::class);
}
