# vim: expandtab:shiftwidth=4:foldmethod=marker

#
#
# ~/ref/template/ansi_escape.templ.zsh
#
#


# {{{ ANSI Escape Array
declare -A cl
cl=(
# None            Bold            Dim             Italic          Underline
 [n]=$'\e[0m'    [b]=$'\e[1m'    [d]=$'\e[2m'    [i]=$'\e[3m'    [u]=$'\e[4m'
# Blink           Fast Blink      Standout        Conceal         Strikeout
 [blnk]=$'\e[5m' [fast]=$'\e[6m' [stnd]=$'\e[7m' [hide]=$'\e[8m' [strk]=$'\e[9m'

# Standard              Bright
 [blk]=$'\e[0;30m'     [BLK]=$'\e[0;90m'     # Black   
 [red]=$'\e[0;31m'     [RED]=$'\e[0;91m'     # Red     
 [grn]=$'\e[0;32m'     [GRN]=$'\e[0;92m'     # Green   
 [ylw]=$'\e[0;33m'     [YLW]=$'\e[0;93m'     # Yellow  
 [blu]=$'\e[0;34m'     [BLU]=$'\e[0;94m'     # Blue    
 [mag]=$'\e[0;35m'     [MAG]=$'\e[0;95m'     # Magenta 
 [cyn]=$'\e[0;36m'     [CYN]=$'\e[0;96m'     # Cyan    
 [wht]=$'\e[0;37m'     [WHT]=$'\e[0;97m'     # White   

# Standard Background   Bright Background
 [bg_blk]=$'\e[0;40m'  [bg_BLK]=$'\e[0;100m' # Black   
 [bg_red]=$'\e[0;41m'  [bg_RED]=$'\e[0;101m' # Red     
 [bg_grn]=$'\e[0;42m'  [bg_GRN]=$'\e[0;102m' # Green   
 [bg_ylw]=$'\e[0;43m'  [bg_YLW]=$'\e[0;103m' # Yellow  
 [bg_blu]=$'\e[0;44m'  [bg_BLU]=$'\e[0;104m' # Blue    
 [bg_mag]=$'\e[0;45m'  [bg_MAG]=$'\e[0;105m' # Magenta 
 [bg_cyn]=$'\e[0;46m'  [bg_CYN]=$'\e[0;106m' # Cyan    
 [bg_wht]=$'\e[0;47m'  [bg_WHT]=$'\e[0;107m' # White   

# Standard Bold         Bright Bold 
 [b_blk]=$'\e[1;30m'   [b_BLK]=$'\e[1;90m'   # Black    
 [b_red]=$'\e[1;31m'   [b_RED]=$'\e[1;91m'   # Red      
 [b_grn]=$'\e[1;32m'   [b_GRN]=$'\e[1;92m'   # Green    
 [b_ylw]=$'\e[1;33m'   [b_YLW]=$'\e[1;93m'   # Yellow   
 [b_blu]=$'\e[1;34m'   [b_BLU]=$'\e[1;94m'   # Blue     
 [b_mag]=$'\e[1;35m'   [b_MAG]=$'\e[1;95m'   # Magenta  
 [b_cyn]=$'\e[1;36m'   [b_CYN]=$'\e[1;96m'   # Cyan     
 [b_wht]=$'\e[1;37m'   [b_WHT]=$'\e[1;97m'   # White    

# Standard Dim          Bright Dim 
 [d_blk]=$'\e[2;30m'   [d_BLK]=$'\e[2;90m'   # Black    
 [d_red]=$'\e[2;31m'   [d_RED]=$'\e[2;91m'   # Red      
 [d_grn]=$'\e[2;32m'   [d_GRN]=$'\e[2;92m'   # Green    
 [d_ylw]=$'\e[2;33m'   [d_YLW]=$'\e[2;93m'   # Yellow   
 [d_blu]=$'\e[2;34m'   [d_BLU]=$'\e[2;94m'   # Blue     
 [d_mag]=$'\e[2;35m'   [d_MAG]=$'\e[2;95m'   # Magenta  
 [d_cyn]=$'\e[2;36m'   [d_CYN]=$'\e[2;96m'   # Cyan     
 [d_wht]=$'\e[2;37m'   [d_WHT]=$'\e[2;97m'   # White    

# Standard Italic       Bright Italic 
 [i_blk]=$'\e[3;30m'   [i_BLK]=$'\e[3;90m'   # Black    
 [i_red]=$'\e[3;31m'   [i_RED]=$'\e[3;91m'   # Red      
 [i_grn]=$'\e[3;32m'   [i_GRN]=$'\e[3;92m'   # Green    
 [i_ylw]=$'\e[3;33m'   [i_YLW]=$'\e[3;93m'   # Yellow   
 [i_blu]=$'\e[3;34m'   [i_BLU]=$'\e[3;94m'   # Blue     
 [i_mag]=$'\e[3;35m'   [i_MAG]=$'\e[3;95m'   # Magenta  
 [i_cyn]=$'\e[3;36m'   [i_CYN]=$'\e[3;96m'   # Cyan     
 [i_wht]=$'\e[3;37m'   [i_WHT]=$'\e[3;97m'   # White    

# Standard Underline    Bright Underline
 [u_blk]=$'\e[4;30m'   [u_BLK]=$'\e[4;90m'   # Black    
 [u_red]=$'\e[4;31m'   [u_RED]=$'\e[4;91m'   # Red      
 [u_grn]=$'\e[4;32m'   [u_GRN]=$'\e[4;92m'   # Green    
 [u_ylw]=$'\e[4;33m'   [u_YLW]=$'\e[4;93m'   # Yellow   
 [u_blu]=$'\e[4;34m'   [u_BLU]=$'\e[4;94m'   # Blue     
 [u_mag]=$'\e[4;35m'   [u_MAG]=$'\e[4;95m'   # Magenta  
 [u_cyn]=$'\e[4;36m'   [u_CYN]=$'\e[4;96m'   # Cyan     
 [u_wht]=$'\e[4;37m'   [u_WHT]=$'\e[4;97m'   # White    

# Standard Blink        Bright Blink
 [bl_blk]=$'\e[5;30m'  [bl_BLK]=$'\e[5;90m'  # Black   
 [bl_red]=$'\e[5;31m'  [bl_RED]=$'\e[5;91m'  # Red     
 [bl_grn]=$'\e[5;32m'  [bl_GRN]=$'\e[5;92m'  # Green   
 [bl_ylw]=$'\e[5;33m'  [bl_YLW]=$'\e[5;93m'  # Yellow  
 [bl_blu]=$'\e[5;34m'  [bl_BLU]=$'\e[5;94m'  # Blue    
 [bl_mag]=$'\e[5;35m'  [bl_MAG]=$'\e[5;95m'  # Magenta 
 [bl_cyn]=$'\e[5;36m'  [bl_CYN]=$'\e[5;96m'  # Cyan    
 [bl_wht]=$'\e[5;37m'  [bl_WHT]=$'\e[5;97m'  # White   

# Standard Fast Blink   Bright Fast Blink
 [bf_blk]=$'\e[6;30m'   [bf_BLK]=$'\e[6;90m'   # Black    
 [bf_red]=$'\e[6;31m'   [bf_RED]=$'\e[6;91m'   # Red      
 [bf_grn]=$'\e[6;32m'   [bf_GRN]=$'\e[6;92m'   # Green    
 [bf_ylw]=$'\e[6;33m'   [bf_YLW]=$'\e[6;93m'   # Yellow   
 [bf_blu]=$'\e[6;34m'   [bf_BLU]=$'\e[6;94m'   # Blue     
 [bf_mag]=$'\e[6;35m'   [bf_MAG]=$'\e[6;95m'   # Magenta  
 [bf_cyn]=$'\e[6;36m'   [bf_CYN]=$'\e[6;96m'   # Cyan     
 [bf_wht]=$'\e[6;37m'   [bf_WHT]=$'\e[6;97m'   # White    

# Standard Standout     Bright Standout
 [sd_blk]=$'\e[7;30m'   [sd_BLK]=$'\e[7;90m'   # Black    
 [sd_red]=$'\e[7;31m'   [sd_RED]=$'\e[7;91m'   # Red      
 [sd_grn]=$'\e[7;32m'   [sd_GRN]=$'\e[7;92m'   # Green    
 [sd_ylw]=$'\e[7;33m'   [sd_YLW]=$'\e[7;93m'   # Yellow   
 [sd_blu]=$'\e[7;34m'   [sd_BLU]=$'\e[7;94m'   # Blue     
 [sd_mag]=$'\e[7;35m'   [sd_MAG]=$'\e[7;95m'   # Magenta  
 [sd_cyn]=$'\e[7;36m'   [sd_CYN]=$'\e[7;96m'   # Cyan     
 [sd_wht]=$'\e[7;37m'   [sd_WHT]=$'\e[7;97m'   # White    

# Standard Strikeout    Bright Strikeout
 [sk_blk]=$'\e[9;30m'   [sk_BLK]=$'\e[9;90m'   # Black    
 [sk_red]=$'\e[9;31m'   [sk_RED]=$'\e[9;91m'   # Red      
 [sk_grn]=$'\e[9;32m'   [sk_GRN]=$'\e[9;92m'   # Green    
 [sk_ylw]=$'\e[9;33m'   [sk_YLW]=$'\e[9;93m'   # Yellow   
 [sk_blu]=$'\e[9;34m'   [sk_BLU]=$'\e[9;94m'   # Blue     
 [sk_mag]=$'\e[9;35m'   [sk_MAG]=$'\e[9;95m'   # Magenta  
 [sk_cyn]=$'\e[9;36m'   [sk_CYN]=$'\e[9;96m'   # Cyan     
 [sk_wht]=$'\e[9;37m'   [sk_WHT]=$'\e[9;97m'   # White    
)
# }}}
# {{{ Log Strings
declare -A log
log=(
    [tag_b]="$cl[b_WHT]["
    [tag_e]="$cl[b_WHT]]$cl[n]::"

        [root]="$cl[BLK]├$cl[n]"
     [branch1]="$cl[BLK]╰──$cl[n]"
    [branch1e]="$cl[BLK]╰─╴$cl[n]" 
    [branch2a]="$cl[BLK]├──╴$cl[n]"
    [branch2b]="$cl[BLK]╰┬╴$cl[n]" # Base
    [branch2p]="$cl[BLK]╰─┬$cl[n]" # Periphery
     [branch3]="$cl[BLK]├─┬"
        [vert]="$cl[BLK]│"
)
log+=(
    [Usage]="$log[tag_b]$cl[grn]Usage$log[tag_e]"
    [ERROR]="$log[tag_b]$cl[b_red]ERROR$log[tag_e]"
     [WARN]="$log[tag_b]$cl[b_YLW]WARN$log[tag_e]"
)
# }}}
