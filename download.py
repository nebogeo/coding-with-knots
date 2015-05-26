# script for downloading quipu

import urllib

for i in range(1,999):
    num = ("%03d"%i)
    filename = "UR"+num+".xls"
    print(filename)
    url = "http://khipukamayuq.fas.harvard.edu/DataTables/UR%20%3C1000%20data%20tables/"+filename
    urllib.urlretrieve (url, filename)
