# Interneuronal connectivity simulation
This project contains template simulating interneuronal 
connectivity in the M1 cortex. This code builds upon the 
Aberra pipeline on individual cells.
> NOTE: Project is not finished and all the functionality is yet
> to be implemented

Currently importing the cells is working properly, but no actual
connections have been made yet.

## Install
Create new virtualenv

`python3 -m virtualenv env -p=3.9`

and activate the virtualenv

`source env/bin/activate`

install required packages

`pip install -r requirements.txt`

### Compile mechanism
While in the virtual env run `nrnivmodl mechanism` to
compile the cell mechanisms

### Data
Cell data is in the [cells](cells) directory
[cells.json](cells.json) contains cell and template names for cells to be imported
- `label` : cell label need to be same as the cell folder name in cells directory.
  label is used as the cell name in the code.
- `cell_name`: name of the template to be imported defined in the corresponding 
  `template.hoc` file

[cells](cells) folder include the same cells as in Aberra's pipeline. Can be changed if
different cell models needs to be used.

[data](data) folder contains single cell population data calculated using Aberra's matlab code
converted to json format.


## Run
To run the code: `python main.py`
possible arguments:
- `--cells {path}` defines path for the cells to import 
  (default: `cells.json`)
  
- `--log {log_level}` change logging output level 
  (default: warning)
  
- `--log_file {filename}` defines output file for logging output. 
  (default: None)
  
