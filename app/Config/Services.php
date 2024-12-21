<?php

namespace Config;

use App\Libraries\IncomingRequest;
use CodeIgniter\Config\BaseService;
use CodeIgniter\Config\Services as AppServices;
use CodeIgniter\HTTP\UserAgent;

/**
 * Services Configuration file.
 *
 * Services are simply other classes/libraries that the system uses
 * to do its job. This is used by CodeIgniter to allow the core of the
 * framework to be swapped out easily without affecting the usage within
 * the rest of your application.
 *
 * This file holds any application-specific services, or service overrides
 * that you might need. An example has been included with the general
 * method format you should use for your service methods. For more examples,
 * see the core Services file at system/Config/Services.php.
 */
class Services extends BaseService
{
    /**
     * The IncomingRequest class models an HTTP request.
     *
     * @return IncomingRequest
     *
     * @internal
     */
    public static function incomingrequest(?App $config = null, bool $getShared = false)
    {
        if ($getShared) {
            return static::getSharedInstance('request', $config);
        }

        $config ??= config('App');

        return new IncomingRequest(
            $config,
            AppServices::uri(),
            'php://input',
            new UserAgent()
        );
    }
}
