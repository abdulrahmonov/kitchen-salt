{% set msi = "windows_exporter-0.16.0-amd64.msi" %}
{% set sourceDir = "salt://prometheus_agent_deploy/" %}
{% set targetDir = "C:\\temp\\"%}
{% set targetFullPath = targetDir + msi %}
{% set collectors = "[defaults]" %}

{% if salt['service.available']('MSSQLSERVER') == True %}
  {% set collectors = collectors + ',mssql' %}
{% endif %}

{% if salt['service.available']('IISADMIN') == True %}
  {% set collectors = collectors + ',iis' %}
{% endif %}

copy prom_exporter.msi to minion:
  file.managed:
    - name: {{ targetFullPath }}
    - source: {{sourceDir}}{{ msi }}
    - makedirs: True

execute prom_exporter.msi:
  cmd.run:
    - name: msiexec /i {{ targetFullPath }} ENABLED_COLLECTORS={{ collectors }};
    - shell: powershell
    - require:
      - file: {{ targetFullPath }}