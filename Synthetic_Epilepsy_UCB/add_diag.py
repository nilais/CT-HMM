import csv

ls_rows = []
with open('hmm.csv') as csvfile:
    csvreader = csv.reader(csvfile, delimiter=',')
    for row in csvreader:
        row = [float(i) for i in row]
        ls_rows.append(row)

N = len(ls_rows)

for i in range(N):
    ls_rows[i][2]*=10000
    ls_rows[i][2]=int(ls_rows[i][2])
    ls_rows[i][2]='DIAG_'+str(ls_rows[i][2])
    diag = ls_rows[i][2]
    time = ls_rows[i][1]
    ls_rows[i][1] = diag
    ls_rows[i][2] = int(time)
    ls_rows[i].append(1)

with open('hmm-diag.csv','wb') as csvfile:
    csvwriter = csv.writer(csvfile, delimiter=',')
    for row in ls_rows:
        csvwriter.writerow(row)
    

