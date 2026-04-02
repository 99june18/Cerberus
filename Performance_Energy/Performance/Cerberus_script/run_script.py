import psutil
import yaml
import sys
import os
import datetime
import subprocess
import time

def get_remain_cpu_cores():
    # Total core count
    total_cores = psutil.cpu_count(logical=True)
    # Measure per-core CPU usage
    current_usage = psutil.cpu_percent(interval=1, percpu=True)
    # Count active cores
    active_cores = sum(usage > 10 for usage in current_usage) # active cores where util is more than 10%
    # Remaining cores
    remaining_cores = total_cores - active_cores
    return remaining_cores

# Update gpgpusim config
def modify_gpgpu_config(file_name, workload_info, bench_info):
    options = {}
    if 'commonOptions' in bench_info:
        if bench_info['commonOptions']:
            for key, value in bench_info['commonOptions'].items():
                options[key] = value
    if 'specificOptions' in workload_info:
        if workload_info['specificOptions']:
            for key, value in workload_info['specificOptions'].items():
                options[key] = value
    if not options:
        print("There is no config to change")
        return
    else:
        print("config to be applied:")
        for key, value in options.items():
            print("-{} {}".format(key,value))
        print("")
    # Buffer for file contents
    lines = []

    # Read the file
    with open(file_name, 'r') as file:
        lines = file.readlines()

    # Find and update options
    option_done = {key: False for key in options.keys()}

    for i, line in enumerate(lines):
        line_word = line.split()
        for option, value in options.items():
            option_line = "-{}".format(option)
            if line_word and line_word[0] == option_line:
                lines[i] = '-{} {}\n'.format(option, value)
                option_done[option] = True

    lines.append('\n') # Add a blank line for separation
    for key, value in options.items():
        if option_done[key] == False:
            lines.append('-{} {}\n'.format(key, value))

    # Write the updated file
    with open(file_name, 'w') as file:
        file.writelines(lines)

def bench_run_func(bench, proc):
    bench_dir = bench['dir'] # bench folder
    _out_dir = bench['result_dir']
    print("Result_dir: {}".format(_out_dir))
    for workload in bench['workloads']:
        os.chdir(os.path.join(bench_dir, workload['name'])) # Move to the workload folder
        os.system("cp {} .".format(org_config_dir+'/*')) # Copy original gpgpusim_config
        print()
        print("### workload: {} / scheme: {} --------------------------------".format(workload['name'], bench['source']))
        # Apply options
        modify_gpgpu_config('gpgpusim.config', workload, bench)
        os.system("cp {} {}".format("gpgpusim.config", _out_dir))

        if not (os.path.isfile('run')):
            print("current_dir: {}".format(os.getcwd()))
            print("bench: {} / workload: {} / run do not exist!".format(bench['name'], workload['name']))
            sys.exit(1)
        log_name = "{}_{}.txt".format(bench['prefix'], workload['name'])
        workload['log_file_path'] = os.path.join(os.getcwd(), log_name)
        print("SAL: log_path: {}".format(workload['log_file_path']))
        start_datetime = datetime.datetime.now()
        if ('specificDescription' in workload) and bool(workload['specificDescription']):
            description = "{} / {}".format(bench['description'], workload['specificDescription'])
        else:
            description = bench['description']
        with open(log_name, "w") as log_file:
            desc_header = (
                "===================================================================\n"
                "========================== Description ============================\n"
                "Date: {}\n"
                "Workload: {}\n"
                "Description: {}\n"
                "===================================================================\n"
            ).format(start_datetime.strftime("%Y-%m-%d %H:%M:%S"), workload['name'], description)
            log_file.write(desc_header)
        commands = "cd {}; source setup_environment; cd {}; ./run >> {} 2>&1".format(source_dir[bench['source']], os.path.join(bench_dir, workload['name']), log_name)
        print("log_name: {}".format(log_name))
        print("commands: {}\n".format(commands)) # debug
        work = subprocess.Popen(['bash', '-c', commands]) # Needs verification
        proc[bench['name']][workload['name']] = {'load': workload['name'], 'proc': work, 'error_reported': False, 'elapsed_t': None, 'start_t': start_datetime, 'pid': work.pid, 'log_name': log_name}
        time.sleep(1)
    time.sleep(10)

