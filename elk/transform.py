import csv

reader = csv.reader(open("/data/data.csv"), delimiter=',')
writer = csv.writer(open("/data/output.csv", "w"), delimiter=',', lineterminator='\n')

# fix up the header since we are merging date and time into one field
headers = reader.next()[1:]
headers[0] = "dateTime"

writer.writerow( headers)

for row in reader:
	newRow = [row[0] + " " + row[1]] + row[2:]
	writer.writerow(newRow)
