.DEFAULT_GOAL := help
USER ?= USERNAME_GOES_HERE
PASSWORD ?= PASSWORD_GOES_HERE

install: install-apt alsa-config install-spotifyd config-spotifyd systemd-spotifyd enable-spotifyd  ## Install and configure spotifyd (first set USER and PASSWORD here

install-apt: /usr/bin/unzip
/usr/bin/unzip:
	sudo apt install unzip

alsa-config: /etc/asound.conf ## Configure alsa to use the usb audio device
/etc/asound.conf:
	sudo cp ./config/asound.conf /etc/asound.conf

install-spotifyd: /usr/local/bin/spotifyd
/usr/local/bin/spotifyd:
	wget https://github.com/Spotifyd/spotifyd/releases/download/v0.2.5/spotifyd-2019-02-25-armv6.zip
	unzip ./spotifyd-2019-02-25-armv6.zip
	sudo mv ./spotifyd /usr/local/bin/

config-spotifyd: /etc/spotifyd.conf  ## Install the spotifyd configuration SET USER and PASSWORD IN THIS FILE FIRST
/etc/spotifyd.conf:
	sed -i 's/USER/$(USER)/' ./config/spotifyd.conf
	sed -i 's/PASSWORD/$(PASSWORD)/' ./config/spotifyd.conf
	sudo cp ./config/spotifyd.conf /etc/spotifyd.conf

systemd-spotifyd: /etc/systemd/user/spotifyd.service
/etc/systemd/user/spotifyd.service:
	sudo cp ./config/spotifyd.service /etc/systemd/user/spotifyd.service

enable-spotifyd: systemd-spotifyd /home/pi/.config/systemd/user/default.target.wants/spotifyd.service ## Enable the spotifyd service
/home/pi/.config/systemd/user/default.target.wants/spotifyd.service:
	systemctl --user enable spotifyd.service
	systemctl --user start spotifyd.service

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

