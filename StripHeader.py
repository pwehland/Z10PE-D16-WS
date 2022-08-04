import sys

if len(sys.argv) != 3:
    print("Usage: python3 decapify.py cap_filename extracted_header")
    sys.exit(0)

print("Reading CAP file:", sys.argv[1])
with open(sys.argv[1], 'rb') as f:
    cap = f.read()

print("Extracting Header from CAP file.")
header = cap[0:2048]

print("Writing extracted Header file:", sys.argv[2])
with open(sys.argv[2], 'wb') as f:
    f.write(header)

