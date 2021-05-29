import json
import logging


def parse_population(file: str):
    with open(file, 'r') as f:
        data = json.load(f)
        logging.debug(data.keys())

        cell_model_names = data["cell_model_names"]
        thresh_es = data["threshEs"]
        init_inds = data["init_inds"]
        e_mags = data["E_mags"]
        params = data["params"]

        # TODO: import cell coordinates
        # TODO: Parse data and return dict with useful data

        # Some debug prints
        logging.debug("Cell lengths")
        logging.debug(len(cell_model_names))
        logging.debug(len(thresh_es))
        logging.debug(len(init_inds))
        logging.debug(len(e_mags))
        logging.debug(len(params))

        logging.debug("Cell sizes")
        logging.debug(cell_model_names[0])
        logging.debug(len(thresh_es[0]))
        logging.debug(len(init_inds[0]))
        logging.debug(len(e_mags[0]))
        #logging.debug(params)

        logging.debug(thresh_es[0])
        logging.debug(init_inds[0])
        logging.debug(e_mags[0])

        # return large dict with a lot of non needed data
        return data

"""if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    parse_population("../data/tms_maxH_w1_ls_1_E_M1_PA_MCB70_P_nrn_pop1.json")"""
