import sys
if sys.prefix == '/usr':
    sys.real_prefix = sys.prefix
    sys.prefix = sys.exec_prefix = '/home/szk/workspace/car_distributed/car_agent/install/car_agent_bringup'
