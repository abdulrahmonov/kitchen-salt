top.sls:
  base:
    "*":
      - clamav
      - prometheus_agent_deploy