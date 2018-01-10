cmake_minimum_required(VERSION 3.8)

if(pm_utils_included)
    return()
endif()
set(pm_utils_included 1)


#----------------------------- pm_print, pm_print_verbose, pm_error, pm_assert_strequal -----------------------------
function(pm_print msg)
    message(STATUS "${msg}")
endfunction()

function(pm_print_verbose msg)
    if(PM_VERBOSE)
        message(STATUS "${msg}")
    endif()
endfunction()

function(pm_error msg)
    message(FATAL_ERROR "########## ${msg} ##########")
endfunction()

function(pm_assert cond msg)
    if(NOT "${cond}")
        pm_error("pm_assert: ${msg}")
    endif()
endfunction()

function(pm_assert_strequal a b)
    if(NOT "${a}" STREQUAL "${b}")
        pm_error("pm_assert_strequal: ${a} != ${b}")
    endif()
endfunction()


#----------------------------- pm_print_list -----------------------------
# usage pm_print_list("mylist" "${mylist}")
function(pm_print_list list_name lst)
    pm_print("${list_name}:")
    foreach(item ${lst})
        pm_print("  ${item}")
    endforeach()
    pm_print("")
endfunction()


#----------------------------- pm_get_abs_paths -----------------------------
function(pm_get_abs_paths out_abs_paths abs_dir rel_paths)
    set(abs_paths)
    foreach(rel_path ${rel_paths})
        list(APPEND abs_paths "${abs_dir}/${rel_path}")
    endforeach()
    set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
endfunction()


#----------------------------- pm_set_ide_sourcegroups -----------------------------
# pm_set_sourcegroups("C:/root" "dir1/a.cpp;dir2/b.cpp" "group/subgroup") will create in visual studio source explorer:
# +-group
#   +-subgroup
#     +-dir1
#        +-a.cpp (C:/root/dir1/a.cpp)
#     +-dir2
#        +-b.cpp (C:/root/dir2/b.cpp)
function(pm_set_ide_sourcegroups abs_dir rel_paths root_sourcegroup)
    foreach(rel_path ${rel_paths})
        set(group "${rel_path}")                         # "a/b/file.cpp"
        if(NOT "${root_sourcegroup}" STREQUAL "")
            set(group "${root_sourcegroup}/${rel_path}")       # "group/subgroup/a/b/file.cpp"
        endif()
        string(REPLACE "/" ";" tokens "${group}")        # "group;subgroup;a;b;file.cpp"
        list(REMOVE_AT tokens -1)                        # "group;subgroup;a;b"
        string(REPLACE ";" "\\" sourcegroup "${tokens}") # "group\\subgroup\\a\\b"
        if(NOT "${sourcegroup}" STREQUAL "")
            # we create one source group per file, it's brute force but it works
            source_group("${sourcegroup}" FILES "${abs_dir}/${rel_path}")
        endif()
    endforeach()
endfunction()


#----------------------------- pm_sources -----------------------------
# return all files in abs_dir (and set a sourcegroup for each)
function(pm_get_sources out_abs_paths abs_dir root_sourcegroup)
    file(GLOB_RECURSE rel_paths RELATIVE "${abs_dir}" "${abs_dir}/*")
    pm_set_ide_sourcegroups("${abs_dir}" "${rel_paths}" "${root_sourcegroup}")
    pm_get_abs_paths(abs_paths "${abs_dir}" "${rel_paths}")
    set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
endfunction()