def elapsed_time_cal(start_t, end_t):
    elapsed_time = end_t - start_t
    days, remainder = divmod(elapsed_time.total_seconds(), 86400)
    hours, minutes = divmod(remainder, 3600)
    return int(days), int(hours), int(minutes // 60)

def elapsed_time_str(start_t, end_t):
    days_t, hours_t, min_t = elapsed_time_cal(start_t, end_t)
    elapsed_t_str = "{} days {} hours {} minutes".format(days_t, hours_t, min_t)
    return elapsed_t_str

def update_status_log(processes, log_file_path):
    """ Update the status log with the current state of each process. """
    intermed_t = datetime.datetime.now()

    with open(log_file_path, "w") as log_file:
        log_file.write("This process PID: {}\n".format(this_pid))
        log_file.write("Start_timedate: {}\n".format(start_time.strftime("%Y-%m-%d %H:%M:%S")))
        for bench_name, bench_info in processes.items():
            if bool(bench_info):
                log_file.write("Benchmark: {} / start_date: {}\n".format(bench_name, bench_start_t[bench_name].strftime("%Y-%m-%d %H:%M:%S")))
                log_file.write("Description: {}\n".format(bench_description[bench_name]))
                for work_name, work_info in bench_info.items():
                    load, proc, error_reported, elapsed_t, work_start_t, w_pid, w_log= work_info['load'], work_info['proc'], work_info['error_reported'], work_info['elapsed_t'], work_info['start_t'], work_info['pid'], work_info['log_name']
                    proc_return = proc.poll()
                    if proc_return is None:
                        status = "Running"
                        elapsed_t = elapsed_time_str(work_start_t, intermed_t)
                    else:
                        if work_info['elapsed_t'] == None:
                            work_info['elapsed_t'] = elapsed_time_str(work_start_t, intermed_t)
                            elapsed_t = elapsed_time_str(work_start_t, intermed_t)
                        if proc.returncode == 0:
                            status = "Completed"
                        else:
                            status = "Error"
                            if not error_reported:
                                print("{} / {} : Error occurred!".format(bench_name, load), file=sys.stderr)
                                print("{} / {} : Error occurred!".format(bench_name, load))
                                work_info['error_reported'] = True
                    log_file.write("{:<20}: PID {:<5} / {:<10} / Elapsed time: {} / {}\n".format(load, w_pid, status, elapsed_t, w_log))
                log_file.write("\n")
            else:
                log_file.write("Benchmark: {} not start!\n\n".format(bench_name))
        if all_done:
            days, hours, minutes = elapsed_time_cal(start_time, intermed_t)
            elapsed_result = "Total Elapsed time: {} days / {} hours / {} minutes".format(days, hours, minutes)
            log_file.write(elapsed_result)

def update_result_file():
    for bench in run_config['sets']:
        if not (bench['name'] in run_config['run']):
            continue
        if not is_run_bench[bench['name']]:
            continue

        for workload in bench['workloads']:
            if 'log_file_path' not in workload:
                print("SAL: in update_result_file - workload {} doesn't have log file path".format(workload['name']))
                continue
            _log_file_path = workload['log_file_path']
            if not (os.path.isfile(_log_file_path)):
                continue

            _out_dir = bench['result_dir']
            with open(_log_file_path, 'r', encoding='utf-8') as log_file:
                for line in log_file:
                    if "exit detected" in line:
                        os.system("mv {} {}".format(_log_file_path, _out_dir))
                        print("SAL: found exit and copy result file: mv {} -> {}/".format(_log_file_path, _out_dir))
                        break



# Check if the correct number of arguments is passed
# Put both prefix and description in the YAML config

if len(sys.argv) == 2:
    config_name = sys.argv[1]
else:
    print("You must enter only the config_file")
    sys.exit(1)

if not(os.path.isfile(config_name)):
    print("config_file do not exist!!")
    sys.exit(1)

# main code
with open(config_name, 'r', encoding='utf-8') as file: # Read YAML
    run_config = yaml.safe_load(file)
print("YAML_config: {}".format(config_name))
org_config_dir = run_config['org_config_dir'] # Original gpgpusim_config path
print("Origianl_gpgpusim_config: {}".format(org_config_dir))
print("Log_file_path: {}".format(run_config['log_file_path']))

source_dir = run_config['source_dir']
start_time = datetime.datetime.now()
print("start_date: {}".format(start_time.strftime("%Y-%m-%d %H:%M:%S")))
this_pid = os.getpid()
print("PID: {}".format(this_pid))
# Build the benchmark run list from run_config
is_run_bench = {}
bench_start_t = {}
bench_description = {}
bench_list = [set_item['name'] for set_item in run_config['sets']] # Benchmark list defined in sets
print("Benchmarks to run : {}".format(bench_list)) # debug
processes = {} # Track all workloads
all_done = False

for bench in run_config['sets']:
    bench_description[bench['name']] = bench['description']

for bench in run_config['run']:
    if(bench in bench_list):
        is_run_bench[bench] = False
        bench_start_t[bench] = None
        processes[bench] = {}
    else:
        print("undefined benchmark: {} !!".format(bench))
        sys.exit(1)

# Check result directories
outdir_check = True
for bench in run_config['sets']:
    _outdir = bench['result_dir']
    if not os.path.isdir(_outdir):
        print("Make a new output directory: {}".format(_outdir))
        os.makedirs(_outdir)
    if not os.path.isdir(_outdir):
        print("    >  Failed to make a new directory")
        outdir_check = False
if not outdir_check:
    print("Error: There's invalid result directory path")
    sys.exit(1)

# Copy config to result directories for record
for bench in run_config['sets']:
    _outdir = bench['result_dir']
    if (bench['name'] in run_config['run']):
        os.system("cp {} {}".format(config_name, _outdir))
        print("{} -> {}".format(bench['name'], _outdir))

while(True):
    for bench in run_config['sets']:
        if not (bench['name'] in run_config['run']):
            continue
        if not is_run_bench[bench['name']]: # Run only if not started
            workload_n = len(bench['workloads'])
            #if workload_n <= get_remain_cpu_cores() - 2: # If enough cores are available, margin 5
            if workload_n <= get_remain_cpu_cores() + 4: # If enough cores are available, margin 5
                is_run_bench[bench['name']] = True # Benchmark set started
                bench_start_t[bench['name']] = datetime.datetime.now()
                print("\nRun {} =======================================".format(bench['name']))
                print("Datetime: {}".format(bench_start_t[bench['name']].strftime("%Y-%m-%d %H:%M:%S")))
                print("Available cores: {} / workload_count: {}".format(get_remain_cpu_cores(), workload_n))
                bench_run_func(bench, processes) # Run benchmarks
                print()
            else:
                break
    update_status_log(processes, run_config['log_file_path'])
    update_result_file()
    time.sleep(60)
    if not(any(process_info['proc'].poll() is None for group in processes.values() for process_info in group.values())) and all(status is True for status in is_run_bench.values()):
        all_done = True
        update_status_log(processes, run_config['log_file_path'])
        update_result_file()
        break

print("All benchmarks finished / datetime: {}".format(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
