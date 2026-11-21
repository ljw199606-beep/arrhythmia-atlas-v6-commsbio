FROM python:3.10-slim

WORKDIR /workspace
COPY requirements-verify.txt .
RUN pip install --no-cache-dir -r requirements-verify.txt

COPY scripts/ ./scripts/
COPY data_audit/ ./data_audit/
COPY virtualmyocyte/ ./virtualmyocyte/
COPY figures/ ./figures/
COPY manifests/ ./manifests/

CMD ["python", "scripts/run_reviewer_quickcheck.py"]
