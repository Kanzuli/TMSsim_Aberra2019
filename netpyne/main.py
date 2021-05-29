import json
import logging
import argparse

from netpyne import specs, sim
from utils import analysis
from config import cell_config, net_config, sim_config


def init():
    parser = argparse.ArgumentParser("LST-Project network template")
    parser.add_argument("--cells", type=str, help="JSON file containing used cells", default="cells.json")
    parser.add_argument("--log", type=str, help="Logging level", default="warning")
    parser.add_argument("--log_file", type=str, help="Log file", default=None)
    args = parser.parse_args()

    log_level = getattr(logging, args.log.upper())

    logging.basicConfig(filename=args.log_file, level=log_level)

    return args


def main():
    args = init()

    net_params = specs.NetParams()
    sim_cfg = specs.SimConfig()

    logging.info("Opening cells")
    with open(args.cells, "r") as f:
        cells = json.load(f)

    logging.debug(cells)

    logging.info("Init cells")
    #cell_config.init_cells(net_params, cells)

    # Load single cell (For debug purposes)
    cell_config.load_cell(label=cells[0]["label"],
                          cell_name=cells[0]["cell_name"],
                          load_biophysic=True,
                          net_params=net_params)

    logging.info("Init network parameters")
    net_config.init_net_params(net_params, cells)

    logging.info("Init simulation config")
    sim_config.init_sim_config(sim_cfg)

    logging.info("Analysing")


    # These commands can be used to initialize the network simulation before analysis and simulations
    sim.initialize(
        simConfig=sim_config,
        netParams=net_params
    )
    sim.net.createPops()
    sim.net.createCells()
    sim.net.connectCells()



    logging.debug("Cells")
    logging.debug(sim._gatherAllCellTags()[0])

    logging.debug(net_params.cellParams.keys())
    logging.debug(net_params.popParams.keys())
    logging.debug(net_params.synMechParams.keys())

    logging.debug("Number of synapse mechanisms: {}".format(len(net_params.synMechParams.keys())))

    # TODO: Create synMechs, populations, connections

    # Simulate and create analysis
    analysis.analyse(net_params, sim_cfg)


if __name__ == '__main__':
    main()
