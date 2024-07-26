import sys
import numpy as np

with open('part_0.keys', 'rb') as f:
  keys = np.fromfile(f, dtype=np.int64)
with open('part_0.vals', 'rb') as f:
  vals = np.fromfile(f, dtype=np.float32)

if not vals.size % keys.size == 0:
  print('Corrupted files.')
  sys.exit(1)
dim = int(vals.size / keys.size)

for i, k in enumerate(keys):
  val = vals[i * dim : i * dim + dim]
  print(f'key: {k}, val: {val}')
