
namespace eval TRCharacterEditor {
    
    proc Create {f} {
	global tux_data_dir
	upvar #0 _state$f state

	frame $f

	# Select character frame
	set charselect [frame $f.charselect -border 4 -relief sunken]

	# Create Header
	set header $charselect.header
	label $header -text "Select Character" \
		-background black -foreground white
	pack $header -fill x -expand no

	set cf [frame $charselect.f]

	set label [label $cf.label -text "Character: "]
	set state(character) Unset
	set state(charselectbox)  [tixComboBox $cf.combo -label "" \
		-variable _state$f\(character\) \
		-command [code UpdateCharSelect $f]]
	foreach character {
	    "boris"
	    "samuel"
	    "neva"
	    "tux"
	} {
	    $state(charselectbox) subwidget listbox insert end $character
	}
	$state(charselectbox) pick 0

	pack $label -side left
	pack $state(charselectbox) -side left -fill x -expand yes
	pack $cf -fill x -expand yes
	pack $charselect -fill both -expand yes

	# Create character container selection
	set cf [frame $charselect.charroot]
	set label [label $cf.label -text "Container: "]
	set state(char_container) \
		[TRPropEdit::Create $cf.char_container object \
		":display_characters:$state(character)" 1 rw]
	pack $label -side left -expand no
	pack $state(char_container) -side left -expand yes
	pack $cf -fill x -expand yes

	# Link Alias Anims Frame
	set linkalias [frame $f.alias -border 4 -relief sunken]

	# Create Header
	set header $linkalias.header
	label $header -text "Link Alias Animations" \
		-background black -foreground white
	pack $header -fill x -expand no

	pack $linkalias -fill x -expand no

	set cf [frame $linkalias.selectanim]
	set label [label $cf.label -text "Anim: "]
	pack $label -side left -expand no
	set state(anim_select) \
		[TRPropEdit::Create $cf.anim_select object \
		":display_characters:$state(character):anim" 1 rw]
	pack $state(anim_select) -side left -fill x -expand yes
	pack $cf -fill x -expand yes

	# Create link buttons
	set cf [frame $linkalias.buttons]
	set linkbutton [button $cf.linkbtn \
		-text "Link" \
		-command [code LinkAliasAnim $f]]
	set linkallbutton [button $cf.linkallbtn \
		-text "Link All" \
		-command [code LinkAllAliasAnims $f]]
	set unlinkbutton [button $cf.unlinkbtn \
		-text "Unlink" \
		-command [code UnlinkAnim $f]]

	pack $linkbutton -side left -expand no
	pack $linkallbutton -side left -expand no
	pack $unlinkbutton -side left -expand no
	pack $cf 

	# Save Scene Graph Frame
	set savesg [frame $f.savesg -border 4 -relief sunken]

	# Create Header
	set header $savesg.header
	label $header -text "Save Scene Graph" \
		-background black -foreground white
	pack $header -fill x -expand no

	pack $savesg -fill x -expand no

	# Create save button
	set savebutton [button $savesg.savebtn \
		-text "Save" \
		-command [code SaveSG $f]]

	pack $savebutton

	pack $f -fill both -expand true

	return $f
    }

    proc FindAnimNode {curnode name} {
	set basename [objget $curnode basename]
	if { "$basename" == "$name" && [objcall $curnode is_a s_sganim] } {
	    return $curnode;
	}
	set children [objget $curnode children]
	foreach child $children {
	    set result [FindAnimNode $child $name]
	    if { $result != "" } {
		return $result
	    }
	}
	return ""
    }

    proc UnlinkAnim { f } {
	upvar #0 _state$f state

	set char_container [TRPropEdit::GetValue $state(char_container)]
	set anim [TRPropEdit::GetValue $state(anim_select)]

	RemoveAnimFromHierarchy $char_container $anim
    }
    
