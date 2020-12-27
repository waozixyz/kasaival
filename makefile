VERSION=0.1.0
LOVE_VERSION=11.3
NAME=change-me
ITCH_ACCOUNT=change-me-too
URL=https://gitlab.com/alexjgriffith/min-love2d-fennel
AUTHOR="Your Name"
DESCRIPTION="Minimal setup for trying out Phil Hagelberg's fennel/love game design process."

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))


run: $(OUT) ; love .

count: ; cloc *.fnl --force-lang=clojure

clean: ; rm -rf releases/* $(OUT)

cleansrc: ; rm -rf $(OUT)

%.lua: %.fnl; lua lib/fennel --compile --correlate $< > $@

LOVEFILE=releases/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(OUT) $(LIBS) #assets text
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL=$(PWD)/love-release.sh # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love $(LOVE_VERSION) --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

releases/$(NAME)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd appimage && ./build.sh $(LOVE_VERSION) $(PWD)/$(LOVEFILE)
	mv appimage/game-x86_64.AppImage $@

releases/$(NAME)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv releases/$(NAME)-macos.zip $@

releases/$(NAME)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv releases/$(NAME)-win32.zip $@

linux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
mac: releases/$(NAME)-$(VERSION)-macos.zip
windows: releases/$(NAME)-$(VERSION)-win.zip

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
