from netpyne import specs, sim


def analyse(net_params: specs.NetParams, sim_config: specs.SimConfig):
    sim.createSimulateAnalyze(netParams=net_params, simConfig=sim_config)

    # Plot 3d shape of the imported cells
    # sim.analysis.plotShape(includePre=["all"], includePost=["all"])

    # TODO: Customise analysis outputs
