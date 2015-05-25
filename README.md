#Coding with knots

Quipu parsing code for reading the [Khipu Database Project](http://khipukamayuq.fas.harvard.edu/) files.
This project is an side thread of the [weavingcodes](http://kairotic.org) project.

![](https://github.com/nebogeo/khipu-parser/raw/master/UR113 Valhalla_jpg.jpg)

##Requirements

* [python](https://www.python.org/)
* [python-xlrd](https://pypi.python.org/pypi/xlrd) for reading excel spreadsheets
* [graphviz](http://www.graphviz.org/) for rendering graphs

##Usage

Command line:

    $ python quipu2dot.py
    $ dot quipu.dot -tPNG > quipu.png
