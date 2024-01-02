import sys
import subprocess


def write_stdout(s):
    sys.stdout.write(s)
    sys.stdout.flush()


def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


def main():
    while 1:
        write_stdout('READY\n') # transition from ACKNOWLEDGED to READY
        line = sys.stdin.readline()  # read header line from stdin
        write_stderr(line) # print it out to stderr
        headers = dict([ x.split(':') for x in line.split() ])
        data = sys.stdin.read(int(headers['len'])) # read the event payload
        write_stderr(data) # print the event payload to stderr
        data = dict([x.split(':') for x in data.split()])

        write_stdout('RESULT 2\nOK') # transition from READY to ACKNOWLEDGED

        print("\n", headers, data, "\n", file=sys.stderr, flush=True)

        if ((headers["eventname"] == "PROCESS_STATE_FAILED")
                or (headers["eventname"] == "PROCESS_STATE_FATAL")
                or (headers["eventname"] == "PROCESS_STATE_EXITED" and data["processname"] == "papermc")):
            subprocess.call(["pkill", "-15", "supervisord"])


if __name__ == '__main__':
    main()
    import sys
    import subprocess
