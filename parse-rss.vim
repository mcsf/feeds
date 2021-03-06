%!xml2

" Grab site title
/^\/\(rss\/channel\|feed\)\/title=/s/^.*=//
d t

" Demarcate each feed item with "=BEGIN"
function! MarkItem()
	i
=BEGIN
.
endfunction
g/^\/\(rss\/channel\/item\|feed\/entry\)$/:call MarkItem()
1/^\/\(rss\/channel\/item\|feed\/entry\)/:call MarkItem()

" Clear irrelevant fields
v/^\(=BEGIN\|\/\(rss\/channel\/item\|feed\/entry\)\/\(title\|link\|description\|summary\|pubDate\|published\)\)/d

" Limit long feeds to 10 items
function! TakeFirstN(total, pattern)
	let n = a:total - 1
	while n > 0
		let n = n - 1
		call search(a:pattern, "W")
	endwhile
	if search(a:pattern, "W")
		.,$d
	else
	endif
endfunction
1
call TakeFirstN(10, "^=BEGIN")

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

" Turn each feed item into formatted HTML
function! ProcessItem()
	" Yank title
	/^\/\(rss\/channel\/item\|feed\/entry\)\/title=\?/s///
	d t
	?^=BEGIN

	" Yank link
	/^\(\/rss\/channel\/item\/link=\?\|\/feed\/entry\/link\/@href=\)/s///
	d l
	?^=BEGIN

	" Yank date
	try
		" RSS
		/^\/rss\/channel\/item\/pubDate=\?/s///
	catch /Pattern not found/
		" Atom
		try
			/^\/feed\/entry\/published=\?/s///
			s/Z/+0000/
			s/\(-\|+\)\(\d\d\):\(\d\d\)/\1\2\3
			.%!while read date; do LANG=C date -jf '\%Y-\%m-\%dT\%H:\%M:\%S\%z' $date +"\%d \%b \%Y"; done
		catch /Pattern not found/
		endtry
	endtry
	d p
	?^=BEGIN

	" Yank description
	try
		" RSS
		/^\/rss\/channel\/item\/description=\?/s///
		d d
		?^=BEGIN
	catch /Pattern not found/
		" Atom
		$y d
	endtry

	" Put and edit link
	-1pu l
	i
<details>
	<summary>
.

	" Put date above link
	pu p

	" Format date
	try
		s/^.*\(\d\d \w\w\w \d\d\d\d\).*$/		<time>\1<\/time>/
	catch /Pattern not found/
	endtry

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
	s/^$/(untitled)/
	s/^/			/

	" Close anchor
	a
		</a>
.

	a
	</summary>
.

	try
		pu d
	endtry
	s/^/	<p>/
	s/$/<\/p>/
a
</details>
.
endfunction

g/^=BEGIN/:call ProcessItem()

" Clean up and print
g/^\(=BEGIN\)\|\(\/\(rss\|feed\)\)/d
%p
