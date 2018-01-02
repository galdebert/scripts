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


