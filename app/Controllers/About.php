<?php

namespace App\Controllers;

use App\Models\DocumentationModel;
use CodeIgniter\HTTP\RedirectResponse;

class About extends BaseController
{
    private string $title = 'About';

    public function index(string $jurisdiction = ''): void
    {
        echo view('core/header', ['title' => $this->title]);
        $DocumentationModel = new DocumentationModel();
        $jurisdictions = [];
        if ($jurisdiction === '') {
            $jurisdictions = $DocumentationModel->getAboutJurisdiction();
        }
        $query = $DocumentationModel->getAboutDetail($jurisdiction);
        if ($query === []) {
            echo view('core/norecord');
        } else {
            echo view('about/index', ['query' => $query, 'jurisdictions' => $jurisdictions]);
        }
        echo view('core/footer');
    }

    public function redirect(int|string $id): RedirectResponse
    {
        return redirect()->to('/' . $this->request->getLocale() . '/about/' . $id . '/', 301);
    }
}
