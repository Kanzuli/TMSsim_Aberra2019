from netpyne import specs


def init_net_params(net_params: specs.NetParams, cells):
    ASCII_BASE = 65
    for i, cell in enumerate(cells):
        # Create populations with names starting from A
        net_params.popParams[chr(ASCII_BASE + i)] = {'cellType': cells[i]["label"], 'numCells': 10}

        # TODO: Create connections between cell populations based on the literature


def update_instantiated_network(net, cell_config_dict):
    # TODO: Update instantiated network cells with data based on calculated thresholds and e_mags
    # TODO: Create interpolations based on the dat
    pass
