from lxml import etree
import xml.etree.ElementTree as ET
import os

xml_dir = '2011/'
files = [xml_dir + f for f in os.listdir(xml_dir)]

sum = 0

for f in files:
    tree = ET.parse(f)
    root = tree.getroot()
    award = root[0]
    amount = award.find('AwardAmount').text
    
    sum = sum + int(amount)

average = sum/len(files)

print(average)
    
