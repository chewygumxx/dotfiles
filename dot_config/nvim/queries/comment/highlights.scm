; vim:set expandtab shiftwidth=4 filetype=query:
; SPDX-License-Identifier: GPL-3.0-only

; 
; 
; ~chewygumxx/dotfiles.git
; ::: :/dot_config/nvim/queries/comment/highlights.scm
; 
; 

;
; Tree-sitter query for https://github.com/stsewd/tree-sitter-comment
;

; Header

; ~chewygumxx/dotfiles.git
(
    "text" @comment.git_repo.owner
    "text" @comment.git_repo.solidus
    "text" @comment.git_repo.name
    "text" @comment.git_repo.dot
    "text" @comment.git_repo.ext
    (#lua-match? @comment.git_repo.owner   "^~[%w_]+$")
    (#eq?        @comment.git_repo.solidus "/")
    (#lua-match? @comment.git_repo.name    "^[%w_]+$")
    (#eq?        @comment.git_repo.dot     ".")
    (#eq?        @comment.git_repo.ext     "git")
    (#adjacent?  @comment.git_repo.owner
                 @comment.git_repo.solidus
                 @comment.git_repo.name
                 @comment.git_repo.dot 
                 @comment.git_repo.ext)
 )

; ::: :/dot_config/nvim/queries/comment/highlights.scm
(
    "text" @comment.git_repo.path_prepend
    "text" @comment.git_repo.path_prepend
    "text" @comment.git_repo.path_prepend
    "text" @comment.git_repo.path_start
    "text" @comment.git_repo.path_start
    "text" @comment.git_repo.root_directory
    (#eq?            @comment.git_repo.path_prepend   ":")
    (#lua-match?     @comment.git_repo.path_start     "^[:/]$")
    (#lua-match?     @comment.git_repo.root_directory "^[%w_]+$")
    (#adjacent?      @comment.git_repo.path_prepend
                     @comment.git_repo.path_start
                     @comment.git_repo.root_directory)
 )
(
    "text" @comment.git_repo.path_sep
    (#any-of?        @comment.git_repo.path_sep       "/")
    (#header-line?   @comment.git_repo.path_sep)
 )
(
    "text" @comment.git_repo.subdirectory
    (#lua-match?     @comment.git_repo.subdirectory   "^[%w_]+$")
    (#header-line?   @comment.git_repo.subdirectory)
 )
(
    "text" @comment.git_repo.basename
    "text" @comment.git_repo.dot
    "text" @comment.git_repo.ext
    (#lua-match?     @comment.git_repo.basename       "^[%w_]+$")
    (#header-line?   @comment.git_repo.basename       "path")
    (#eq?            @comment.git_repo.dot            ".")
    (#lua-match?     @comment.git_repo.ext            "^[%w_]+$")
    (#last-matching? @comment.git_repo.ext            "^[%w_]+$")
    (#adjacent?      @comment.git_repo.basename
                     @comment.git_repo.dot
                     @comment.git_repo.ext)
 )

; From https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm

; TODO(@chewygumxx): Yeet
((tag
   (name) @comment.todo @nospell
   ("(" @punctuation.bracket
    (user) @constant
    ")" @punctuation.bracket)?
   ":" @punctuation.delimiter)
 (#any-of? @comment.todo "TODO" "WIP"))

; TODO
("text" @comment.todo @nospell
 (#any-of? @comment.todo "TODO" "WIP"))

; NOTE(@chewygumxx): Yeet
((tag
   (name) @comment.note @nospell
   ("(" @punctuation.bracket
    (user) @constant
    ")" @punctuation.bracket)?
   ":" @punctuation.delimiter)
 (#any-of? @comment.note "NOTE" "XXX" "INFO" "DOCS" "PERF" "TEST"))

; NOTE
("text" @comment.note @nospell
 (#any-of? @comment.note "NOTE" "XXX" "INFO" "DOCS" "PERF" "TEST"))

; HACK(@chewygumxx): Yeet
((tag
   (name) @comment.warning @nospell
   ("(" @punctuation.bracket
    (user) @constant
    ")" @punctuation.bracket)?
   ":" @punctuation.delimiter)
 (#any-of? @comment.warning "HACK" "WARNING" "WARN" "FIX"))

; HACK
("text" @comment.warning @nospell
 (#any-of? @comment.warning "HACK" "WARNING" "WARN" "FIX"))

; FIXME(@chewygumxx): Yeet
((tag
   (name) @comment.error @nospell
   ("(" @punctuation.bracket
    (user) @constant
    ")" @punctuation.bracket)?
   ":" @punctuation.delimiter)
 (#any-of? @comment.error "FIXME" "BUG" "ERROR"))

; FIXME
("text" @comment.error @nospell
 (#any-of? @comment.error "FIXME" "BUG" "ERROR"))

; Issue number (#123)
("text" @number
 (#lua-match? @number "^#[0-9]+$"))

; https://github.com
(uri) @string.special.url @nospell
