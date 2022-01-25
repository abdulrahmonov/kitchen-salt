{% set msi = "clamav-0.104.2.win.x64.msi" %}
{% set sourceDir = "salt://clamav/" %}
{% set targetDir = "C:\\temp\\"%}
{% set targetFullPath = targetDir + msi %}
{% set collectors = "[defaults]" %}


copy clamav.msi to minion:
  file.managed:
    - name: {{ targetFullPath }}
    - source: {{sourceDir}}{{ msi }}
    - makedirs: True

execute clamav.msi:
  cmd.run:
    - name: msiexec /i {{ targetFullPath }} ENABLED_COLLECTORS={{ collectors }};  rm {{ targetFullPath }}
    - shell: powershell
    - require:
      - file: {{ targetFullPath }}