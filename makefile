VERSION=0.1.4
LOVE_VERSION=11.3
NAME=Kasaival
ITCH_ACCOUNT=waotzi
URL="https://kasaival.rocks"
AUTHOR="Wolfi"
DESCRIPTION="Survival adventure game. Out of nowhere you have come to exist. The fire is burning inside you, but you feel it diminishing. Stay alive as long as you can! Do whatever it takes to keep your flame burning!"

ASSETS := $(wildcard assets/*)
LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)

run: love .

clean: ; rm -rf releases/* 

LOVEFILE=releases/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(LIBS) $(ASSETS)
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@


love: $(LOVEFILE)

# platform-specific distributables

REL=$(PWD)/love-release.sh # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love $(LOVE_VERSION) --url $(URL) -v $(VERSION) --lovefile $(LOVEFILE) 

releases/$(NAME)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd appimage && ./build.sh $(LOVE_VERSION) $(PWD)/$(LOVEFILE)
	mv appimage/game-x86_64.AppImage $@

releases/$(NAME)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv releases/$(NAME)-macos.zip $@

releases/$(NAME)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv releases/$(NAME)-win32.zip $@

releases/$(NAME)-$(VERSION).apk: $(LOVEFILE)
	$(REL) $(FLAGS) -A
	mv releases/$(NAME)-aligned-debugSigned.apk $@

linux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
mac: releases/$(NAME)-$(VERSION)-macos.zip
windows: releases/$(NAME)-$(VERSION)-win.zip
android: releases/$(NAME)-$(VERSION).apk

# If you release on itch.io, you should install butler:
# https://itch.io/docs/butler/installing.html

uploadlinux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):linux --userversion $(VERSION)
uploadmac: releases/$(NAME)-$(VERSION)-macos.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):mac --userversion $(VERSION)
uploadwindows: releases/$(NAME)-$(VERSION)-win.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):windows --userversion $(VERSION)

upload: uploadlinux uploadmac uploadwindows

release: linux mac windows upload cleansrc
