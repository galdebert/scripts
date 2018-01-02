cmake_minimum_required(VERSION 3.8)

if(pm_utils_included)
    return()
endif()
set(pm_utils_included 1)


#----------------------------- pm_print, pm_print_verbose, pm_error, pm_assert -----------------------------
function(pm_print msg)
    message(STATUS "${msg}")
endfunction()

function(pm_print_verbose msg)
    if(PM_VERBOSE)
        message(STATUS "${msg}")
    endif()
endfunction()

function(pm_error msg)
    message(FATAL_ERROR "${msg}")
endfunction()

function(pm_assert_strequal a b)
    if(NOT "${a}" STREQUAL "${b}")
        pm_error(msg "${a} != ${b}")
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


#----------------------------- pm_absolute_paths -----------------------------
function(pm_absolute_paths out_list root_dir in_list)
    set(lst)
    foreach(item ${in_list})
        list(APPEND lst "${root_dir}/${item}")
    endforeach()
    set("${out_list}" "${lst}" PARENT_SCOPE)
endfunction()


#----------------------------- pm_groups -----------------------------
function(pm_groups abs_root rel_paths root_sourcegroup)
    foreach(rel_path ${rel_paths})
        string(REPLACE "/" ";" tokens "${rel_path}")
        list(REMOVE_AT tokens -1)
        if(NOT "${root_sourcegroup}" STREQUAL "")
            list(INSERT tokens 0 "${root_sourcegroup}")
        endif()
        string(REPLACE ";" "\\" sourcegroup "${tokens}")
        source_group("${sourcegroup}" FILES "${abs_root}/${rel_path}")
        #pm_print("source_group(${sourcegroup} FILES ${abs_root}/${rel_path})")
    endforeach()
endfunction()


#----------------------------- pm_setcpp11_per_file -----------------------------
# on Android, set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11") does not work with .c files.
# android_native_app_glue.c is added automatically by cmake for executables.
# The workaround is to set "-std=c++11" for each file
# From cmake doc: Source file properties are visible only to targets added in the same directory (CMakeLists.txt).
function(pm_setcpp11_per_file files)
    if(pm_platform_is_android)
        foreach(file ${files})
            get_filename_component(extension "${file}" EXT)
            if("${extension}" STREQUAL ".cpp")
                set_source_files_properties("${file}" PROPERTIES COMPILE_FLAGS "-std=c++11")
            endif()
        endforeach()
    endif()
endfunction()

#----------------------------- pm_glob_filter -----------------------------
# requires pm_source_extensions to be set
function(pm_glob_filter out_filter dir)
    set(filter)
    foreach(extension ${pm_source_extensions})
        list(APPEND filter "${dir}/*${extension}")
    endforeach()
    #pm_print("filter=${filter}")
    set("${out_filter}" "${filter}" PARENT_SCOPE)
endfunction()

#----------------------------- pm_sources -----------------------------
# GLOB RECURSE in root_dir using and create source_groups
function(pm_sources out_absolute_files root_dir root_sourcegroup)
    pm_glob_filter(filter "${root_dir}")
    file(GLOB_RECURSE relative_files RELATIVE "${root_dir}" ${filter})
    pm_groups("${root_dir}" "${relative_files}" "${root_sourcegroup}")
    pm_absolute_paths(absolute_files "${root_dir}" "${relative_files}")
    pm_setcpp11_per_file("${absolute_files}")
    set("${out_absolute_files}" "${absolute_files}" PARENT_SCOPE)
endfunction()

#----------------------------- pm_sources_flat -----------------------------
# GLOB in root_dir using ${pm_source_extensions} and create source_groups
function(pm_sources_flat out_absolute_files root_dir root_sourcegroup)
    pm_glob_filter(filter "${root_dir}")
    file(GLOB relative_files RELATIVE "${root_dir}" ${filter})
    pm_groups("${root_dir}" "${relative_files}" "${root_sourcegroup}")
    pm_absolute_paths(absolute_files "${root_dir}" "${relative_files}")
    pm_setcpp11_per_file("${absolute_files}")
    set("${out_absolute_files}" "${absolute_files}" PARENT_SCOPE)
endfunction()

#----------------------------- pm_sources_onefile -----------------------------
function(pm_sources_onefile out_absolute_files one_file_abspath root_sourcegroup)
    source_group("${root_sourcegroup}" FILES "${one_file_abspath}")
    pm_setcpp11_per_file("${one_file_abspath}")
    set("${out_absolute_files}" "${one_file_abspath}" PARENT_SCOPE)
endfunction()

