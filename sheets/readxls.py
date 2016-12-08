import re
import sys
import openpyxl
from openpyxl import Workbook

### Create a workbook
wb = Workbook()

wb = openpyxl.load_workbook(sys.argv[1])

### Get the active worksheets (index 0)
ws = wb.active

### get the dimensions
mr = ws.max_row
mc = ws.max_column

print mr, mc

### Print the data for the whole sheet
for row in ws.iter_rows():
 for cell in row:
   if cell.value is not None:
     print cell.value,
 print
