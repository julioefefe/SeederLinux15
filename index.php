<?php
require_once __DIR__ . '/lib/config.php';
require_once __DIR__ . '/lib/db.php';
require_once __DIR__ . '/lib/functions.php';

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');

// Roteador de temas públicos: o index só chama o tema definido no painel
// (Dashboard → Tema do sistema). Opções: classic, modern, solar.
$theme = 'classic';
try {
    $row = Database::fetchOne("SELECT value FROM settings WHERE key = 'public_theme'");
    if ($row && in_array($row['value'], ['classic', 'modern', 'solar'], true)) {
        $theme = $row['value'];
    }
} catch (Throwable $e) {
    // Sem banco: cai no clássico
}

switch ($theme) {
    case 'modern':
        require __DIR__ . '/public/moderno.php';
        break;
    case 'solar':
        require __DIR__ . '/public/solar.php';
        break;
    default:
        require __DIR__ . '/public/classico.php';
        break;
}
