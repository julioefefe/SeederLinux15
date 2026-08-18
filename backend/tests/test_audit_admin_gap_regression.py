from pathlib import Path

root = Path(__file__).resolve().parents[2]
functions_file = root / 'lib' / 'functions.php'
api_file = root / 'api' / 'index.php'

functions_text = functions_file.read_text(encoding='utf-8')
api_text = api_file.read_text(encoding='utf-8')


def test_admin_gap_helper_accepts_legacy_admin_role():
    assert "return in_array($role, ['admin_gap', 'admin'], true);" in functions_text


def test_admin_gap_org_scope_is_ignored():
    assert "if (isAdminGap()) {\n        return null;" in functions_text
    assert "Admin GAP visualiza tudo" in api_text
    assert "if ($orgId !== null && $orgId > 0 && $userOrgId !== null && $userOrgId !== $orgId)" in api_text
    assert "if ($orgId !== null && $orgId > 0 && isAdminGap())" not in api_text
