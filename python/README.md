# README

Make sure to install pylint and autopep8 python modules using: `py -3 -m pip install -r requirements.txt`

this will install:
- autopep8>=1.3.2
- pylint>=1.7.2

# vscode integration of pylint and autopep8

the workspace settings I use is:
```json
{
    "python.pythonPath": "${env:GA_PYTHON3_DIR}/python.exe",
    "python.linting.enabled": true,
    "python.linting.pylintArgs": ["--rcfile=${env:GA_SCRIPTS}/python/python-format"],
    "python.formatting.autopep8Args" : ["--global-config", "${env:GA_SCRIPTS}/python/python-format"],

    "files.exclude": {
        "**/__pycache__": true
    }
}
```

This make use of 2 environment variables:
- `GA_PYTHON3_DIR` (for ex = `C:\dev\Python36`)
- `GA_SCRIPTS` (for ex = `D:\dev\galdebert\scripts`)
