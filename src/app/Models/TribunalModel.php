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
                    WHEN tribunaltype.tribunaltypelevel > 2 THEN government.governmentshortshort || ', ' || governmentstate.governmentshortshort
                    WHEN tribunaltype.tribunaltypelevel = 2 THEN government.governmentshortshort
                    ELSE ''
                END ||
                CASE
                    WHEN tribunaltype.tribunaltypedivision <> '' THEN ', ' || tribunaltype.tribunaltypedivision
                    ELSE ''
                END ||
                CASE
                    WHEN tribunaltype.tribunaltypelevel = 1 AND tribunal.tribunaldistrictcircuit <> '' THEN 'the '
                    WHEN tribunal.tribunaldistrictcircuit <> '' THEN ', '
                    ELSE ''
                END ||
                CASE
                    WHEN tribunal.tribunaldistrictcircuit = '1' THEN 'First'
                    WHEN tribunal.tribunaldistrictcircuit = '2' THEN 'Second'
                    WHEN tribunal.tribunaldistrictcircuit = '3' THEN 'Third'
                    WHEN tribunal.tribunaldistrictcircuit = '4' THEN 'Fourth'
                    WHEN tribunal.tribunaldistrictcircuit = '5' THEN 'Fifth'
                    WHEN tribunal.tribunaldistrictcircuit = '6' THEN 'Sixth'
                    WHEN tribunal.tribunaldistrictcircuit = '7' THEN 'Seventh'
                    WHEN tribunal.tribunaldistrictcircuit = '8' THEN 'Eighth'
                    WHEN tribunal.tribunaldistrictcircuit = '9' THEN 'Ninth'
                    WHEN tribunal.tribunaldistrictcircuit = '10' THEN 'Tenth'
                    WHEN tribunal.tribunaldistrictcircuit = '11' THEN 'Eleventh'
                    WHEN tribunal.tribunaldistrictcircuit = '12' THEN 'Twelfth'
                    WHEN tribunal.tribunaldistrictcircuit = '13' THEN 'Thirteenth'
                    WHEN tribunal.tribunaldistrictcircuit = '14' THEN 'Fourteenth'
                    WHEN tribunal.tribunaldistrictcircuit = 'C' THEN 'Central'
                    WHEN tribunal.tribunaldistrictcircuit = 'E' THEN 'Eastern'
                    WHEN tribunal.tribunaldistrictcircuit = 'M' THEN 'Middle'
                    WHEN tribunal.tribunaldistrictcircuit = 'N' THEN 'Northern' 
                    WHEN tribunal.tribunaldistrictcircuit = 'Rich' THEN 'Richmond'
                    WHEN tribunal.tribunaldistrictcircuit = 'S' THEN 'Southern'
                    WHEN tribunal.tribunaldistrictcircuit = 'Scrtn' THEN 'Scranton'
                    WHEN tribunal.tribunaldistrictcircuit = 'Sta' THEN 'Staunton'
                    WHEN tribunal.tribunaldistrictcircuit = 'W' THEN 'Western'
                    WHEN tribunal.tribunaldistrictcircuit = 'W.Lyn' THEN 'Western'
                    WHEN tribunal.tribunaldistrictcircuit = 'Wmpt' THEN 'Williamsport'
                    WHEN tribunal.tribunaldistrictcircuit = 'Wyt' THEN 'Wytheville'
                    ELSE ''
                END ||
                CASE
                    WHEN tribunal.tribunaldistrictcircuit <> '' THEN ' ' || tribunaltype.tribunaltypedistrictcircuit
                    ELSE ''
                END ||
                CASE
                    WHEN tribunaltype.tribunaltypelevel = 1 AND (tribunaltype.tribunaltypelong = 'Supreme Court' OR government.governmentname = 'Columbia') THEN 'the ' || government.governmentshortshort
                    WHEN tribunaltype.tribunaltypelevel = 1 AND tribunaltype.tribunaltypedistrictcircuit = 'District' AND tribunal.tribunaldistrictcircuit = '' THEN government.governmentshortshort
                    WHEN tribunaltype.tribunaltypelevel = 1 AND tribunaltype.tribunaltypedistrictcircuit = 'District' THEN ' of ' || government.governmentshortshort
                    ELSE ''
                END ||
                CASE
                    WHEN tribunal.tribunaldistrictcircuit = 'W.Lyn' THEN ', Lynchburg Division'
                    ELSE ''
                END
            QUERY;
    }
}
