			<div class="push">&nbsp;</div>
			</main>
			<footer class="headerfooter">
			    <div id="footertext" class="bodytext">
			        <?= lang('Template.originalContent') ?> &copy; 2009–<?= date('Y') ?> <a href="https://www.markconnelly.pro/<?= \Config\Services::request()->getLocale() ?>/contact/">Mark A. Connelly</a>
			        <?= lang('Template.license') ?> <a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/deed.<?= \Config\Services::request()->getLocale() ?>">CC BY-SA 4.0</a> |
			        <a href="/<?= \Config\Services::request()->getLocale() ?>/disclaimer/"><?= lang('Template.disclaimers') ?></a> |
					<a href="https://opendata.localgeohistory.pro/"><?= lang('Template.opendata') ?></a> |
			        <?= ($live ? 'LIVE as of' : 'Data updated') ?> <?= $updated ?>
			    </div>
			</footer>
			</div>
			</body>

			</html>