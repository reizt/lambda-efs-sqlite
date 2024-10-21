#! /bin/sh

rm -rf tmp
mkdir tmp
cp .python-version requirements.lock requirements-dev.lock pyproject.toml README.md tmp
cd tmp

python3.12 -m venv layer
layer/bin/pip install -r requirements.lock --platform=manylinux2014_x86_64 --only-binary=:all: --target layer/lib/python3.12/site-packages
mv layer/lib/python3.12/site-packages python
zip -r ../layer.zip python

cd ..
rm -rf tmp
