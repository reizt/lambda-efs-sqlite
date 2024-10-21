#! /bin/sh

workdir=tmp
outfile=layer.zip
venv=venv
layer=layer
requirements=requirements.lock

mkdir -p $workdir
cp requirements.lock requirements-dev.lock .python-version pyproject.toml README.md $workdir
cd $workdir
rm -rf $venv $layer $outfile
echo "✅ created workdir: $workdir"
python -m venv $venv
echo "✅ created venv: $venv"
$venv/bin/pip install -r requirements.lock
echo "✅ installed requirements"
mkdir -p $layer
mv $venv/lib $layer/python
echo "✅ moved python libs: $layer/python"
zip -r $outfile $layer
echo "✅ created zip file: $outfile"
cd ..
