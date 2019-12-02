%!xml2

" Grab site title
/^\/rss\/channel\/title=/s/^.*=//
d t

" Clear irrelevant fields
v/^\/rss\/channel\/item\/\(title\|link\|description\|pubDate\)/d

" Add heading
1i
<h2>
.
pu t
a
</h2>
.
-2,.j!
$a

.

function! MarkItem()
	i
=BEGIN
.
endfunction

function! ProcessItem()
	" Yank title
	/^.\{-}title=\?/s///
	d t
	?^=BEGIN

	" Yank link
	/^.\{-}link=\?/s///
	d l
	?^=BEGIN

	" Yank date
	/^.\{-}pubDate=\?/s///
	d p
	?^=BEGIN

	" Yank description
	/^.\{-}description=\?/s///
	d d
	?^=BEGIN

	" Put and edit link
	-1pu l
	i
<details>
	<summary>
.

	" Put date above link
	pu p

	" Format date
	s/^.*\(\d\d \w\w\w \d\d\d\d\).*$/<time>\1<\/time>/

	" Format link
	a
		<a href="
.
	j!
	a
">
.
	-1,.j!

	" Put title
	pu t
	s/^/			/

	" Close anchor
	a
		</a>
.

	a
	</summary>
.

	pu d
	s/^/	<p>/
	s/$/<\/p>/
a
</details>
.
endfunction

g/^\/rss\/channel\/item\/title=/:call MarkItem()
g/^=BEGIN/:call ProcessItem()
g/^\(=BEGIN\)\|\(\/rss\)/d
%p
