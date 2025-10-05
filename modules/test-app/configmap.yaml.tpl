apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name_prefix}-test-config
data:
  app.py: |
${app_py}
