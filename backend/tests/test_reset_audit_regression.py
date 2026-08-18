from pathlib import Path

api_file = Path(__file__).resolve().parents[2] / 'api' / 'index.php'
content = api_file.read_text(encoding='utf-8')

assert "UPDATE om_script_versions" in content, 'Reset should target the OM override row, not delete it'
assert "SET is_active = false" in content, 'Reset should disable OM override without deleting history'
assert "reset_om_default" in content, 'Audit action for OM reset should be preserved'
assert "operador_om" in content, 'Operador OM should be considered for audit access rules'
assert "DELETE FROM om_script_versions" not in content, 'No destructive delete should remain in OM reset logic'
