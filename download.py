# script for downloading quipu

import urllib

for i in range(0,32):
    num = ("%03d"%i)
    filename = "HP"+num+".xls"
    print(filename)
    #url = "http://khipukamayuq.fas.harvard.edu/DataTables/UR%20%3C1000%20data%20tables/"+filename
    url = "http://khipukamayuq.fas.harvard.edu/DataTables/HP%20data%20tables/"+filename
    urllib.urlretrieve (url, filename)
