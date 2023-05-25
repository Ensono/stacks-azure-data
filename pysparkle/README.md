# PySparkle Usage

## Using CLI

```bash
pysparkle --help
pysparkle silver --help
pysparkle silver --partitions 4
pysparkle gold
```

## Using an entrypoint script

```bash
python entrypoint.py --help
python entrypoint.py silver --help
python entrypoint.py silver --partitions 4
python entrypoint.py gold
```

# Build
Use the following command to build a Python wheel (by default saved to `dist` directory).

```bash
poetry build
```

# Install
Please replace the version as required.

```bash
pip install dist/pysparkle-0.1.0-py3-none-any.whl
```

# Prerequisites
Spark runs on Java 8/11/17, Java 8 prior to version 8u362 support is deprecated
as of Spark 3.4.0. For details see: https://spark.apache.org/docs/latest/.
