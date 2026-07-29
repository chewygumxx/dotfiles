encourage=(  # String length: 11-14
    "Praising the"   "Introducing"   "Marveling at"   "Encouraging"
    "Welcoming the"  "Warm Welcome"  "Rejoicing with" "Appreciating"
    "Befriending"    "Excited for"   "Delighted at"   "Listening to"
    "Honoring the"   "Complimenting" "Empathizing"    "Relaxing with"
    "Embracing the"  "Cheering for"  "Sympathizing"   "Celebrating"
    "Congratulating" "Admiring the"  "Entertaining"
)
function encourage_msg () {
    print -f "%-14s %s\n" \
        "${encourage[RANDOM % ${#encourage} + 1]}:" \
        "${1:-"${0}: No message? :("}"
}

