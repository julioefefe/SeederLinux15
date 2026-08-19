# Lixeira

Esta pasta guarda arquivos substituídos ou gerados que não participam do fluxo
de produção. Eles ficam preservados para consulta histórica e não devem ser
referenciados pelo instalador, pela API ou pelo frontend.

- `sql/`: migrações manuais incorporadas ao `install/schema.sql`.
- `code/`: bytecodes Python gerados localmente e removidos do fluxo rastreado.

Antes de restaurar qualquer arquivo, confirme se a funcionalidade correspondente
já está coberta pelo arquivo consolidado e regenere os artefatos derivados quando
necessário.