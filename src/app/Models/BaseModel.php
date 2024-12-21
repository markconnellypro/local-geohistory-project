<?php

namespace App\Models;

use CodeIgniter\Model;
use CodeIgniter\Database\BaseResult;
use CodeIgniter\Database\Query;

class BaseModel extends Model
{
    protected function getArray(bool|BaseResult|Query $query): array
    {
        if (is_object($query) && method_exists($query, 'getResultArray')) {
            return $query->getResultArray();
        }
        return [];
    }

    protected function getObject(bool|BaseResult|Query $query): array
    {
        if (is_object($query) && method_exists($query, 'getResult')) {
            return $query->getResult();
        }
        return [];
    }
}
