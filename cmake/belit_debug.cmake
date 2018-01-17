cmake_minimum_required(VERSION 3.8)

if(belit_debug_included)
    return()
endif()
set(belit_debug_included 1)

function(belit_print_prop target prop)
    get_property(value TARGET "${target}" PROPERTY "${prop}")
    if(NOT "${value}" STREQUAL "")
        message(STATUS "${prop}=${value}")
    endif()
endfunction()

function(belit_print_prop_cfg target prop cfg)
    get_property(value TARGET "${target}" PROPERTY "${prop}_${cfg}")
    if(NOT "${value}" STREQUAL "")
        message(STATUS "${prop}_${cfg}=${value}")
    endif()
endfunction()

function(belit_verbose_imported_props target)
    if(BELIT_VERBOSE)
        get_property(imported_configs TARGET "${target}" PROPERTY IMPORTED_CONFIGURATIONS)
        foreach(cfg ${imported_configs})
            belit_print_prop_cfg("${target}" IMPORTED_LOCATION "${cfg}")
            belit_print_prop_cfg("${target}" IMPORTED_IMPLIB "${cfg}")
            belit_print_prop_cfg("${target}" IMPORTED_LINK_DEPENDENT_LIBRARIES "${cfg}")
            #belit_print_prop_cfg("${target}" IMPORTED_LINK_INTERFACE_LANGUAGES "${cfg}") commented because always CXX in our case
            belit_print_prop_cfg("${target}" IMPORTED_LINK_INTERFACE_LIBRARIES "${cfg}")
            belit_print_prop_cfg("${target}" IMPORTED_LINK_INTERFACE_MULTIPLICITY "${cfg}")
            belit_print_prop_cfg("${target}" IMPORTED_NO_SONAME "${cfg}")
            belit_print_prop_cfg("${target}" IMPORTED_OBJECTS "${cfg}")
            belit_print_prop_cfg("${target}" IMPORTED_SONAME "${cfg}")
        endforeach()
    endif()
endfunction()

function(belit_verbose_interface_props target)
    if(BELIT_VERBOSE)
        belit_print_prop("${target}" INTERFACE_AUTOUIC_OPTIONS)
        belit_print_prop("${target}" INTERFACE_COMPILE_DEFINITIONS)
        belit_print_prop("${target}" INTERFACE_COMPILE_FEATURES)
        belit_print_prop("${target}" INTERFACE_COMPILE_OPTIONS)
        belit_print_prop("${target}" INTERFACE_INCLUDE_DIRECTORIES)
        belit_print_prop("${target}" INTERFACE_LINK_LIBRARIES)
        belit_print_prop("${target}" INTERFACE_POSITION_INDEPENDENT_CODE)
        belit_print_prop("${target}" INTERFACE_SOURCES)
        belit_print_prop("${target}" INTERFACE_SYSTEM_INCLUDE_DIRECTORIES)
    endif()
endfunction()

function(belit_verbose_props target)
    if(BELIT_VERBOSE)
        message(STATUS "------------------- ${target} properties -------------------")
        belit_verbose_imported_props("${target}")
        belit_verbose_interface_props("${target}")
        message(STATUS "")
    endif()
endfunction()
