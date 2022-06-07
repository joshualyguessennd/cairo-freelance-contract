# Freelance Contract Cairo

This contract let an entity deploy contracts that help employer and freelancer to transact on a secure mode

# Getting started

Create a folder for your project and cd into it:
```
mkdir myproject
cd myproject
```
Create a virtualenv and activate it:

```
python3 -m venv env
source env/bin/activate
```

# compile

Compile Cairo contracts. Compilation articacts are written into the artifacts/ directory.

```
nile compile # compiles all contracts under contracts/
```

# test
run the test 

```
pytest tests/
```