from __future__ import division
import math

## simple measurement of entropy

def hist(source):
    hist = {}; l = 0;
    for e in source:
        l += 1
        if e not in hist:
            hist[e] = 0
        hist[e] += 1
    return (l,hist)

def entropy(hist,l):
    elist = []
    for v in hist.values():
        c = v / l
        elist.append(-c * math.log(c ,2))
    return sum(elist)

source = "222222222222222222122"
(l,h) = hist(source);
print 'Entropy:', entropy(h, l)
