import os,shutil,sys,time
sys.path.append(os.path.join(os.path.split(os.path.realpath(__file__))[0],"../Code"))
import bot


class DoStuffToFiles():
	UBUS_XPAD        = 0
	UBUS_YPAD        = 182
	FIX_REZ_X_PAD    = 0
	FIX_REZ_Y_PAD    = 0


	def fix_resolution(self):

		res_fix = bot.Bot(self.FIX_REZ_XPAD, self.FIX_REZ_YPAD)
		res_fix.mousePos((1655, 48))
		res_fix.left_click()
		time.sleep(0.1)
		res_fix.mousePos((1534, 122))
		res_fix.left_click()
		time.sleep(0.1)
		res_fix.mousePos((0,0))
		res_fix.left_click()

	def refresh_router(self):
 
		
		rmb = bot.Bot(self.UBUS_XPAD, self.UBUS_YPAD)
		
		rmb.open_web_page(self.ROUTER_LOCATION)

		time.sleep(1)
		self.fix_resolution()
		
		time.sleep(1)
		
		rmb.mousePos((870,252))
		rmb.left_click()
	
		time.sleep(0.1)
	
		letters = list(self.ROUTER_USER_NAME)
		for letter in letters:
			rmb.key_board(letter)
		
		time.sleep(0.1)
	
		rmb.key_board("tab")
	
		time.sleep(0.1)
		
		letters = list(self.ROUTER_PASSWORD)
		for letter in letters:
			rmb.key_board(letter)
		
		rmb.key_board("enter")
	
		time.sleep(1)
	
		rmb.mousePos((59, 206))
		rmb.left_click()
	
		time.sleep(1)
		
		rmb.mousePos((59, 282))
		rmb.left_click()
	
		time.sleep(2)
		
		rmb.mousePos((512, 169))
		rmb.left_click()
		sys.exit()
