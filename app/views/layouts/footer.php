        </main>
    </div>
</div>
<script src="<?= e(asset_url('js/app.js')) ?>"></script>
<?php if (!empty($pageScripts ?? [])): foreach ($pageScripts as $src): ?><script src="<?= e(asset_url($src)) ?>"></script><?php endforeach; endif; ?>
</body>
</html>
