from selenium import webdriver

driver = webdriver.Firefox()
driver.get('http://google.com')

ids = driver.find_elements_by_xpath('//*[@id]')
for ii in ids:
    #print ii.tag_name
    print ii.get_attribute('id')