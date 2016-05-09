import os

folder = "Y:\\"

for root,dirs,files in os.walk(folder):
	for file_to_kill in files:
		if file_to_kill.endswith('sync'):
			make_full_name = os.path.join(root,file_to_kill)
			os.remove(make_full_name)