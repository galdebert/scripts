cmake_minimum_required(VERSION 3.8)

if(pm_target_included)
    return()
endif()
set(pm_target_included 1)

include(pm_utils)

# 2 ways to set target-props:
# set_target_properties(target1 target2 ... PROPERTIES prop1 value1 prop2 value2 ...)
# set_property(TARGET target PROPERTY value1 value2 ...) <- better, simpler

function(pm_target_binaries target bin_root_dir lib_root_dir build_str)
    foreach(config ${CMAKE_CONFIGURATION_TYPES})
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

#----------------------------- pm_target_sources_dir -----------------------------
function(pm_target_sources_dir target visibity abs_dir root_sourcegroup)
    pm_get_sources(abs_paths "${abs_dir}" "${root_sourcegroup}")
    target_sources("${target}" "${visibity}" ${abs_paths})
endfunction()

#----------------------------- pm_target_ide_folder -----------------------------
function(pm_target_ide_folder target folder)
    set_property(TARGET "${target}" PROPERTY FOLDER "${folder}")
endfunction()

