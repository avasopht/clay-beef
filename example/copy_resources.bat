PUSHD %~dp0

SETLOCAL

mkdir dist
mkdir dist\resource
mkdir dist\resource\images
mkdir dist\resource\models
copy resource\fonts\* dist\resource\fonts
copy resource\images\* dist\resource\images
