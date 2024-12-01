<?php

namespace App\Models;

use App\Models\BaseModel;

class TribunalModel extends BaseModel
{
    public function getFilingOffice(): string
    {
        return <<<QUERY
                CASE
                    WHEN tribunal.tribunalalternatefilingoffice <> '' THEN government.governmentshortshort || ', ' || governmentstate.governmentshortshort || ' ' || tribunal.tribunalalternatefilingoffice
                    ELSE tribunaltype.tribunaltypefilingoffice || ' of ' ||
                    CASE
                        WHEN tribunaltype.tribunaltypefilingofficerlevel THEN government.governmentshortshort || ', ' || governmentstate.governmentshortshort
                        ELSE 'the ' ||
            QUERY . $this->getLong() . <<<QUERY
                    END
                END
            QUERY;
    }

    public function getLong(): string
    {
        return <<<QUERY
                tribunaltype.tribunaltypelong || ' of ' ||
                CASE
                    WHEN tribunaltype.tribunaltypelevel > 2 THEN government.governmentshortshort || ', ' || governmentstate.governmentshortshort ||
                    CASE
                        WHEN tribunaltype.tribunaltypedivision <> '' THEN ' - ' || tribunaltype.tribunaltypedivision
                        ELSE ''
                    END
                    WHEN tribunaltype.tribunaltypelevel = 2 THEN government.governmentshortshort ||
                    CASE
                        WHEN tribunal.tribunaldistrictcircuit = 'E' THEN ' - Eastern District'
                        WHEN tribunal.tribunaldistrictcircuit = 'M' THEN ' - Middle District'
                        WHEN tribunal.tribunaldistrictcircuit = 'W' THEN ' - Western District'
                        WHEN tribunal.tribunaldistrictcircuit = 'N' THEN ' - Northern District'
                        WHEN tribunal.tribunaldistrictcircuit = 'S' THEN ' - Southern District'
                        WHEN tribunal.tribunaldistrictcircuit = 'C' THEN ' - Central District'
                        ELSE ''
                    END
                    WHEN tribunaltype.tribunaltypelevel = 1 THEN
                    CASE
                        WHEN tribunal.tribunaldistrictcircuit = 'E' THEN 'the Eastern District of ' || government.governmentshortshort
                        WHEN tribunal.tribunaldistrictcircuit = 'M' THEN 'the Middle District of ' || government.governmentshortshort
                        WHEN tribunal.tribunaldistrictcircuit = 'W' THEN 'the Western District of ' || government.governmentshortshort
                        WHEN tribunal.tribunaldistrictcircuit = 'N' THEN 'the Northern District of ' || government.governmentshortshort
                        WHEN tribunal.tribunaldistrictcircuit = 'S' THEN 'the Southern District of ' || government.governmentshortshort
                        WHEN tribunal.tribunaldistrictcircuit = 'C' THEN 'the Central District of ' || government.governmentshortshort
                        WHEN tribunal.tribunaldistrictcircuit = '1' THEN 'the First Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '2' THEN 'the Second Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '3' THEN 'the Third Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '4' THEN 'the Fourth Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '5' THEN 'the Fifth Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '6' THEN 'the Sixth Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '7' THEN 'the Seventh Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '8' THEN 'the Eighth Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '9' THEN 'the Ninth Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '10' THEN 'the Tenth Circuit'
                        WHEN tribunal.tribunaldistrictcircuit = '11' THEN 'the Eleventh Circuit'
                        WHEN government.governmentlevel = 1 OR government.governmentname = 'District of Columbia' THEN 'the ' || government.governmentshortshort
                        ELSE government.governmentshortshort
                    END
                    ELSE ''
                END
            QUERY;
    }
}
