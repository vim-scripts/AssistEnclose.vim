let g:FileTypeList = ['python','c','cpp','matlab','javascript','vim'] " supporting languages
fun DecisionFT()
	for support in g:FileTypeList
		let decision = 0
		if &ft == support
			let decision += 1
		endif
	endfor
	if decision == 0	" if [not] in programming env (in text edit) (or latex )
		let g:ListForQuote    = ['.','!','~','h','?']	" char to include for quotes
		let g:ListForBracket  = ["'",'"','h','.',':']	" char to include for brackets
		let g:ListForSnippets = ['!','~','?',',','.'] 	" char to include for snippets
	else   				" if in <programming> env
		let g:ListForQuote    = []	" char to include for quotes
		let g:ListForBracket  = []	" char to include for brackets
		let g:ListForSnippets = [] 	" char to include for snippets
	endif
	if &filetype is 'vim'
		let g:ListForQuote    = ['$']	" char to include for quotes
		let g:ListForBracket  = ['$']	" char to include for brackets
	endif
endfun
au BufRead,GuiEnter * call DecisionFT()
" Or you can manually modify the character to include when manipulating specific filetype language one by one.
" like following
" if &ft == 'python'
" let g:ListForQuote    = ['.','!','~','h','?']	" char to include for quotes
" let g:ListForBracket  = ["'",'"','h','.',':']	" char to include for brackets
" let g:ListForSnippets = ['!','~','?',',','.'] 	" char to include for snippets
" elseif &ft == 'c'
" let g:ListForQuote    = ['.','!','~','h','?']	" char to include for quotes
" let g:ListForBracket  = ["'",'"','h','.',':']	" char to include for brackets
" let g:ListForSnippets = ['!','~','?',',','.'] 	" char to include for snippets
" ...
" endif

let g:ListBra = [')','(']
let g:ListSha = ['>','<']
let g:ListCur = ['}','{']
let g:ListRec = [']','[']

" priority order : 		{...}	⊃   (...) 	 ⊃	  <...>   ⊃ 	[...] 
" This order will be used in "blow out things at once in brackets" function (DeleteInBraOnce)
let g:ListBraTotal = [g:ListCur,g:ListBra,g:ListSha,g:ListRec]

let g:ListDuo = ['"','"']
let g:ListSma = ["'","'"]


fun DeleteInQuoteOnce(avoid)
	let avoid      = a:avoid
	let avoid_cmp1 = [a:avoid[0],a:avoid[0]]
	let avoid_cmp2 = [a:avoid[1],a:avoid[1]]

	let safe1      = SafetyCheckIsOK(avoid_cmp1,'normal')
	let safe2      = SafetyCheckIsOK(avoid_cmp2,'normal')

	if safe1
		let index = 0
	elseif safe2
		let index = 1
	else
		"echo 'It cannot be erased!!'
		"echo avoid_cmp1[0] . ' ' . avoid_cmp1[1]
	endif

	if safe1 + safe2 == 1
		while     getline('.')[col('.')]   != avoid[index]
			normal x
		endwhile

		while     getline('.')[col('.')-2] != avoid[index]
			normal dh
		endwhile
		normal x
	elseif safe1 * safe2
		while     getline('.')[col('.')]   != avoid[1]
			normal x
		endwhile

		while     getline('.')[col('.')-2] != avoid[1]
			normal dh
		endwhile
		normal x

	endif
endf

"let g:ListBraTotal = [g:ListCur,g:ListBra,g:ListSha,g:ListRec]
" {} () <> []
fun DeleteInBraOnce(avoid)
	let avoid = a:avoid
	let safe1 = SafetyCheckIsOK(avoid[0],'normal') " ()
	let safe2 = SafetyCheckIsOK(avoid[1],'normal') " <>
	let safe3 = SafetyCheckIsOK(avoid[2],'normal') " {}
	let safe4 = SafetyCheckIsOK(avoid[3],'normal') " []

	if safe1

		" to the right
		while ( getline ('.')[col('.')]     != avoid[0][0] )
			normal x
		endwhile

		" to the left
		while ( getline ('.')[col('.') -2 ] != avoid[0][1] )
			normal dh
		endwhile

		normal x

	elseif safe2
		" to the right
		while ( getline ('.')[col('.')]     != avoid[1][0] )
			normal x
		endwhile

		" to the left
		while ( getline ('.')[col('.') -2 ] != avoid[1][1] )
			normal dh
		endwhile

		normal x
	elseif safe3
		" to the right
		while ( getline ('.')[col('.')]     != avoid[2][0] )
			normal x
		endwhile

		" to the left
		while ( getline ('.')[col('.') -2 ] != avoid[2][1] )
			normal dh
		endwhile

		normal x
	elseif safe4

		" to the right
		while ( getline ('.')[col('.')]     != avoid[3][0] )
			normal x
		endwhile

		" to the left
		while ( getline ('.')[col('.') -2 ] != avoid[3][1] )
			normal dh
		endwhile

		normal x

	else

		echo 'Not proper place!'
	endif
