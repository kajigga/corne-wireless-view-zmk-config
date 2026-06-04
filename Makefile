clear:
	rm -fv *.uf2
download: clear
	gh run download -n firmware

# right:
#
# left:
#
# flash: 
# 	cp "corne_left nice_view_adapter nice_view-nice_nano_v2-zmk.uf2" 
# 	cp "corne_right nice_view_adapter nice_view-nice_nano_v2-zmk.uf2"

