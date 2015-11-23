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

def calc(source):
    (l,h) = hist(source)
    return entropy(h,l)

def unit_test():
    assert(calc("00000000000000000")==0)
    assert(calc("zzzz")==0)
    assert(calc("zzzzzzzzzzzzzzzzzzzzzzz")==0)

unit_test()
