echom "Opening and wiping files"
edit wordle.txt
vsplit ./lua/wordle/list.lua
%delete

echom "Copying content"
buffer wordle.txt
%yank
buffer ./lua/wordle/list.lua
0put
1

echom "Formatting"
normal Oreturn {
let @i = "    "
%global/^.....$/normal "iP
%global/^\s\s\s\s.....$/normal A,
normal Gi}
-1

write
echom "Done!"
quitall
