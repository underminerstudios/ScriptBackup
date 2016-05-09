import sys, pprint

from pysideuic import compileUi


class Convert_Ui():
    '''
    nice little helper that converts .ui files to .py files in maya. local doesn't even need a version of the file
    because the inport is done after 
    '''

    def convert(self,input_name,output_name):
        #yes open the output file
        pyfile = open(output_name, 'w')
        #let's compile the input file
        compileUi(input_name, pyfile, False, 4,False)
        pyfile.close()