endf

fun DeleteContents(avoid,mode) range
	if SafetyCheckIsOK(a:avoid,a:mode)
		while getline('.')[col('.')] != a:avoid[0]
			normal x
		endwhile
		while getline('.')[col('.')-2] != a:avoid[1]
			normal dh
		endwhile
		normal x
	endif
endf

fun SafetyCheckIsOK(arg,mode)

	let bang            = a:arg
	let left_bang       = bang[1]
	let right_bang      = bang[0]
	let left_bounded    = 0
	let right_bounded   = 0

	let current_line    = getline('.')
	let current_col_ref = col('.') - 1

	if a:mode is 'visual'
		let col_left        = col("'<")+2 " include quotes or brackets
		let col_right       = col("'>")-3 " (+)consider $ character
	elseif a:mode is 'normal'
		let col_left        = current_col_ref
		let col_right       = current_col_ref
	endif

	let same_bang = (left_bang == right_bang)

	while !left_bounded

		if col_left < col("^") + 1
			break
		endif

		if same_bang
			if current_line[col_left-1] is left_bang
				let left_bounded = 1
				break
			else
				let col_left = col_left -1
			endif
		else
			if current_line[col_left-1] is right_bang
				break
			elseif current_line[col_left-1] is left_bang
				let left_bounded = 1
			else
				let col_left = col_left -1
			endif
		endif
	endwhile

	while !right_bounded
		if col_right> col("$") - 1
			break
		endif
		if same_bang
			if current_line[col_right+1] is right_bang
				let right_bounded = 1
				break
			else
				let col_right = col_right+1
			endif
		else
			if current_line[col_right+1] is left_bang
				break
			elseif current_line[col_right+1] is right_bang
				let right_bounded = 1
			else
				let col_right = col_right+1
			endif
		endif
	endwhile

	"let ok = right_bounded * left_bounded
	"echo ok
	return right_bounded * left_bounded
endf

fun EraseEncaps(arg,mode) range
	let sav_pos          = getpos('.')
	let line_text        = getline('.')
	let current_col_ref  = col('.')
	let left_bang        = a:arg[1]
	let right_bang       = a:arg[0]
	let col_end          = col('$')-1
	let col_start        = col('^')+1

	if a:mode is 'visual'
		let col_to_right = col("'>")-1
		let col_to_left  = col("'<")+1
	elseif a:mode is 'normal'
		let col_to_right = current_col_ref
		let col_to_left  = current_col_ref
	endif

	if SafetyCheckIsOK(a:arg,a:mode)

		if a:mode is 'visual'
			call cursor(line("'>"),col("'>"))
		elseif a:mode is 'normal'
			call setpos('.',sav_pos)
		endif

		while line_text[col('.')-1] != right_bang && col_to_right < col_end 
			normal l
		endwhile
		normal x

		if a:mode is 'visual'
			call cursor(line("'<"),col("'<"))
		elseif a:mode is 'normal'
			call setpos('.',sav_pos)
		endif

		while line_text[col('.')-1] != left_bang && col_to_left > col_start
			normal h
		endwhile
		normal x
	else
		echo "Can't erase outer encaps."
	endif
	call setpos('.',sav_pos)
endf


