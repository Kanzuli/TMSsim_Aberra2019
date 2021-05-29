from netpyne import specs


def init_sim_config(cfg: specs.SimConfig):

    # TODO: Set simulation parameters from the pipeline params
    cfg.duration = 0.05*1e3        # Duration of the simulation, in ms
    cfg.dt = 0.1              # Internal integration timestep to use
    cfg.verbose = False         # Show detailed messages
    cfg.recordTraces = {'V_soma':{'sec':'soma','loc':0.5,'var':'v'}}  # Dict with traces to record
    cfg.recordStep = 0.1        # Step size in ms to save data (eg. V traces, LFP, etc)
    cfg.filename = 'network_test'       # Set file output name

    # TODO: Add plotting configs





