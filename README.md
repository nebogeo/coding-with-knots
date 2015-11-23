#Coding with knots
 
Quipu parsing code for reading the [Khipu Database Project](http://khipukamayuq.fas.harvard.edu/) files.
This project is a side thread of the [weavingcodes](http://kairotic.org) project.

![](https://github.com/nebogeo/khipu-parser/raw/master/UR113 Valhalla_jpg.jpg)

##Requirements

* [python](https://www.python.org/)
* [python-xlrd](https://pypi.python.org/pypi/xlrd) for reading excel spreadsheets
* [graphviz](http://www.graphviz.org/) for rendering graphs

##Usage

###Generating dot files and PNGs

Individual xls spreadsheet:

    $ ./quipu2dot.py UR001.xls
    $ dot UR001.xls.dot -Tpng > UR001.png

Batch mode, does convertion and runs dot (assumes location is data/xls):

    $ ./quipu2dot.py batch

###Measuring entropy command line

Single quipu:

    $ ./quipu2entropy.py UR001.xls

A test string:

    $ ./quipu2entropy.py test AAABBB

Batch mode, as above assumes location is data/xls - prints sorted list:

    $ ./quipu2entropy.py batch