fun WordsBracket(arg) range
	let lin_ref = line('.')
	let col_ref = col('.')

	let cnt = a:arg
	let stand_alone = (col_ref == col('$') -1)
	if stand_alone
		normal bi(
	else
		normal ebi(
	endif
	if cnt > 1
		while cnt - 1
			normal e
			let cnt = cnt - 1
		endwhile
	endif
	normal ea)
	call cursor(lin_ref,col_ref)
endf

fun WordsEncapsN(encapsList,includeMap)
	call Workaroundautoclose('open')
	let pos          = getpos('.')
	let left_encaps  = a:encapsList[1]
	let right_encaps = a:encapsList[0]
	let include		 = a:includeMap

	normal wb
	let existsInclude = SearchBackSpot(include)

	exe "normal i" . left_encaps

	if !existsInclude
		normal e
	else
		normal le
	endif
	call SearchNextSpot(include)

	exe "normal a" . right_encaps

	call setpos('.',pos)
	call Workaroundautoclose('close')
	" redraw!
endf

fun CoreExample()
	nmap x <Plug>ToggleautocloseMappings
	normal x
	exe 'nunmap x'
endf

let g:switched = 0
fun Workaroundautoclose(arg)
	let status = a:arg
	if exists('g:autoclose_loaded')
		if g:autoclose_on && status == 'open' 
			call CoreExample()
			let g:switched = !g:switched
		elseif g:switched && status == 'close'
			call CoreExample()
			let g:switched = !g:switched
		endif
	endif
endf

fun WordsEncapsV(encapslist,includeMap,mode) range

	call Workaroundautoclose('open')

	let left_encaps  = a:encapslist[1]
	let right_encaps = a:encapslist[0]
	let include      = a:includeMap
	let mode         = a:mode
	" let V = 0

	if mode == 'each'

		let start_lin = line ( "'<")
		let end_lin   = line ( "'>")
		let start_col = col  ( "'<")
		let end_col   = col  ( "'>")
		let lin_num = end_lin - start_lin + 1
		for i in range(lin_num)

			call cursor(start_lin+i,col("'<"))
			normal wb
			let existsInclude = SearchBackSpot(include)
			exe "normal i" . left_encaps

			call cursor(start_lin+i,col("'>"))
			normal be
			call SearchNextSpot(include)    
			exe "normal a" . right_encaps
		endfor

		call cursor(line("'<"),col("'<"))
	elseif mode == 'onepair'
		call cursor(line("'<"),col("'<"))
		if col("'<")==1
			if getline('.')[0] == ' ' || getline('.')[0] == "\<TAB>"
				normal w
			endif
		else
			normal wb
		endif
		let existsInclude = SearchBackSpot(include)
		exe "normal i" . left_encaps

		call cursor(line("'>"),col("'>"))

		if !existsInclude
			if col("'>") < col('$')
				normal e
			endif
		else
			normal le
		endif
		call SearchNextSpot(include)    

		if col("$") == col("'>")
			normal h
		endif

		exe "normal a" . right_encaps
		call cursor(line("'<"),col("'<"))
	endif
	call Workaroundautoclose('close')
	" redraw!
endf


fun SearchNextSpot(toInclude) 
	let ListForQuote = a:toInclude
	let spot = getline('.')[col('.')]
	let gotit = 0
	for si in ListForQuote
		if spot is si
			normal l
			call SearchNextSpot(ListForQuote)
			let gotit = 1
		endif
	endfor
	return gotit
endf
fun SearchBackSpot(toInclude) 
	let ListForQuote = a:toInclude
	let spot = getline('.')[col('.')-2]
	let gotit = 0
	for si in ListForQuote
		if spot is si && col('.') != 1
			normal h
			call SearchBackSpot(ListForQuote)
			let gotit = 1
		endif
	endfor
	return gotit
endf

fun SearchNextSpotSmall(sp,a1,a2,a3) 
	let spot = a:sp
	let s1 = a:a1
	let s2 = a:a2
	let s3 = a:a3
	let spot = getline('.')[col('.')]
	if spot is s1 || spot is s2 || spot is s3
		normal l
		call SearchNextSpotSmall(spot,s1,s2,s3)
	else
		normal a'
	endif
endf

fun WordsEmphasizeV(arg)
	call Workaroundautoclose('open')
	let option = a:arg

	call cursor(line("'>"),col("'>"))
	if getline('.')[col('.')] != ' '
		normal e
	endif

	call SearchNextSpot(g:ListForSnippets)
	if &ft == 'html'
		normal a</em>
	elseif &ft == 'tex'
		normal a}
	endif

	call cursor(line("'<"),col("'<"))
	if getline('.')[col('.')-2] != ' '
		normal b
	endif
	call SearchBackSpot(g:ListForSnippets)
	if &ft == 'html'
		normal i<em>
		let after = 0
	elseif &ft == 'tex'
		let after = 2
		if option == 0
			normal i\emph{
			let after = 1
		elseif option == 1
			normal i\textcolor{red}{
		elseif option == 2
			normal i\textcolor{magenta}{
		elseif option == 3
			normal i\textcolor{blue}{
		elseif option == 4
			normal i\textcolor{cyan}{
		elseif option == 5
			normal i\textcolor{green}{
		endif
	endif
	call cursor(line("'<"),col("'<"))
	if after == 0
		normal f>l
	elseif after == 1
		normal f{l
	elseif after == 2
		normal f{;l
	endif
	call Workaroundautoclose('close')
endf
fun WordsEmphasize(arg) range
	let pos = getpos('.')
	call Workaroundautoclose('open')
	let option = a:arg

	if getline('.')[col('.')] != ' '
		normal e
	endif

	call SearchNextSpot(g:ListForSnippets)
	" normal a</em>
	if &ft == 'html'
		" normal i<em>
		normal a</em>
	elseif &ft == 'tex'
		normal a}
	endif

	call setpos('.',pos)

	if getline('.')[col('.')-2] != ' '
		normal b
		" normal wb
	endif
	call SearchBackSpot(g:ListForSnippets)
	if &ft == 'html'
		normal i<em>
		let after = 0
	elseif &ft == 'tex'
		let after = 2
		if option == 0
			normal i\emph{
			let after = 1
		elseif option == 1
			normal i\textcolor{red}{
		elseif option == 2
			normal i\textcolor{magenta}{
		elseif option == 3
			normal i\textcolor{blue}{
		elseif option == 4
			normal i\textcolor{cyan}{
		elseif option == 5
			normal i\textcolor{green}{
		endif
	endif
	" normal i<em>

	call setpos('.',pos)
	if after == 0
		normal f>l
	elseif after == 1
		normal f{l
	elseif after == 2
		normal f{;l
	endif
	call Workaroundautoclose('close')
endf

fun WordsSnippetsV() range
	call Workaroundautoclose('open')

	call cursor(line("'>"),col("'>")-1)
	normal e

	call SearchNextSpot(g:ListForSnippets)
	normal a}

	call cursor(line("'<"),col("'<")+1)
	normal b

	call SearchBackSpot(g:ListForSnippets)
	normal i${1:
	normal h
	" call cursor(line("'<"),col("'<"))
	call Workaroundautoclose('close')
endf
fun WordsSnippets()
	call Workaroundautoclose('open')
	let pos = getpos('.')
	normal e
	call SearchNextSpot(g:ListForSnippets)
	normal a}

	call setpos('.',pos)
	normal wb
	call SearchBackSpot(g:ListForSnippets)
	normal i${1:
	normal h
	call Workaroundautoclose('close')
endf
" 
" 0. "blow out all contents"
let avoidList = ["'",'"']
nmap <silent><A-;><A-'> :call DeleteInQuoteOnce(avoidList)<CR>i
nmap <silent><A-[><A-]> :call DeleteInBraOnce(g:ListBraTotal)<CR>i

" 1. "Make encaps."
nmap <silent><A-)><A-(> :call WordsEncapsN(g:ListBra,g:ListForBracket)<CR>
nmap <silent><A->><A-<> :call WordsEncapsN(g:ListSha,g:ListForBracket)<CR>
" nmap <silent><A-]><A-[> :call WordsEncapsN(g:ListRec,g:ListForBracket)<CR>
nmap <silent><A-}><A-{> :call WordsEncapsN(g:ListCur,g:ListForBracket)<CR>
nmap <A-'><A-;> :call WordsEncapsN(g:ListSma,g:ListForQuote)<CR>
" nmap <silent><A-'><A-;> :call WordsEncapsN(g:ListSma,g:ListForQuote)<CR>
nmap <silent><A-"><A-:> :call WordsEncapsN(g:ListDuo,g:ListForQuote)<CR>

vmap <silent><A-)><A-(> :call WordsEncapsV(g:ListBra,g:ListForBracket,'onepair')<CR>
vmap <silent><A->><A-<> :call WordsEncapsV(g:ListSha,g:ListForBracket,'onepair')<CR>
" vmap <silent><A-]><A-[> :call WordsEncapsV(g:ListRec,g:ListForBracket,'onepair')<CR>
vmap <silent><A-}><A-{> :call WordsEncapsV(g:ListCur,g:ListForBracket,'onepair')<CR>
vmap <silent><A-'><A-;> :call WordsEncapsV(g:ListSma,g:ListForQuote,'onepair')<CR>
vmap <silent><A-"><A-:> :call WordsEncapsV(g:ListDuo,g:ListForQuote,'onepair')<CR>

vmap <silent><leader><A-)><A-(> :call WordsEncapsV(g:ListBra,g:ListForBracket,'each')<CR>
vmap <silent><leader><A->><A-<> :call WordsEncapsV(g:ListSha,g:ListForBracket,'each')<CR>
vmap <silent><leader><A-]><A-[> :call WordsEncapsV(g:ListRec,g:ListForBracket,'each')<CR>
vmap <silent><leader><A-}><A-{> :call WordsEncapsV(g:ListCur,g:ListForBracket,'each')<CR>
vmap <silent><leader><A-'><A-;> :call WordsEncapsV(g:ListSma,g:ListForQuote,'each')<CR>
vmap <silent><leader><A-"><A-:> :call WordsEncapsV(g:ListDuo,g:ListForQuote,'each')<CR>

" 2. "Delete contents in encaps."
nmap <silent><A-(><A-(> :call DeleteContents(g:ListBra,'normal')<CR>
nmap <silent><A-<><A-<> :call DeleteContents(g:ListSha,'normal')<CR>
nmap <silent><A-{><A-{> :call DeleteContents(g:ListCur,'normal')<CR>
nmap <silent><A-[><A-[> :call DeleteContents(g:ListRec,'normal')<CR>
nmap <silent><A-:><A-:> :call DeleteContents(g:ListDuo,'normal')<CR>
nmap <silent><A-;><A-;> :call DeleteContents(g:ListSma,'normal')<CR>

vmap <silent><A-(><A-(> x:call DeleteContents(g:ListBra,'visual')<CR>
vmap <silent><A-<><A-<> x:call DeleteContents(g:ListSha,'visual')<CR>
vmap <silent><A-{><A-{> x:call DeleteContents(g:ListCur,'visual')<CR>
vmap <silent><A-[><A-[> x:call DeleteContents(g:ListRec,'visual')<CR>
vmap <silent><A-:><A-:> x:call DeleteContents(g:ListDuo,'visual')<CR>
vmap <silent><A-;><A-;> x:call DeleteContents(g:ListSma,'visual')<CR>

" {3}. "Remove encaps leaving contents intact."
nmap <silent><A-)><A-)> :call EraseEncaps(g:ListBra,'normal')<CR>
nmap <silent><A->><A->> :call EraseEncaps(g:ListSha,'normal')<CR>
nmap <silent><A-}><A-}> :call EraseEncaps(g:ListCur,'normal')<CR>
nmap <silent><A-]><A-]> :call EraseEncaps(g:ListRec,'normal')<CR>
nmap <silent><A-"><A-"> :call EraseEncaps(g:ListDuo,'normal')<CR>
nmap <silent><A-'><A-'> :call EraseEncaps(g:ListSma,'normal')<CR>

vmap <silent><A-)><A-)> :call EraseEncaps(g:ListBra,'visual')<CR>
vmap <silent><A->><A->> :call EraseEncaps(g:ListSha,'visual')<CR>
vmap <silent><A-}><A-}> :call EraseEncaps(g:ListCur,'visual')<CR>
vmap <silent><A-]><A-]> :call EraseEncaps(g:ListRec,'visual')<CR>
vmap <silent><A-"><A-"> :call EraseEncaps(g:ListDuo,'visual')<CR>
vmap <silent><A-'><A-'> :call EraseEncaps(g:ListSma,'visual')<CR>


fun DoubleFunctions()
	nmap <silent><A-]><A-[> :call WordsEncapsN(g:ListRec,g:ListForBracket)<CR>
	vmap <silent><A-]><A-[> :call WordsEncapsV(g:ListRec,g:ListForBracket,'onepair')<CR>
endfun

fun SetForSnippets()
	vmap <silent><A-]><A-[> :call WordsSnippetsV()<CR>
	nmap <silent><A-]><A-[> :call WordsSnippets()<CR>
endf
fun SetForHTML()
	nmap <silent><A-]><A-[>	 :call WordsEmphasize(0)<CR>
	vmap <silent><A-]><A-[>	 :call WordsEmphasizeV($buf.count)<CR>
	nmap <silent>1<A-]><A-[> :call WordsEmphasize(1)<CR>
	nmap <silent>2<A-]><A-[> :call WordsEmphasize(2)<CR>
	nmap <silent>3<A-]><A-[> :call WordsEmphasize(3)<CR>
	nmap <silent>4<A-]><A-[> :call WordsEmphasize(4)<CR>
	nmap <silent>5<A-]><A-[> :call WordsEmphasize(5)<CR>
	" vmap <A-]><A-[> :call WordsEmphasizeV()<CR>
	" nmap <A-]><A-[> :call WordsEmphasize()<CR>
endf

fun CheckFiletype()
	if &ft == 'html' || &ft == 'tex'
		call SetForHTML()
	elseif &ft == 'snippets'
		call SetForSnippets()
	else
		call DoubleFunctions()
	endif
endfun
au BufEnter * call CheckFiletype()
" au BufEnter * call CheckFiletype()
" au filetype html,tex call SetForHTML()
" au filetype snippets call SetForSnippets()

"Drop in your .vim/plugin or vimfiles/plugin
"Feel free changing to your favorite key mapping.
