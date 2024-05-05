<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class LanguageRedirect implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null): void
    {
        $segments = $request->getUri()->getSegments();
        $locale = $request->getLocale();
        if (isset($segments[0]) && $segments[0] !== $locale && $segments !== ['robots.txt']) {
            $segments[0] = $locale;
            $segments = '/' . implode('/', $segments) . '/';
            header('Location: ' . $segments);
            die();
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null): void
    {
    }
}
