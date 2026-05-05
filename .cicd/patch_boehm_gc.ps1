<#
.SYNOPSIS
	Patch C files in Boehm GC package to work with Gobo Eiffel.

.DESCRIPTION
	Patch C files in Boehm GC package to work with Gobo Eiffel.

.EXAMPLE
	# Patch C files in Boehm GC package:
	patch_boehm_gc.ps1 <path_to_boehm_gc>

.NOTES
	Copyright: "Copyright (c) 2026 Eric Bezault and others"
	License: "MIT License"
#>

param
(
	[Parameter(Mandatory=$true)]
	[string] $BoehmGcPath
)

$ErrorActionPreference = "Stop"

$files_to_be_deleted = @(
	".git",
	".github",
	"build",
	"cord",
	"doc",
	"extra/Mac_files",
	"extra/symbian",
	"extra/AmigaOS.c",
	"extra/MacOS.c",
	"extra/msvc_dbg.c",
	"extra/pcr_interface.c",
	"extra/real_malloc.c",
	"extra/symbian.cpp",
	"m4",
	"tests",
	"tools",
	".appveyor.yml",
	".gitattributes",
	".gitignore",
	".travis.yml",
	"autogen.sh",
	"bdw-gc.pc.in",
	"ChangeLog",
	"CMakeLists.txt",
	"Config.cmake.in",
	"configure.ac",
	"digimars.mak",
	"gc_badalc.cc",
	"gc_badalc.cpp",
	"gc_cpp.cc",
	"gc_cpp.cpp",
	"ia64_save_regs_in_stack.s",
	"Makefile.am",
	"Makefile.direct",
	"NT_MAKEFILE",
	"OS2_MAKEFILE",
	"PCR-Makefile",
	"README.QUICK",
	"SMakefile.amiga",
	"sparc_mach_dep.S",
	"sparc_netbsd_mach_dep.s",
	"WCC_MAKEFILE"
)

foreach ($file in $files_to_be_deleted) {
	if (Test-Path -Path $BoehmGcPath/$file) {
		Remove-Item $BoehmGcPath/$file -Recurse -Force
	}
}
