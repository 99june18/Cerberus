import yaml
import sys
import os

benchmark_order = ['R', 'P', 'G', 'B']
benchmark_list = {
    "R": {
        "name": "rodinia",
        "list": [
            "nw",
            "b+tree",
            "backprop",
            "dwt2d",
            "bfs",
            "srad_v1",
            ]
    },
    "P": {
        "name": "parboil",
        "list": [
            "sgemm",
            "mri-q",
            "spmv",                 
            ]
    },
    "G": {
        "name": "graphBIG",
        "list": [
            "gpu_DegreeCentr",     
            "gpu_BFS",           
            "gpu_SSSP",            
            "gpu_kCore",
            ]
    },
    "B": {
        "name": "polybench",
        "list": [
            "ATAX",
            "MVT",
            "3DCONV",
            ]
    }
}

### Lists ###
search_list = ["gpu_tot_sim_cycle", "gpu_tot_sim_insn", "gpu_tot_ipc"]
mem_list = ['n_cmd', 'n_nop', 'n_act', 'n_pre', 'n_ref_event', 'n_req', 'n_rd', 'n_rd_L2_A', 'n_write', 'n_wr_bk', 'bw_util']
calc_list = ['dram_cnt']

print_list = ['gpu_tot_sim_cycle', 'gpu_tot_sim_insn', 'gpu_tot_ipc',
                'n_cmd', 'n_req', 'n_act', 'n_pre', 'n_rd', 'n_rd_L2_A', 'n_write', 'n_wr_bk']


### Making Excel ###
from openpyxl import Workbook
## Use an older version in the gpgpusim Docker (Python <= 3.6)
## $ pip install openpyxl==2.5.14
def make_excel(out_file, data):
    # 1) Create a new Excel workbook
    wb = Workbook()
    ws = wb.active
    ws.title = "data"

    # 2-1) Write directory info
    dir_headers = ['dir_id', 'dir_name', 'dir_path', 'Groups']
    ws.append(dir_headers)

    for _dir_id, _dir_data in enumerate(data):
        dir_row = [_dir_id, _dir_data['name'], _dir_data['path']] + _dir_data['group_list']
        ws.append(dir_row)
    ws.append([])

    # 2-2) Write all dir, benchmark, and workload data
    # - dir order: result_data (same as result_dir)
    # - benchmark order: benchmark_order
    # - workload order: benchmark_list[benchmark]['list']
    data_headers = ['dir_id', 'dir_name', 'dir_path', 'Benchmark', 'Workload', 'Result_file'] + search_list + mem_list + calc_list
    ws.append(data_headers)

    for _dir_id, _dir_data in enumerate(data):
        _dir_name = _dir_data['name']
        # Write benchmarks in benchmark_order
        for _bench_id in benchmark_order: # bench_id: 'R', 'P',...
            _bench_name = benchmark_list[_bench_id]['name']
            _bench_data = _dir_data['data'][_bench_name]
            w_list = benchmark_list[_bench_id]['list'] # Keep workload order from benchmark_list

            bench_row = [_dir_id, _dir_name, _dir_data['path'], _bench_name]
            ws.append(bench_row)

            # Write all workloads in w_list order
            for _w_name in w_list:
                _w_data = _bench_data[_w_name]
                w_row = None

                if _w_data['path'] is None:
                    w_row = [None, None, None, None, _w_name, '-']
                else:
                    w_row = [None, None, None, None, _w_name, _w_data['path']]
                # Fill data; None becomes an empty Excel cell
                for _item in search_list:
                    w_row.append(_w_data[_item])
                for _item in mem_list:
                    w_row.append(_w_data[_item])
                for _item in calc_list:
                    w_row.append(_w_data[_item])

                ws.append(w_row)
            ws.append([])

    # 2-3) Compare print_list values across dirs
    # sheet<'n_req'>
    #     - id::0:1:...
    #     - path::path0:path1:...
    #     - dir_name::dir0:dir1:...
    #     - benchmark0:workload0:data0:data1:...
    #     - benchmark0:workload1:data0:data1:...
    for _item in print_list:
        if not ((_item in search_list) or (_item in mem_list) or (_item in calc_list)):
            print("[error] There's no such item - {}!!!".format(_item))
            continue
        ws = wb.create_sheet(title=_item)

        item_header1 = ['dir_id', None] + [i for i in range(len(data))]
        ws.append(item_header1)
        item_header2 = ['dir_path', None] + [dir_data['path'] for dir_data in data]
        ws.append(item_header2)
        item_header3 = ['dir_name', None] + [dir_data['name'] for dir_data in data]
        ws.append(item_header3)

        # benchmark order: benchmark_order
        for _bench_id in benchmark_order: # bench_id: 'R', 'P',...
            _bench_name = benchmark_list[_bench_id]['name']
            w_list = benchmark_list[_bench_id]['list']

            # workload order: benchmark_list[benchmark]['list']
            for _w_name in w_list:
                # row
                w_row = [_bench_name, _w_name]

                # column
                # dir order: result_data (same as result_dir)
                for _dir_id, _dir_data in enumerate(data):
                    _w_data = _dir_data['data'][_bench_name][_w_name]
                    w_row.append(_w_data[_item])

                ws.append(w_row)
            ws.append([])

    # 3) Save the Excel file
    wb.save(out_file)
    print("Data has been written to {}".format(out_file))


