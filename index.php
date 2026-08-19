<?php
require_once __DIR__ . '/lib/config.php';
require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/functions.php';

$theme = 'classic';
try {
    $row = Database::fetchOne("SELECT value FROM settings WHERE key = 'public_theme'");
    if ($row && in_array($row['value'], ['classic', 'modern'], true)) {
        $theme = $row['value'];
    }
} catch (Throwable $e) {
    // Fall back to classic if settings table is unavailable
}

if ($theme === 'modern') {
    require __DIR__ . '/public/index.php';
} else {
    require __DIR__ . '/index.html';
}
