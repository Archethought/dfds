#
"""
Show how to create fake customer information
and write to a CSV file
"""
import csv
from faker import Factory

f = Factory.create()

with open('fakedata.csv', 'wb') as csvfile:
  csvwriter = csv.writer(csvfile, dialect='excel', delimiter=',', quotechar='"')
  csvwriter.writerow([f.name(),f.street_address(),f.email(),f.company()])
