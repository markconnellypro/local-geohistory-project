<?php

namespace App\Controllers;

class Adjudication extends BaseController
{

    private $data;

	public function __construct()
	{
			$this->data = [
				'title' => 'Adjudication Detail',
				'isInternetExplorer' => $this->isInternetExplorer(),
				'live' => $this->isLive(),
				'online' => $this->isOnline(),
				'updated' => $this->lastUpdated()->fulldate,
			];
	}

	public function noRecord($state)
	{
		$this->data['state'] = $state;
		echo view('header', $this->data);
		echo view('norecord');
		echo view('footer');
	}

	public function view($state, $id)
	{
		$this->data['state'] = $state;
		if ($this->data['live'] AND preg_match('/^\d{1,9}$/', $id)) {
			$id = intval($id);
		}
		$query = $this->db->query('SELECT * FROM extra.ci_model_adjudication_detail(?, ?)', [$id, $state])->getResult();
		if (count($query) != 1) {
			$this->noRecord($state);
		} else {
			$id = $query[0]->adjudicationid;
			$this->data['pageTitle'] = $query[0]->adjudicationtitle;
			echo view('header', $this->data);
			echo view('adjudication_detail', ['row' => $query[0]]);
			$query = $this->db->query('SELECT * FROM extra.ci_model_adjudication_location(?)', [$id])->getResult();
			if (count($query) > 0) {
				echo view('adjudication_location', ['query' => $query]);
			}
			$query = $this->db->query('SELECT * FROM extra.ci_model_adjudication_filing(?, ?)', [$id, $this->data['live']])->getResult();
			if (count($query) > 0) {
				echo view('adjudication_filing', ['query' => $query]);
			}
			$query = $this->db->query('SELECT * FROM extra.ci_model_adjudication_source(?)', [$id])->getResult();
			if (count($query) > 0) {
				echo view('general_reporter', ['query' => $query, 'state' => $state, 'hasLink' => true, 'title' => 'Reporter Links']);
			}
			$query = $this->db->query('SELECT * FROM extra.ci_model_adjudication_event(?)', [$id])->getResult();
			if (count($query) > 0) {
				echo view('general_event', ['query' => $query, 'state' => $state, 'title' => 'Event Links', 'eventRelationship' => true]);
			}
			echo view('footer');
		}

	}
}
