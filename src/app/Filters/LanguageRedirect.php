<?php

namespace App\Filters;

use CodeIgniter\HTTP\RedirectResponse;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class LanguageRedirect implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null): null|RedirectResponse
    {
        $segments = $request->uri->getSegments();
        $locale = $request->getLocale();
        if (isset($segments[0]) && $segments[0] !== $locale && $segments !== ['robots.txt']) {
            $segments[0] = $locale;
            $segments = '/' . implode('/', $segments) . '/';
            return redirect()->to($segments);
        }
        return null;
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null): void
    {
    }
}
