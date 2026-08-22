# -*-tcl-*-
# Pallette display.

namespace eval TRPallette {

    proc Create { f } {
	frame $f

	set b(setup) [button $f.setup -text Setup \
		-command { \
		objnew s_sgnode : scene; \
		objnew s_container : objects; \
		objnew s_container : models; \
		objnew s_container : textures; \
	    } -width 16]
	pack $b(setup) -side top -fill x -expand true

	set b(object) [button $f.object -text Object \
		-command {objnew s_object3d :objects obj1} -width 16]
	pack $b(object) -side top -fill x -expand true
	
	set b(instance) [button $f.instance -text Instance \
		-command {objnew s_object3dinst :scene obj1inst} -width 16]
	pack $b(instance) -side top -fill x -expand true

	set b(model) [button $f.model -text Model \
		-command {objnew s_model :models model1} -width 16]
	pack $b(model) -side top -fill x -expand true

	set b(model) [button $f.texture -text Texture \
		-command {objnew s_texture :textures tex1} -width 16]
	pack $b(model) -side top -fill x -expand true

	set b(loadbitmap) [button $f.load -text "Load Object Bitmap" \
		-command [code ActivateLoader $f] -width 16]
	pack $b(loadbitmap) -side top -fill x -expand true

	set b(writefile) [button $f.write -text "Write Object File" \
		-command  [code ActivateWriter $f] -width 16]
	pack $b(writefile) -side top -fill x -expand true

	set b(flushobjects) [button $f.flush -text "Flush Objects" \
		-command {objcall :scene flush} -width 16]
	pack $b(flushobjects) -side top -fill x -expand true

	pack $f

	return $f
    }

    proc ActivateLoader {f} {
	global tux_data_dir

	set typelist {
	    {"PNG Image" {".png"}}
	    {"RGB Image" {".rgb"}}
	    {"All Files" {*}} }

	set result [tk_getOpenFile -initialdir $tux_data_dir/courses \
		-title "Select File" -initialfile trees.png \
		-filetypes $typelist -parent $f ]

	if { $result != "" } {
	    if [catch {objcall :palette create_instances $result } msg] {
		tk_messageBox -type ok -message $msg
	    }
	}
    }

    proc ActivateWriter {f} {
	global tux_data_dir

	set typelist {
	    {"Tcl File" {".tcl"}}
	    {"All Files" {*}} }

	set fname [tk_getSaveFile -initialdir $tux_data_dir/courses \
		-title "Save items.tcl File" -initialfile items.tcl \
		-filetypes $typelist -parent $f]

	if { $fname != "" } {
	    if [catch {open $fname w} fileId] {
		tk_messageBox -type ok -message "$fileId"
	    } else {
		puts $fileId [objserialize :scene]  
		close $fileId
	    }
	}
    }
    proc okWriteClick { f fname } {
    }


} ;# namespace TRPallette