    proc UpdateCharSelect { f val } {
	upvar #0 _state$f state

	if { [info exists state(character)] && \
		[info exists state(char_container)] && \
		[info exists state(anim_select)] } {
	    
	    set char $state(character)
	    
	    set char_container $state(char_container)
	    set anim_select $state(anim_select)
	    
	    TRPropEdit::SetValue $char_container ":display_characters:$char"
	    TRPropEdit::SetValue $anim_select ":display_characters:$char:anim"
	}
    }

    proc RemoveAnimFromHierarchy { node anim } {
	if [objcall $node is_a s_sganim] {
	    set nodeAnims [objget $node bound_animations]
	    
	    set numAnims [llength $nodeAnims]
	    for {set i [expr $numAnims-1]} {$i>=0} {incr i -1} {
		set boundAnim [lindex $nodeAnims $i]
		if { ![regexp {[(] *([^ ]*)} $boundAnim dummy boundChannel] } {
		    error "couldn't determine boundChannel"
		}
		if [regexp "^$anim" $boundChannel] {
		    set nodeAnims [lreplace $nodeAnims $i $i]
		}
	    }
	    objset $node -bound_animations $nodeAnims
	}
	
	if [objcall $node is_a s_container] {
	    foreach child [objget $node children] {
		RemoveAnimFromHierarchy $child $anim
	    }
	}
    }
    
    proc LinkAllAliasAnims { f } {
	upvar #0 _state$f state

	set char_container [TRPropEdit::GetValue $state(char_container)]

	set anims [objget $char_container:anim children]

	set timed_anims { "intro" "end_win" "end_lose" }
	
	foreach anim $anims {
	    if [objcall $anim is_a s_alias_container] {
		if { [lsearch $timed_anims [objget $anim basename]] >= 0 } {
		    set useClock 1
		} else {
		    set useClock 0
		}
		LinkAliasAnimAux $char_container $anim $useClock
	    }
	}
    }

    proc LinkAliasAnim { f } {
	upvar #0 _state$f state

	set char_container [TRPropEdit::GetValue $state(char_container)]
	set anim [TRPropEdit::GetValue $state(anim_select)]

	LinkAliasAnimAux $char_container $anim 0
    }
    
    proc LinkAliasAnimAux { characterRoot anim useClock } {
	set curves [objget $anim children]
	
	RemoveAnimFromHierarchy $characterRoot $anim
	
	foreach curve $curves {
	    set curveName [objget $curve basename]
	    
	    set channelMap(rotateX) x_radians
	    set channelMap(rotateY) y_radians
	    set channelMap(rotateZ) z_radians
	    set channelMap(translateX) x_translation
	    set channelMap(translateY) y_translation
	    set channelMap(translateZ) z_translation
	    set channelMap(scaleX) x_scale
	    set channelMap(scaleY) y_scale
	    set channelMap(scaleZ) z_scale
	    set channelMap(scaleX) x_scale
	    set channelMap(scaleY) y_scale
	    set channelMap(scaleZ) z_scale
	    
	    regexp {^([^-]*)-([^-]*)$} $curveName dummy nodename channel
	    
	    set node [FindAnimNode $characterRoot:sg $nodename]
	    
	    if { $node == "" } {
		tux_warning "couldn't find node for curve $curve"
		continue
	    }
	    
	    set nodeAnims [objget $node bound_animations]
	    
	    if [ info exists channelMap($channel) ] {
		set newAnim [list ( $curve , $channelMap($channel) , $useClock ) ]
		lappend nodeAnims $newAnim
		objset $node -bound_animations $nodeAnims
	    } else {
		tux_warning "no mapping for channel $channel"
	    }
	}
    }
    
    proc SaveSG { f } {
	upvar #0 _state$f state
	global tux_data_dir

	set char_container [TRPropEdit::GetValue $state(char_container)]

	set sg [objserialize $char_container:sg]
	
	regsub -all "$char_container:" $sg {} sg
	
	set fname "$tux_data_dir/characters/$state(character)/sg.tcl"
	
	if [catch {open $fname w} fileId] {
	    tk_messageBox -type ok -message "$fileId"
	} else {
	    fconfigure $fileId -buffering full
	    
	    puts $fileId $sg
	    
	    close $fileId
	}
    }
}


