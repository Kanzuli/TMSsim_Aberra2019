import logging
import os

from neuron import h
from netpyne import specs, conversion


def init_cells(net_params: specs.NetParams, cells):
    all_cells = load_many_cells(cells, net_params)


def load_hoc_files(load_biophysics=True):
    """
    Check the h.load_file documentation. number one flag is required to force NEURON to load the file with the same
    name again.
    https://www.neuron.yale.edu/neuron/static/py_doc/programming/dynamiccode.html?highlight=load_file#load_file
    """

    # Load import3d, this is required for the cell morphologies
    h.load_file("import3d.hoc")
    # Load constants, not sure if this is needed, but better safe than sorry
    h.load_file("constants.hoc")

    # Load morphology. Every cell has its own morphology
    h.load_file(1, "morphology.hoc")
    # Load biophysics. Every cell types has its own biophysic
    # if clause to prevent error output of trying to load same template multiple times
    if load_biophysics:
        h.load_file(1, "biophysics.hoc")
    # Load synapses. Needed for synmechs
    h.load_file(1, "synapses/synapses.hoc")


def load_cell(label: str, cell_name: str, net_params: specs.NetParams, load_path=None, load_biophysic=True) -> dict:

    # Set current workdir temporarily to this cells directory so hoc files load properly
    # (For some reason full paths break loading of cells sometimes)
    original_path = os.getcwd()
    if load_path is None:
        os.chdir(os.path.join(original_path, "cells", label))
        template_path = str(os.path.join(original_path, "cells", label, "template.hoc"))
    else:
        os.chdir(os.path.join(load_path, label))
        template_path = str(os.path.join(load_path, label, "template.hoc"))

    net_params.popParams.keys()

    # Import cell files
    load_hoc_files(load_biophysic)

    # This functions imports the cells. Does not work if cells have
    cell_rule = net_params.importCellParams(
        label=label,
        fileName=template_path,
        cellName=cell_name,
        cellArgs=[1],   # Load synapses: 0 = false, 1=true. Need to be true to import synapse mechanisms
        importSynMechs=True,
    )
    # Set workdir back to original
    os.chdir(original_path)
    return cell_rule


def load_many_cells(cells, net_params: specs.NetParams) -> list[dict]:
    all_cells = []
    for i, cell in enumerate(cells):
        logging.info("Loading cell num {}".format(i))
        cell_type_labels = list(map(lambda x: x[:-2], net_params.cellParams.keys()))

        load_biophysics = cell["label"][:-2] not in cell_type_labels

        c = load_cell(label=cell["label"], cell_name=cell["cell_name"],
                      net_params=net_params,
                      load_biophysic=load_biophysics)
        all_cells.append(c)
    logging.debug(net_params.cellParams.keys())
    return all_cells
