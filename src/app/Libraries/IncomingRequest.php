<?php

namespace App\Libraries;

use CodeIgniter\HTTP\IncomingRequest as BaseIncomingRequest;
use Locale;

class IncomingRequest extends BaseIncomingRequest
{
    /**
     * Sets the locale string for this request.
     *
     * @return IncomingRequest
     */
    #[\Override]
    public function setLocale(string $locale)
    {
        // If it's not a valid locale, set it
        // to the default locale for the site.
        if (!in_array($locale, $this->validLocales, true)) {
            // Check again, but only use the ISO 639-1 code.
            $locale = explode('-', $locale)[0];
            if (!in_array($locale, $this->validLocales, true)) {
                $locale = $this->defaultLocale;
            }
        }

        $this->locale = $locale;
        Locale::setDefault($locale);

        return $this;
    }
}
