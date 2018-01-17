cmake_minimum_required(VERSION 3.8)


#------------------------------- pm_exclude_target_from_build_config ----------------------------------------
# not used for now
function(pm_exclude_target_from_build_config target build_config)
    set_property(TARGET "${target}" PROPERTY "EXCLUDE_FROM_DEFAULT_BUILD_${build_config}" 1)
endfunction()


#----------------------------- pm_exe_platform_specific_sources -----------------------------
# not used for now
function(pm_platform_specific_sources out_sources)
    set(sources)

    if(pm_target_is_android)
        set(sources
            "${pm_ndk_root}/sources/android/native_app_glue/android_native_app_glue.c"
            "${pm_ndk_root}/sources/android/native_app_glue/android_native_app_glue.h")
            #"${platform_source_root_dir}/AndroidManifest.xml")
    endif()

    if(pm_platform_is_osx OR pm_platform_is_ios)
        set(sources MACOSX_BUNDLE)
    endif()

    set("${out_sources}" "${sources}" PARENT_SCOPE)
endfunction()



#----------------------------- pm_platform_specific_target_link_libraries -----------------------------
# not used for now
function(pm_platform_specific_target_link_libraries target link_dependency_type)
    if(pm_target_is_windows)
        target_link_libraries("${target}" "${link_dependency_type}" ws2_32 imm32 iphlpapi psapi winmm dbghelp)
    endif()

    if(pm_target_is_android)
        target_link_libraries("${target}" "${link_dependency_type}" c m dl log android EGL GLESv3 OpenSLES)
    endif()
endfunction()


#----------------------------- pm_exe_platform_specific_include_directories -----------------------------
# not used for now
function(pm_exe_platform_specific_target_link_libraries exe)
    if(pm_platform_is_android)
        target_include_directories("${exe}" PRIVATE "${pm_ndk_root}/sources/android/native_app_glue")
    endif()
endfunction()


#------------------------------- pm_static_lib_imported -------------------------------
# not used for now
# nothing to do here, this kinf od stuff needs to be inside a FindXXX.cmake script
function(pm_static_lib_imported lib include_dirs link_libs)
    add_library("${lib}" STATIC IMPORTED)

    set_system_properties("${lib}") # defined in CMakeMacros.cmake. Call some platform specific set_target_properties().

    # it's not clear how to pass a list for value1 in set_target_properties(target1 target2 ... PROPERTIES prop1 value1 prop2 value2 ...)
    # let's use set_property intead of set_target_properties
    # usage: set_property(TARGET [target1 [target2 ...]] [APPEND] [APPEND_STRING] PROPERTY <name> [value1 [value2 ...]])
    set_property(TARGET "${lib}" PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${include_dirs})

    set_property(TARGET "${lib}" PROPERTY IMPORTED_LOCATION_DEBUG "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG}/${LIB_PREFIX}${lib}${LIB_SUFFIX}")
    set_property(TARGET "${lib}" PROPERTY IMPORTED_LOCATION_DEV "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEV}/${LIB_PREFIX}${lib}${LIB_SUFFIX}")
    set_property(TARGET "${lib}" PROPERTY IMPORTED_LOCATION_RELEASE "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE}/${LIB_PREFIX}${lib}${LIB_SUFFIX}")

    set_property(TARGET "${lib}" PROPERTY INTERFACE_LINK_LIBRARIES ${link_libs})
endfunction()


#----------------------------- pm_setcpp11_flag -----------------------------
# on Android, set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11") does not work with .c files.
# android_native_app_glue.c is added automatically by cmake for executables.
# The workaround is to set "-std=c++11" for each file
# From cmake doc: Source file properties are visible only to targets added in the same directory (CMakeLists.txt).
# function(pm_setcpp11_flag abs_paths)
#     if(pm_platform_is_android)
#         foreach(abs_path ${abs_paths})
#             get_filename_component(extension "${abs_path}" EXT)
#             if("${extension}" STREQUAL ".cpp")
#                 set_source_files_properties("${abs_path}" PROPERTIES COMPILE_FLAGS "-std=c++11")
#             endif()
#         endforeach()
#     endif()
# endfunction()

#----------------------------- pm_glob_filter -----------------------------
# requires pm_source_extensions to be set
# function(pm_glob_filter out_filter dir)
#     set(filter)
#     foreach(extension ${pm_source_extensions})
#         list(APPEND filter "${dir}/*${extension}")
#     endforeach()
#     #belit_print("filter=${filter}")
#     set("${out_filter}" "${filter}" PARENT_SCOPE)
# endfunction()


