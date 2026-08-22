# Routines for adding menus to the menu bar

namespace eval TRMenu {
    
    # Sets up the menubar
    proc Setup { menubar } {
	upvar #0 _statemenu state

	menu $menubar

	# Associate menu with its main window
	set top [winfo parent $menubar]
	$top config -menu $menubar
	set state(menubar) $menubar
	set state(uid) 0
    }

    # Creates a top-level menu with name <label>
    proc Menu { label } {
	upvar #0 _statemenu state
	if [info exists state(menu,$label)] {
	    error "Menu $label already defined"
	}

	# Create the cascade menu
	set menuName $state(menubar).mb$state(uid)
	incr state(uid)

	menu $menuName -tearoff 1
	$state(menubar) add cascade -label $label -menu $menuName

	# Remember the name to menu mapping
	set state(menu,$label) $menuName
    }

    # Returns the widget for the menu <menuName>
    proc Get { menuName } {
	upvar #0 _statemenu state

	if [ catch {set state(menu,$menuName)} m] {
	    return -code error "No such menu: $menuName"
	}

	return $m
    }

    # Adds a command menu item to the specified menu
    proc Command { menuName label command } {
	set m [Get $menuName]
	$m add command -label $label -command $command
    }

    # Adds a checkbox menu item to the specified menu
    proc Check { menuName label var { command {} } } {
	set m [Get $menuName]
	$m add check -label $label -command $command -variable $var
    }

    # Adds a radiobutton item to the specified menu
    proc Radio { menuName label var {val {}} {command {}} } {
	set m [Get $menuName]
	if {[string length $val] == 0} {
	    set val $label
	}
	$m add radio -label $label -command $command \
		-value $val -variable $var
    }

    # Adds a separator to the specified menu
    proc Separator { menuName } {
	[Get $menuName] add separator
    }

    # Adds a submenu to the specified menu
    proc Cascade { menuName label } {
	upvar #0 _statemenu state
	set m [Get $menuName]
	if [info exists state(menu,$label)] {
	    error "Menu $label already defined"
	}
	set sub $m.sub$state(uid)
	incr state(uid)
	menu $sub -tearoff 0
	$m add cascade -label $label -menu $sub
	set state(menu,$label) $sub
    }

    # Binds an event sequence to the specified menu
    proc Bind { what sequence menuName label } {
	upvar #0 _statemenu state
	set m [Get $menuName]
	if [catch {$m index $label} index] {
	    error "$label not in menu $menuName"
	}
	set command [$m entrycget $index -command]
	bind $what $sequence $command
	$m entryconfigure $index -accelerator $sequence
    }
}
