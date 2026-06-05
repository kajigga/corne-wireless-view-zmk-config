LEFT_FW  := corne_left nice_view_adapter nice_view-nice_nano_v2-zmk.uf2
RIGHT_FW := corne_right nice_view_adapter nice_view-nice_nano_v2-zmk.uf2
RUN_ID_FILE := .run_id

.PHONY: clear push watch download flash

clear:
	rm -fv *.uf2 $(RUN_ID_FILE)

push:
	git push origin master

watch:
	@OLD=$$(gh run list --branch master --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null); \
	MAX=40; i=0; \
	while [ $$i -lt $$MAX ]; do \
		RUN=$$(gh run list --branch master --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null); \
		if [ -n "$$RUN" ] && [ "$$RUN" != "null" ] && [ "$$RUN" != "$$OLD" ]; then \
			echo "$$RUN" > $(RUN_ID_FILE) && \
			exec gh run watch "$$RUN"; \
		fi; \
		i=$$((i + 1)); \
		sleep 3; \
	done; \
	echo "Timed out waiting for a new run after 2 minutes" >&2; \
	exit 1

download: clear push watch
	RUN_ID=$$(cat $(RUN_ID_FILE)) && \
	rm -f $(RUN_ID_FILE) && \
	gh run download "$$RUN_ID" -n firmware

# flash: download
flash:
	@echo "Put the LEFT half into bootloader mode..."
	@until [ -d "/Volumes/NICENANO" ]; do sleep 1; done
	cp "$(LEFT_FW)" /Volumes/NICENANO/
	@echo "Left half flashed! Waiting for disconnect..."
	@until [ ! -d "/Volumes/NICENANO" ]; do sleep 1; done
	@sleep 1
	@echo "Put the RIGHT half into bootloader mode..."
	@until [ -d "/Volumes/NICENANO" ]; do sleep 1; done
	cp "$(RIGHT_FW)" /Volumes/NICENANO/
	@echo "Right half flashed! Done."
