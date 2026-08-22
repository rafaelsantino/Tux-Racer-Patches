# -*-tcl-*-
# Tk-based Tcl shell.

# Based on example 19-4, p 245 in _Practical Programming in Tcl and
# Tk_, 2nd Ed. by Brent B. Welch.

namespace eval TRConsole {

    proc Create { f } {

	tixScrolledText $f -scrollbar both -options { 
	    text.width 80 
	    text.height 10 
	    text.font {courier 12 normal} 
	}

	pack $f -fill both -expand yes
	set t [$f subwidget text]

	# Stop cursor blinking
	$t configure -insertofftime 0

	# Text tags give script output, command errors, command
	# results, and the prompt a different appearance

	$t tag configure prompt -underline true
	$t tag configure result -foreground purple
	$t tag configure error -foreground red
	$t tag configure output -foreground blue

	# Make state an alias for object state
	upvar #0 _state$t state

	# Insert the prompt and initialize the limit mark

	set state(history) [list]
	set state(history_pos) 0
	set state(prompt) "tcl>"
	$t insert insert $state(prompt) prompt
	$t insert insert " "
	$t mark set limit insert
	$t mark gravity limit left
	focus $t
	set state(text) $t

	# Key bindings that limit input and eval things. The break in
	# the bindings skips the default Text binding for the event.

	bind $t <Return> [namespace code {EvalTypein %W ; break}]
	bind $t <BackSpace> [namespace code {
	    if {[%W tag nextrange sel 1.0 end] != ""} {
		%W delete sel.first sel.last
	    } elseif {[%W compare insert > limit]} {
		%W delete insert-1c
		%W see insert
	    }
	    break
	}]
	bind $t <Key> [namespace code {
		if [%W compare insert < limit] {
		%W mark set insert end
	    }
	}]

	bind $t <Up> [code DisplayHistory $t -1]
	bind $t <Down> [code DisplayHistory $t +1]
	

	bind $t <Destroy> "unset _state$t"

	return $t
    }

    proc DisplayHistory {t dir} {
	upvar #0 _state$t state

	set newpos [expr $state(history_pos) + $dir]
	set histlen [llength $state(history)]

	if { $newpos >= 0 && $newpos < $histlen } {
	    $t delete limit insert
	    $t insert insert [lindex $state(history) $newpos]
	    $t see insert
	    set state(history_pos) $newpos
	} elseif { $newpos == $histlen } {
	    $t delete limit insert
	    $t see insert
	    set state(history_pos) $newpos
	}
	
	return -code break
    }

    # Evaluate everything between limit and end as a Tcl command

    proc EvalTypein {t} {
	upvar #0 _state$t state
	$t mark set insert end
	$t insert insert \n
	set command [$t get limit end]
	if [info complete $command] {
	    $t mark set limit insert
	    Eval $t $command
	} else {
	    $t see insert
	}
    }

    # Echo the command and evaluate it

    proc EvalEcho {t command} {
	upvar #0 _state$t state
	$t mark set insert end
	$t insert insert $command\n
	$t mark set limit insert
	Eval $t $command
    }

    # The puts alias puts stdout and stderr into the text widget

    proc ShellPuts {t args} {
	if {[llength $args] > 3} {
	    error {wrong # args: should be "puts ?-nonewline? ?channelId? string"}
	}
	set newline "\n"
	if {[string match "-nonewline" [lindex $args 0]]} {
	    set newline ""
	    set args [lreplace $args 0 0]
	}
	if {[llength $args] == 1} {
	    set chan stdout
	    set string [lindex $args 0]$newline
	} else {
	    set chan [lindex $args 0]
	    set string [lindex $args 1]$newline
	}
	if [regexp (stdout|stderr) $chan] {
	    upvar #0 _state$t state
	    $t mark gravity limit right
	    $t insert limit $string output
	    $t see limit
	    $t mark gravity limit left
	} else {
	    puts.orig -nonewline $chan $string
	}
    }

    # Evaluate a command and display its result

    proc Eval {t command} {
	upvar #0 _state$t state

	# Add command to history
	lappend state(history) [string trimright [string trimleft $command]]
	set state(history_pos) [llength $state(history)]

	# Temporarily rename puts
	set renamed_puts 0
	if { ![catch {rename ::puts puts.orig}] } {
	    interp alias {} puts {} [namespace code ShellPuts] $t
	    set renamed_puts 1
	}

	$t mark set insert end
	if [catch {namespace eval :: $command} result] {
	    $t insert insert $result error
	} else {
	    $t insert insert $result result
	}
	if {[$t compare insert != "insert linestart"]} {
	    $t insert insert \n
	}
	$t insert insert $state(prompt) prompt
	$t insert insert " "
	$t see insert
	$t mark set limit insert
	    
	# Restore puts
	if $renamed_puts {
	    interp alias {} puts {}
	    rename puts.orig ::puts
	}

	return
    }

} ;# namespace TRConsole
