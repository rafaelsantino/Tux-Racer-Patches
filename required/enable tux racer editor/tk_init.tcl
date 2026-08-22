# -*-tcl-*-
# Initialization script for Tk

# Procedure to load Tk in sub-interpreters
proc LoadTk { { interp {} } } {
    set tk_lib_names {libtk8.3.so libtk8.2.so libtk8.0.so tk.dll}

    set loaded 0

    foreach tk_lib $tk_lib_names {
	if { ![catch {load $tk_lib Tk $interp}] } {
	    set loaded 1
	    break
	}
    }

    if { !$loaded } {
	error "Could not load Tk"
    }
}


#
# Set up resources
#
option add *selectColor lightgray

source tklib/scrolledtext.tcl
source tklib/tkshell.tcl
source tklib/profiler.tcl
source tklib/animeditor.tcl
source tklib/charactereditor.tcl
source tklib/objbrowser.tcl
source tklib/objeditor.tcl
source tklib/methodpanel.tcl
source tklib/propedit.tcl
source tklib/editutil.tcl
source tklib/objtree.tcl
source tklib/objselectdialog.tcl
source tklib/pallette.tcl
source tklib/newobject.tcl
source tklib/moveobject.tcl
source tklib/copyobject.tcl
source tklib/menu.tcl
source tklib/courseeditor.tcl
source tklib/sceneeditor.tcl
source tklib/modeleditor.tcl

namespace eval TRMainWin {
    set w .
    upvar #0 _state$w state

    wm title $w "Tux Racer Editor"

    # Somebody set up us the menu
    TRMenu::Setup .menubar

    # File Menu
    TRMenu::Menu File

    TRMenu::Command File Quit [code CheckQuit]
    TRMenu::Bind $w <Alt-Key-x> File Quit

    # Setup Menu
    TRMenu::Menu Setup

    TRMenu::Command Setup "Create Object3D" {objnew s_object3d :objects obj1}
    TRMenu::Command Setup "Create Instance" \
	    {objnew s_object3dinst :scene obj1inst}
    TRMenu::Command Setup "Create Model" {objnew s_model :models model1}
    TRMenu::Command Setup "Create Texture" {objnew s_texture :textures tex1}

    # Scene Menu
    TRMenu::Menu Scene

    TRMenu::Command Scene "Load Object Bitmap" [code LoadObjectBitmap]
    TRMenu::Command Scene "Save Object File" [code TRCourseEditor::SaveObjectFile]
    TRMenu::Command Scene "Clear" [code ClearScene]
    TRMenu::Command Scene "Quadtree-ify" {TRQuadTree::Rearrange :scene 5}
    TRMenu::Command Scene "Save Object Heights" {TRSaveHeights::Save :scene}
    TRMenu::Command Scene "Restore Object Heights" {TRSaveHeights::Restore}
    TRMenu::Command Scene "Set Start Points" [code SetStartPoints]

    # Windows Menu
    TRMenu::Menu Windows

    TRMenu::Command Windows "Course Editor" [code ActivateCourseEditor]
    TRMenu::Command Windows "Profiler" [code ActivateProfiler]
    TRMenu::Command Windows "Animations" [code ActivateAnimations]
    TRMenu::Command Windows "Scene Editor" [code ActivateSceneEditor]
    TRMenu::Command Windows "Model Editor" [code ActivateModelEditor]
    TRMenu::Command Windows "Character Editor" [code ActivateCharacterEditor]

    # Create Paned Window
    set f [tixPanedWindow .panedWindow -orientation vertical]
    $f add browserPane
    $f add consolePane

    # Create object browser
    set state(browser) [TRBrowser::Create [$f subwidget browserPane].browser]
    pack $state(browser) -side top -fill both -expand yes

    # Create Console
    set state(console) [TRConsole::Create [$f subwidget consolePane].console]
    pack $state(console) -side top -fill both -expand yes

    pack $f -side top -fill both -expand yes

    wm geometry . 800x375

    # HACK: If we don't do this, Tcl segfaults before the application exits...
    # Not sure where the bug is, but it occurs on both Windows and Linux.
    # -jfpatry
    bind [$f subwidget browserPane] <Destroy> exit


    proc CheckQuit {} {
	set result [tk_messageBox -type yesno -message "Really Quit?" \
		-parent . -default yes]
	if { $result == "yes" } {
	    exit
	}
    }

    proc LoadObjectBitmap {} {
	global tux_data_dir

	set typelist {
	    {"PNG Image" {".png"}}
	    {"RGB Image" {".rgb"}}
	    {"All Files" {*}} }

	set result [tk_getOpenFile -initialdir "$tux_data_dir/courses" \
		-title "Select File" -initialfile trees.png \
		-filetypes $typelist -parent . ]

	if { $result != "" } {
	    if [catch {objcall :palette create_instances $result } msg] {
		tk_messageBox -type ok -message $msg
	    }
	}
    }

    proc ActivateConsole {} {
	upvar #0 _state. state 
	set c $state(console)
	focus $c
    }

    proc GetConsole {} {
	upvar #0 _state. state 
	set c $state(console)
	return $c
    }

