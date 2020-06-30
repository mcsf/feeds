#.ONESHELL:

MAKEFLAGS += -j6
SOURCES = $(filter-out sources/.%,$(shell find -s sources -type f))

sourcetohtml = $(subst sources/,html/,$(addsuffix .html,$(1)))
lastpubdate = $$(LANG=C date -jf '%d %b %Y' "$$(grep -m1 '<time>' < $(1) | sed -e 's/^.*\([0-9][0-9] [A-z][A-z][A-z] [0-9][0-9][0-9][0-9]\).*$$/\1/')" +"%s" )

all: init html/index.html

init:
	@mkdir -p rss html

.SECONDARY: # Preserve RSS files for possible debugging
rss/%: sources/%
	# Fetching $@…
	@curl $$(cat $^) > $@ 2>/dev/null

html/%.html: rss/%
	# Building $@…
	@if grep -q . $^ ; then \
		(ex --clean -n $^ < parse-rss.vim > $@; true) ; \
	else \
		echo "<!-- <time>01 Jan 1970</time> -->" > $@ ; \
	fi

html/index.html: templates/base.html $(call sourcetohtml,$(SOURCES))
	# Sorting dependencies and building $@…
	@cp templates/base.html $@
	@# Sort feeds by most recent posts
	@for f in $(filter-out templates/%,$^); do echo $(call lastpubdate,$$f) $$f; done | sort -r | cut -d\  -f2 | while read feed; do \
		cat $$feed >> $@ ;  \
	done
	@echo "</main><footer>Last updated: <time>$$(LANG=C date)</time>" >> $@

clean:
	rm -rf rss/* html/*
	touch sources/*
