# TODO
# - [X] Atom support
# - [X] Limit length
# - [X] Ignore certain feeds
# - Folder categories support

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
	@(ex --clean -n $^ < parse-rss.vim > $@; true) # Suppress Ex errors

html/index.html: templates/base.html $(call sourcetohtml,$(SOURCES))
	# Sorting dependencies and building $@…
	@cp templates/base.html $@
	@# Sort feeds by most recent posts
	@for f in $(filter-out templates/%,$^); do echo $(call lastpubdate,$$f) $$f; done | sort -r | cut -d\  -f2 | while read feed; do \
		cat $$feed >> $@ ;  \
	done

clean:
	rm -rf rss/* html/*
	touch sources/*