### File Parsing ###
import re
def extract_dram_values(file_path, w_data):
    with open(file_path, 'r') as file:
        line_cnt = 0
        for _line in file:
            if not _line.strip().startswith('n_cmd'):
                continue
            line_cnt += 1

            for _keyword in mem_list:
                # (\d+(\.\d+)?) captures a number with an optional decimal part
                match = re.search(r"{}=(\d+(\.\d+)?)".format(_keyword), _line) # search: Not necessary to startswith '_keyword'
                if match:
                    if w_data[_keyword] is None: # value initialize
                        w_data[_keyword] = 0
                    w_data[_keyword] += float(match.group(1)) # value accumulate

        w_data['dram_cnt'] = line_cnt

def extract_values_from_file(file_path, w_data):
    with open(file_path, 'r') as file:
        for _line in file:
            for _keyword in search_list:
                match = re.match(r"{}\s*=\s*(\d+(\.\d+)?)".format(_keyword), _line) # match: should startswith '_keyword'
                if match:
                    w_data[_keyword] = float(match.group(1))

def file_parsing(dir_id, data):
    dir_data = data[dir_id]
    dir_name = data[dir_id]['name']

    for _bench, _bench_data in dir_data['data'].items():
        for _workload, _w_data in _bench_data.items():
            if _w_data['path'] is None:
                continue

            print("Parsing <{}_{}_{}_{}> {}".format(dir_id, dir_name, _bench, _workload, _w_data['path']))
            extract_values_from_file(_w_data['path'], _w_data)
            extract_dram_values(_w_data['path'], _w_data)


### Initialize ###
def get_init_workload_data():
    info_init = {'path': None}
    for _item in search_list:
        info_init[_item] = None
    for _item in mem_list:
        info_init[_item] = None
    for _item in calc_list:
        info_init[_item] = None

    return info_init

def init_data_field(dir_id, dir_name, dir_path, data):
    data[dir_id] = {'name': dir_name, 'path': dir_path, 'group_list':[], 'data':{}}
    dir_data = data[dir_id]

    # Initialize all benchmarks and workloads
    for _value in benchmark_list.values(): # all benchmarks
        bench_init_info = {}
        for _workload in _value['list']: # all workloads
            bench_init_info[_workload] = get_init_workload_data()
        dir_data['data'][_value['name']] = bench_init_info

    # Find valid result files and store their paths
    for _file in os.listdir(dir_path):
        ## Valid file format: {group}_{benchmark}_{workload}.txt
        # Check if the file ends with .txt
        if not _file.endswith(".txt"):
            continue
        # Split the filename by '_' (without extension)
        file_name = _file[:-4]  # remove extension
        parts = file_name.split("_")  # split by '_'

        # Check {group}_{benchmark}_{workload} format
        if len(parts) < 3:
            continue
        
        file_path = os.path.join(dir_path, _file)
        _scheme    = parts[0]                 # HBM4 / DUO / Unity / Cerberus ...
        _bench_tag = parts[1]                 # R / P / G / B
        _workload  = "_".join(parts[2:])      # bfs, MVT, gpu_kCore ...

        # Check if bench_tag is valid
        if _bench_tag not in benchmark_list:
            print("Invalid benchmark - {} ({})".format(_bench_tag, _file))
            invalid_benchmarks.append(file_path)
            continue

        # Check if workload is valid
        if _workload not in benchmark_list[_bench_tag]['list']:
            print("Invalid workload - {} ({})".format(_workload, _file))
            invalid_workloads.append(file_path)
            continue

        bench_name = benchmark_list[_bench_tag]['name']   # 'rodinia', 'parboil', ...

        # Store scheme names in group_list
        if _scheme not in dir_data['group_list']:
            dir_data['group_list'].append(_scheme)

        if dir_data['data'][bench_name][_workload]['path'] is not None:
            print("[error] Duplicated workload founded!!!")
            print("\t(1) {}".format(dir_data['data'][bench_name][_workload]['path']))
            print("\t(2) {}".format(file_path))

        dir_data['data'][bench_name][_workload]['path'] = file_path

### Global Values ###
# bench_data = {}
result_dir = []
result_data = {}
invalid_benchmarks = [] # for debugging
invalid_workloads = [] # for debugging

config_file_list = [
    '/root/Cerberus_script/Cerberus.yaml'
]


### Main ###
# Read the YAML file and build the sorted dir list
for _config_file in config_file_list:
    # Read YAML config (run_config)
    if not(os.path.isfile(_config_file)):
        print("config_file do not exist!!")
        sys.exit(1)

    with open(_config_file, 'r', encoding='utf-8') as file:
        run_config = yaml.safe_load(file)

    for run in run_config['run']:
        bench = None
        for set_item in run_config['sets']:
            if set_item['name'] == run:
                bench = set_item
                if bench['result_dir'] not in result_dir:
                    result_dir.append(bench['result_dir'])

        if bench is None:
            print()
            print("[error] undefined benchmark run!!! - {}".format(run))
            print()
            print()
    # sort
    result_dir = sorted(result_dir)

# Check all dirs: (1) init and validate files, (2) parse files
result_data = [None] * len(result_dir)
for i, _dir_path in enumerate(result_dir):
    dir_name = os.path.basename(_dir_path)

    init_data_field(i, dir_name, _dir_path, result_data) # (1)
    file_parsing(i, result_data) # (2)

# Debug: list invalid files
print("Invalid benchmarks:", invalid_benchmarks)
print("Invalid workloads:", invalid_workloads)

# Create the result Excel file
from datetime import datetime, timedelta
current_time = datetime.now() + timedelta(hours=9)
formatted_time = current_time.strftime("%Y%m%d_%H%M%S")
result_file_path = '/root/Cerberus_script/run_status/result_' + formatted_time + '.xlsx'
make_excel(result_file_path, result_data)

