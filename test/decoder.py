import re
import sys

#Result struct
data = {}

with open(sys.argv[1]) as f:
    # read first line
    line = f.readline()
    line = f.readline()
    
    while not line == '':
        # find througput
        pattern = re.compile(r'\s*Troughput\s*:\s*(.*)')
        match = re.match(pattern, line)
        t = ''
        if match:
            t = match.group(2)
            line = f.readline()
        else:
            print('Patter Buffer not found')

        # find buffer size
        pattern = re.compile(r'(.*)-b\s*(\w+)(.*)')
        match = re.match(pattern, line)
        b = ""
        if match:
            b = match.group(2)
        else:
            print('Patter Buffer not found')
        
        # find Processing size
        pattern = re.compile(r'(.*)-p\s*(\w+)(.*)')
        match = re.match(pattern, line)
        p = ""
        if match:
            p = match.group(2)
        else:
            print('Patter Processing not found')
    
        while line.find('Capture complete.') == -1:
            line = f.readline()
            
        line = f.readline()
    
        data[t,p,b] = {}
    
        pattern = re.compile(r'(.*)\s*:\s*([0-9]*\.[0-9]+|[0-9]+)\s*(.*)')
        while line.find('############################') == -1:
            match = re.match(pattern, line)
            if match:
                data[t,p,b][match.group(1)+" ("+match.group(3)+")"] = match.group(2)
            line = f.readline()
        line = f.readline()

#print(data)

rows = list(list(data.values())[0].keys())
columns = list(data.keys())

print("Througput", end="")
for c in columns:
    print(";{0}".format(c[0]),end="")
print("")
print("Processing", end="")
for c in columns:
    print(";{0}".format(c[1]),end="")
print("")
print("Buffer", end="")
for c in columns:
    print(";{0}".format(c[2]),end="")
print("")
for r in rows:
    print(r, end="")
    for c in columns:
        print(";{0}".format(data[c][r]), end="")
    print("")
print("Delay", end="")
for c in columns:
    data[c]["Delay (ms)"] = float(data[c]["Avg Waiting Time (ms)"]) + float(data[c]["Avg Buffer Time (ms)"]) + float(data[c]["Avg Transfer Time (ms)"]) + float(data[c]["Avg Processing Time (ms)"])
    print(";{0}".format(data[c]["Delay (ms)"]),end="")
print("")
print("SpeedUp Proc",end ="")
for c in columns:
    data[c]["SpeedUp Proc"] = float(data[c[0],'S','']["Avg Processing Time (ms)"]) / float(data[c]["Avg Processing Time (ms)"])
    print(";{0}".format(data[c]["SpeedUp Proc"]), end="")
print("")

print("SpeedUp Delay", end="")
for c in columns:
    data[c]["SpeedUp Delay"] = float(data[c[0],'S','']["Delay (ms)"]) / float(data[c]["Delay (ms)"])
    print(";{0}".format(data[c]["SpeedUp Delay"]), end="")
print("")