# ------------------------------- get_abs_paths -------------------------------
# get_abs_paths(abs_paths "C:/dir1" "a.cpp;b.cpp") sets abs_paths="C:/dir1/a.cpp;C:/dir1/b.cpp"
# get_abs_paths(abs_paths "C:/dir1" "*.h;*.cpp")   sets abs_paths="C:/dir1/*.h;C:/dir1/*.cpp"
function(get_abs_paths out_abs_paths base_dir rel_paths)
    set(abs_paths)
    foreach(rel_path ${rel_paths})
        list(APPEND abs_paths "${base_dir}/${rel_path}")
    endforeach()
    set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
endfunction()

# ------------------------------- create_source_groups -------------------------------
# create_source_groups("C:/root" "dir1/a.cpp;dir2/b.cpp" "group/subgroup") will create in visual studio source explorer:
# +-group
#   +-subgroup
#     +- dir1
#        +- a.cpp (C:/root/dir1/c.cpp)
#     +- dir2
#        +- b.cpp (C:/root/dir2/e.cpp)
function(create_source_groups base_dir rel_paths base_group)
    foreach(rel_path ${rel_paths})
        set(group "${rel_path}")                         # "a/b/file.cpp"
        if(NOT "${base_group}" STREQUAL "")
            set(group "${base_group}/${rel_path}")       # "group/subgroup/a/b/file.cpp"
        endif()
        string(REPLACE "/" ";" tokens "${group}")        # "group;subgroup;a;b;file.cpp"
        list(REMOVE_AT tokens -1)                        # "group;subgroup;a;b"
        string(REPLACE ";" "\\" sourcegroup "${tokens}") # "group\\subgroup\\a\\b"
        if(NOT "${sourcegroup}" STREQUAL "")
            source_group("${sourcegroup}" FILES "${base_dir}/${rel_path}") # we create one source group per file, it's brute force but works
        endif()
        message(STATUS "source_group(${sourcegroup} FILES ${base_dir}/${rel_path})") # debug
    endforeach()
endfunction()

# ------------------------------- gather_sources_in_dir -------------------------------
# gather_sources_in_dir(abs_paths "C:/root" "group/subgroup") sets abs_paths to all .h and cpp in C:/root
#   and creates the corresponding source group in visual studio
function(gather_sources_in_dir out_abs_paths base_dir base_group)
    # glob *.h and *.cpp in base_dir recursively
    get_abs_paths(glob_filters "${base_dir}" "*.h;*.cpp")
    file(GLOB_RECURSE rel_paths RELATIVE "${base_dir}" ${glob_filters})
    
    create_source_groups("${base_dir}" "${rel_paths}" "${base_group}")
    get_abs_paths(abs_paths "${base_dir}" "${rel_paths}")
    set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
endfunction()

# ------------------------------- set_global_build_options -------------------------------
macro(set_global_build_options)
    if(MSVC)
        add_definitions("-DUNICODE" "-D_UNICODE") # http://utf8everywhere.org/
        add_compile_options(/W4) # Set warning level 4.
        add_compile_options(/WX) # Treat warnings as errors
    endif()
endmacro()

#----------------------------- pm_sources_flat -----------------------------
# GLOB in abs_dir using ${pm_source_extensions} and create source_groups
# commented because probably useless
# function(pm_sources_flat out_abs_paths abs_dir root_sourcegroup)
#     file(GLOB rel_paths RELATIVE "${abs_dir}" "${abs_dir}/*")
#     pm_set_sourcegroups("${abs_dir}" "${rel_paths}" "${root_sourcegroup}")
#     belit_get_abs_paths(abs_paths "${abs_dir}" "${rel_paths}")
#     set("${out_abs_paths}" "${abs_paths}" PARENT_SCOPE)
# endfunction()

#----------------------------- pm_sources_onefile -----------------------------
# commented because probably useless
# function(pm_sources_onefile out_abs_paths one_file_abspath sourcegroup)
#     string(REPLACE "/" "\\" sourcegroup "${sourcegroup}")
#     if(NOT "${sourcegroup}" STREQUAL "")
#         source_group("${sourcegroup}" FILES "${one_file_abspath}")
#     endif()
#     set("${out_abs_paths}" "${one_file_abspath}" PARENT_SCOPE)
# endfunction()


