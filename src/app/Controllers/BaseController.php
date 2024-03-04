<?php

namespace App\Controllers;

use CodeIgniter\Controller;
use CodeIgniter\HTTP\CLIRequest;
use App\Libraries\IncomingRequest;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Psr\Log\LoggerInterface;
use App\Models\AppModel;

/**
 * Class BaseController
 *
 * BaseController provides a convenient place for loading components
 * and performing functions that are needed by all your controllers.
 * Extend this class in any new controllers:
 *     class Home extends BaseController
 *
 * For security be sure to declare any new methods as protected or private.
 */
abstract class BaseController extends Controller
{
    /**
     * Instance of the main Request object.
     *
     * @var CLIRequest|IncomingRequest
     */
    protected $request;

    /**
     * An array of helpers to be loaded automatically upon
     * class instantiation. These helpers will be available
     * to all other controllers that extend BaseController.
     *
     * @var array
     */
    protected $helpers = [];

    // protected $session;
    public function initController(RequestInterface $request, ResponseInterface $response, LoggerInterface $logger): void
    {
        // Do Not Edit This Line
        parent::initController($request, $response, $logger);

        // Preload any models, libraries, etc, here.

        // E.g.: $this->session = \Config\Services::session();
    }

    protected function affectedGovernmentProcess($partQuery = [], $wholeQuery = [])
    {
        $affectedGovernment = [
            'linkTypes' => [],
            'rows' => [],
            'types' => [],
        ];
        if (isset($partQuery)) {
            foreach ($partQuery as $row) {
                if (!empty($row->governmentfromlong)) {
                    $affectedGovernment['types']['from'][$row->affectedgovernmentleveldisplayorder] = $row->affectedgovernmentlevellong;
                    if (!empty($row->includelink) && $row->includelink == 't') {
                        $affectedGovernment['linkTypes']['from'][$row->affectedgovernmentleveldisplayorder] = $row->affectedgovernmentlevellong;
                    }
                    $affectedGovernment['rows'][$row->id]['From ' . $row->affectedgovernmentlevellong . ' Link'] = $row->governmentfrom;
                    $affectedGovernment['rows'][$row->id]['From ' . $row->affectedgovernmentlevellong . ' Long'] = $row->governmentfromlong;
                    $affectedGovernment['rows'][$row->id]['From ' . $row->affectedgovernmentlevellong . ' Affected'] = $row->affectedtypefrom;
                }
                if (!empty($row->governmenttolong)) {
                    $affectedGovernment['types']['to'][$row->affectedgovernmentleveldisplayorder] = $row->affectedgovernmentlevellong;
                    if (!empty($row->includelink) && $row->includelink == 't') {
                        $affectedGovernment['linkTypes']['to'][$row->affectedgovernmentleveldisplayorder] = $row->affectedgovernmentlevellong;
                    }
                    $affectedGovernment['rows'][$row->id]['To ' . $row->affectedgovernmentlevellong . ' Link'] = $row->governmentto;
                    $affectedGovernment['rows'][$row->id]['To ' . $row->affectedgovernmentlevellong . ' Long'] = $row->governmenttolong;
                    $affectedGovernment['rows'][$row->id]['To ' . $row->affectedgovernmentlevellong . ' Affected'] = $row->affectedtypeto;
                }
            }
            foreach ($affectedGovernment['types'] as $fromTo => $levels) {
                ksort($levels);
                $affectedGovernment['types'][$fromTo] = $levels;
            }
            $kSort = $affectedGovernment['types'];
            ksort($kSort);
            $affectedGovernment['types'] = $kSort;
            foreach ($affectedGovernment['linkTypes'] as $fromTo => $levels) {
                ksort($levels);
                $affectedGovernment['linkTypes'][$fromTo] = $levels;
            }
            $kSort = $affectedGovernment['linkTypes'];
            ksort($kSort);
            $affectedGovernment['linkTypes'] = $kSort;
        }
        if (isset($wholeQuery)) {
            foreach ($wholeQuery as $row) {
                foreach ($row as $key => $value) {
                    $affectedGovernment['rows'][$row['id']][$key] = $value;
                }
            }
        }
        foreach ($affectedGovernment['rows'] as $key => $value) {
            $affectedGovernment['rows'][$key] = (object) $value;
        }
        return $affectedGovernment;
    }

    protected function isInternetExplorer(): bool
    {
        if (isset($_SERVER['HTTP_USER_AGENT'])) {
            $browser = strtolower($_SERVER['HTTP_USER_AGENT']);
            return str_contains($browser, 'msie') || str_contains($browser, 'internet explorer') || str_contains($browser, 'trident');
        } else {
            return false;
        }
    }

    protected function getIdInt($id)
    {
        if (static::isLive() && preg_match('/^\d{1,9}$/', $id)) {
			$id = (int) $id;
		}
        return $id;
    }

    public static function getJurisdictions()
    {
        $jurisdictions = trim(($_ENV['app_jurisdiction'] ?? '') . '|' . ($_ENV['app_jurisdiction_development'] ?? ''), '|');
        $jurisdictions = explode('|', $jurisdictions);
        sort($jurisdictions);
        return $jurisdictions;
    }

    public static function getProductionJurisdictions()
    {
        $jurisdictions = trim(($_ENV['app_jurisdiction'] ?? ''), '|');
        $jurisdictions = explode('|', $jurisdictions);
        sort($jurisdictions);
        return $jurisdictions;
    }

    public static function isLive(): bool
    {
        return (ENVIRONMENT == 'development');
    }

    protected function isOnline(): bool
    {
        if (static::isLive() && gethostbyname('unpkg.com') == 'unpkg.com') {
            return false;
        } else {
            return true;
        }
    }

    protected function lastUpdated()
    {
        date_default_timezone_set('America/New_York');
        $AppModel = new AppModel;
        return $AppModel->getLastUpdated();
    }
}
