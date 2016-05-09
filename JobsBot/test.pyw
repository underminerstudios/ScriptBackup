from PIL import ImageGrab, ImageOps
import os
import time
import win32api
from numpy import *

x_pad = 0
y_pad = 182
USA = 14983
 
def screenGrab(x1,y1,x2,y2):
    box = (x1,y1,x2,y2)
    im = ImageGrab.grab(box)
    im.save(os.getcwd() + '\\full_snap__' + str(int(time.time())) + '.png', 'PNG')
    return 

def get_color(x1,y1,x2,y2):
    box = (x1,y1,x2,y2)
    im = ImageOps.grayscale(ImageGrab.grab(box))
    a = array(im.getcolors())
    a = a.sum()
    print a
    im.save(os.getcwd() + '\\login' + '.png', 'PNG')   
    return a

 
def mousePos(cord):
    win32api.SetCursorPos((x_pad + cord[0], y_pad + cord[1]))
     
def get_cords():
    x,y = win32api.GetCursorPos()
    x = x - x_pad
    y = y - y_pad
    print x,y
 
current_location = get_color(1043,684,1202,717)
if current_location == USA:
    print "yup"
#get_cords()
#screenGrab(1600, 40, 1680, 80)