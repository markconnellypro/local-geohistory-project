<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class LanguageRedirect implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $segments = $request->uri->getSegments();
        $locale = $request->getLocale();
        if (isset($segments[0]) and $segments[0] !== $locale and $segments !== ['robots.txt']) {
            $segments[0] = $locale;
            $segments = '/' . implode('/', $segments) . '/';
            return redirect()->to($segments);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
    }
}
