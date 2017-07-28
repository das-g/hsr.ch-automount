.PHONY: install
install: configuration binaries
	sudo service autofs reload

.PHONY: configuration
configuration: ~/.hsr.ch/samba-user /etc/auto.hsr-alg /etc/auto.master.d/hsr.autofs

.PHONY: change-hsr-pw
change-hsr-pw:
	$(MAKE) --always-make ~/.hsr.ch/samba-user
	$(MAKE) install

~/.hsr.ch/samba-user: etc/samba/hsr-user
	@mkdir -p $(@D)
	@echo
	@echo HSR Password will be saved in $@
	@echo
	@echo You can update it with
	@echo "\t"$(MAKE) change-hsr-pw
	@echo
	touch $@
	sudo chmod 0020 $@
	sudo chown root $@
	@sed -e 's/^\(password=\)/\1$(HSR_PASSWORD)/' < $< > $@

etc/samba/hsr-user: etc/samba/hsr-user.dist
	sed -e 's/^\(username=\)/\1$(HSR_USERNAME)/' < $< > $@

/etc/auto.hsr-alg: etc/auto.hsr-alg
	@sudo mkdir -p $(@D)
	sudo cp -i $< $@

/etc/auto.master.d/hsr.autofs: etc/auto.master.d/hsr.autofs | /etc/auto.master
	@grep -E '^\+dir:/etc/auto.master.d$$' $|
	@sudo mkdir -p $(@D)
	sudo cp -i $< $@

HSR_USERNAME ?= $(shell read -p "HSR Username: " pwd; echo $$pwd)
HSR_PASSWORD ?= $(shell stty -echo; read -p "HSR Password: " pwd; stty echo; echo $$pwd)

.PHONY: binaries
binaries: /sbin/mount.cifs /usr/sbin/automount

/sbin/mount.cifs:
	sudo apt install cifs-utils

/usr/sbin/automount:
	sudo apt install autofs

/etc/auto.master: /usr/sbin/automount