    proc ActivateProfiler {} {
	upvar #0 _state. state

	set state(profiler) .profilerWindow
	set p $state(profiler)

	if [ winfo exists $p ] {
	    wm deiconify $p
	    raise $p
	    focus $p
	} else {
	    set w [toplevel $p]
	    wm title $w "TR Profiler"
	    
	    set state(profilerText) [TRProfiler::Create $p.profiler]
	}
    }

    proc ActivateAnimations {} {
	upvar #0 _state. state

	set state(animeditorWindow) .animeditorWindow
	set p $state(animeditorWindow)

	if [ winfo exists $p ] {
	    wm deiconify $p
	    raise $p
	    focus $p
	} else {
	    set w [toplevel $p]
	    wm title $w "TR Animation Editor"
	    
	    set state(animeditor) [TRAnimEditor::Create $p.animeditor]
	}
    }

    proc ActivateSceneEditor {} {
	upvar #0 _state. state

	set state(sceneEditorWindow) .sceneEditorWindow
	set p $state(sceneEditorWindow)

	if [ winfo exists $p ] {
	    wm deiconify $p
	    raise $p
	    focus $p
	} else {
	    set w [toplevel $p]
	    wm title $w "TR Scene Editor"
	    
	    set state(sceneEditor) [TRSceneEditor::Create $p.sceneEditor]
	}
    }

    proc ActivateModelEditor {} {
	upvar #0 _state. state

	set state(modelEditorWindow) .modelEditorWindow
	set p $state(modelEditorWindow)

	if [ winfo exists $p ] {
	    wm deiconify $p
	    raise $p
	    focus $p
	} else {
	    set w [toplevel $p]
	    wm title $w "TR Model Editor"
	    
	    set state(modeleditor) [TRModelEditor::Create $p.modeleditor]
	}
    }

    proc GetProfiler {} {
	upvar #0 _state. state

	if { ![ info exists state(profilerText) ] } {
	    return ""
	}
	return $state(profilerText)
    }

    proc ActivateBrowser {} {
	upvar #0 _state. state

	focus $state(browser)
    }

    proc SelectObjectInTreeView {obj} {
	upvar #0 _state. state

	set browser $state(browser)
	set tree [TRBrowser::GetObjTree $browser]
	TRObjTree::SetSelection $tree $obj
    }

    proc ViewObjectInBrowser {obj} {
	upvar #0 _state. state
	set browser $state(browser)

	SelectObjectInTreeView $obj
	TRBrowser::ViewSelection $browser
    }

    proc ConsoleEval {cmd} {
	upvar #0 _state. state

	set console $state(console)
	TRConsole::Eval $console $cmd
    }

    proc ActivateCourseEditor {} {
	upvar #0 _state. state

	set state(courseEditor) .courseEditorWindow
	set p $state(courseEditor)

	if [ winfo exists $p ] {
	    wm deiconify $p
	    raise $p
	    focus $p
	} else {
	    TRCourseEditor::Create $p
	}
    }

    proc ActivateCharacterEditor {} {
	upvar #0 _state. state

	set state(characterEditor) .characterEditorWindow
	set p $state(characterEditor)

	if [ winfo exists $p ] {
	    wm deiconify $p
	    raise $p
	    focus $p
	} else {
	    set w [toplevel $p]
	    wm title $w "TR Character Editor"

	    TRCharacterEditor::Create $w.characterEditor
	}
    }

    proc GetProfiler {} {
	upvar #0 _state. state

	if { ![ info exists state(profilerText) ] } {
	    return ""
	}
	return $state(profilerText)
    }

    proc ClearScene {} {
	objcall :scene flush
	objcall :reset_points flush
	objcall :start_points flush
    }

    proc AddPoints { p1 p2 } {
	set result " [expr {[lindex $p1 0] + [lindex $p2 0]}] \
		[expr {[lindex $p1 1] + [lindex $p2 1]}] \
		[expr {[lindex $p1 2] + [lindex $p2 2]}] "
	return $result
    }

    proc SetStartPoints {} {
	set gateobj :scene:startgate
	objcall :start_points flush
	if { [objexists $gateobj] } {
	    set start_pos [objget :scene:startgate position]
	    
	    set pos [AddPoints $start_pos { -.9 1.3 0.5 }]
	    objcreate {s_object3dinst} {:start_points:start_point} \
		    {-object3d} {:objects:start_point} \
		    {-position} $pos

	    set pos [AddPoints $start_pos { .9 1.3 0.5 }]
	    objcreate {s_object3dinst} {:start_points:start_point-1} \
		    {-object3d} {:objects:start_point} \
		    {-position} $pos

	    set pos [AddPoints $start_pos { -2.7 1.3 0.5 }]
	    objcreate {s_object3dinst} {:start_points:start_point-2} \
		    {-object3d} {:objects:start_point} \
		    {-position} $pos

	    set pos [AddPoints $start_pos { 2.7 1.3 0.5 }]
	    objcreate {s_object3dinst} {:start_points:start_point-3} \
		    {-object3d} {:objects:start_point} \
		    {-position} $pos
	} else {
	    tk_messageBox -type ok -message "$gateobj does not exist" \
		    -parent .
	}
    }
}
