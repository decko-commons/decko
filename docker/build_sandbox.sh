docker build -f repos/decko-base.dockerfile -t ethn/decko-base .
docker build -f repos/decko-bundled.dockerfile -t ethn/decko-bundled .
docker build -f repos/decko-mysql.dockerfile -t ethn/decko-mysql .
docker build -f repos/decko-postgres.dockerfile -t ethn/decko-postgres .
docker build -f repos/decko-sandbox.dockerfile -t ethn/decko-sandbox .
