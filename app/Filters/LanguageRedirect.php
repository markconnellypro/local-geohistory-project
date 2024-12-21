<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class LanguageRedirect implements FilterInterface
{
    #[\Override]
    public function before(RequestInterface $request, $arguments = null): void
    {
        $segments = $request->getUri()->getSegments();
        $locale = method_exists($request, 'getLocale') ? $request->getLocale() : 'en';
        if (isset($segments[0]) && $segments[0] !== $locale && $segments !== ['robots.txt']) {
            $segments[0] = $locale;
            $segments = '/' . implode('/', $segments) . '/';
            header('Location: ' . $segments);
            die();
        }
    }

    #[\Override]
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null): void {}
}
