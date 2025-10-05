apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name_prefix}-test
  labels:
    app: ${name_prefix}-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${name_prefix}-test
  template:
    metadata:
      labels:
        app: ${name_prefix}-test
    spec:
      containers:
      - name: web
        image: python:3.11-slim
        command: ["/bin/sh","-c","pip install flask && python /app/app.py"]
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: appcode
          mountPath: /app
      volumes:
      - name: appcode
        configMap:
          name: ${name_prefix}-test-config

---
apiVersion: v1
kind: Service
metadata:
  name: ${name_prefix}-test-svc
spec:
  type: LoadBalancer
  selector:
    app: ${name_prefix}-test
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
