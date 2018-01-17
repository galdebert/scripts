cmake_minimum_required(VERSION 3.8)

if(belit_utils_included)
    return()
endif()
set(belit_utils_included 1)

# cmake note:
# there are 2 ways to set target-props:
# set_target_properties(target1 target2 ... PROPERTIES prop1 value1 prop2 value2 ...)
# set_property(TARGET target PROPERTY value1 value2 ...) <- better, simpler


#----------------------------- belit_print, belit_verbose, belit_error, belit_assert_strequal -----------------------------
function(belit_print msg)
    message(STATUS "${msg}")
endfunction()

function(belit_verbose msg)
    if(BELIT_VERBOSE)
        message(STATUS "${msg}")
    endif()
endfunction()

# commented because interesting but awkward
# belit_print_("your message")
# belit_print_("your message" BELIT_VERBOSE)
#function(belit_print_ msg)
#    if(ARGC EQUAL 1)
#        message(STATUS "${msg}")
#    else()
#        if("${${ARGV1}}")
#            message(STATUS "${msg}")
#        endif()
#    endif()
#endfunction()

function(belit_error msg)
    message(FATAL_ERROR "########## ${msg} ##########")
endfunction()

function(belit_assert cond msg)
    if(NOT "${cond}")
        belit_error("belit_assert: ${msg}")
    endif()
endfunction()

function(belit_assert_strequal a b)
    if(NOT "${a}" STREQUAL "${b}")
        belit_error("belit_assert_strequal: ${a} != ${b}")
    endif()
endfunction()


#----------------------------- belit_print_list -----------------------------
# usage belit_print_list("mylist" "${mylist}")
function(belit_print_list list_name lst)
    belit_print("${list_name}:")
    foreach(item ${lst})
        belit_print("  ${item}")
    endforeach()
    belit_print("")
endfunction()


#----------------------------- belit_get_abs_paths -----------------------------
function(belit_get_abs_paths out_abs_paths abs_dir rel_paths)
    set(abs_paths)
    foreach(rel_path ${rel_paths})
        list(APPEND abs_paths "${abs_dir}/${rel_path}")
    endforeach()
    set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
endfunction()


#----------------------------- belit_set_ide_sourcegroups -----------------------------
# belit_set_ide_sourcegroups("C:/root" "dir1/a.cpp;dir2/b.cpp" "group/subgroup")
# will create in visual studio:
# +-group
#   +-subgroup
#     +-dir1
#        +-a.cpp (C:/root/dir1/a.cpp)
#     +-dir2
#        +-b.cpp (C:/root/dir2/b.cpp)
function(belit_set_ide_sourcegroups abs_dir rel_paths root_sourcegroup)
    foreach(rel_path ${rel_paths})
        set(group "${rel_path}")                         # "a/b/file.cpp"
        if(NOT "${root_sourcegroup}" STREQUAL "")
            set(group "${root_sourcegroup}/${rel_path}") # "group/subgroup/a/b/file.cpp"
        endif()
        string(REPLACE "/" ";" tokens "${group}")        # "group;subgroup;a;b;file.cpp"
        list(REMOVE_AT tokens -1)                        # "group;subgroup;a;b"
        string(REPLACE ";" "\\" sourcegroup "${tokens}") # "group\\subgroup\\a\\b"
        # we create one source group per file, it's brute force but it works
        source_group("${sourcegroup}" FILES "${abs_dir}/${rel_path}")
    endforeach()
endfunction()


#----------------------------- belit_get_sources -----------------------------
# return all files recursively in abs_dir (and set a sourcegroup for each)
# ex: belit_get_sources(sources "${CMAKE_SOURCE_DIR}/src" "src")
function(belit_get_sources out_abs_paths abs_dir root_sourcegroup)
    file(GLOB_RECURSE rel_paths RELATIVE "${abs_dir}" "${abs_dir}/*")
    belit_set_ide_sourcegroups("${abs_dir}" "${rel_paths}" "${root_sourcegroup}")
    belit_get_abs_paths(abs_paths "${abs_dir}" "${rel_paths}")
    set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
endfunction()


#----------------------------- belit_set_binaries_paths -----------------------------
# belit_set_binaries_paths(use_boost "${CMAKE_SOURCE_DIR}/bin" "${CMAKE_SOURCE_DIR}/lib" "win64")
function(belit_set_binaries_paths target bin_root_dir lib_root_dir build_str)
    foreach(config ${CMAKE_CONFIGURATION_TYPES}) # is there a way to get the CONFIGS of a target ?
        string(TOUPPER "${config}" config_upper)
        string(TOLOWER "${config}" config_lower)

        set(bin_dir "${bin_root_dir}/${build_str}/${config_lower}")
        set(lib_dir "${lib_root_dir}/${build_str}/${config_lower}")

        # .dll
        set_property(TARGET "${target}" PROPERTY "RUNTIME_OUTPUT_DIRECTORY_${config_upper}" "${bin_dir}")
        set_property(TARGET "${target}" PROPERTY "RUNTIME_OUTPUT_NAME_${config_upper}" "${target}")

        # .lib
        set_property(TARGET "${target}" PROPERTY "ARCHIVE_OUTPUT_DIRECTORY_${config_upper}" "${lib_dir}")
        set_property(TARGET "${target}" PROPERTY "ARCHIVE_OUTPUT_NAME_${config_upper}" "${target}")

        # PDB corresponds to the /pdb linker option, creates a file in the bin dir
        set_property(TARGET "${target}" PROPERTY "PDB_OUTPUT_DIRECTORY_${config_upper}" "${bin_dir}")
        set_property(TARGET "${target}" PROPERTY "PDB_NAME_${config_upper}" "${target}")

        # COMPILE_PDB corresponds to the /Fd compiler option, creates a file in the lib dir
        set_property(TARGET "${target}" PROPERTY "COMPILE_PDB_OUTPUT_DIRECTORY_${config_upper}" "$lib_dir}")
        set_property(TARGET "${target}" PROPERTY "COMPILE_PDB_NAME_${config_upper}" "${target}")
    endforeach()
endfunction()


#----------------------------- belit_add_sources_dir -----------------------------
# add all files recursively in abs_dir (and set a sourcegroup for each) as sources to target
# ex: belit_add_sources_dir(target PUBLIC "${CMAKE_SOURCE_DIR}/src" "src")
function(belit_add_sources_dir target visibility abs_dir root_sourcegroup)
    belit_get_sources(abs_paths "${abs_dir}" "${root_sourcegroup}")
    target_sources("${target}" "${visibility}" ${abs_paths})
endfunction()


#----------------------------- belit_set_ide_folder -----------------------------
# in ide (visual studio), put the project inside a folder
function(belit_set_ide_folder target folder)
    set_property(TARGET "${target}" PROPERTY FOLDER "${folder}")
endfunction()
