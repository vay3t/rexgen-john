# This file contains functions and configurations for generating PC-Lint build
# targets for your CMake projects.

set(CPPCHECK_EXECUTABLE "cppcheck")

add_custom_target(ALL_CPPCHECK)

function(add_cppcheck target)
    get_directory_property(cppcheck_include_directories INCLUDE_DIRECTORIES)
    get_directory_property(cppcheck_defines COMPILE_DEFINITIONS)

    # let's get those elephants across the alps
    # prepend each include directory with "-i"; also quotes the directory
    set(cppcheck_include_directories_transformed)
    foreach(include_dir ${lint_include_directories})
        list(APPEND cppcheck_include_directories_transformed -i"${include_dir}")
    endforeach(include_dir)

    # prepend each definition with "-d"
    set(cppcheck_defines_transformed)
    foreach(definition ${cppcheck_defines})
        list(APPEND cppcheck_defines_transformed -d${definition})
    endforeach(definition)
        
    # list of all commands, one for each given source file
    set(cppcheck_files)

    foreach(sourcefile ${ARGN})
        # only include c and cpp files
        if( sourcefile MATCHES \\.c$|\\.cxx$|\\.cpp$ )
            # make filename absolute
            get_filename_component(sourcefile_abs ${sourcefile} ABSOLUTE)
            # create command line for linting one source file and add it to the list of commands
            list(APPEND cppcheck_files ${sourcefile_abs})
                #COMMAND ${CPPCHECK_EXECUTABLE}
                #"--enable=all"
                #${cppcheck_include_directories_transformed}
                #${cppcheck_defines_transformed}
                #${sourcefile_abs})
        endif()
    endforeach(sourcefile)

    set(cppcheck_slist "")
    foreach(file ${CPPCHECK_SUPPRESS})
      get_filename_component(file_abs ${file} ABSOLUTE)
      set(cppcheck_slist "${cppcheck_slist} --suppressions-list=${file_abs}")
    endforeach(file)

    set(cppcheck_command COMMAND
      ${CPPCHECK_EXECUTABLE}
      "--enable=all"
      "${cppcheck_slist}"
      ${cppcheck_files})

    # add a custom target consisting of all the commands generated above
    add_custom_target(${target}_CPPCHECK ${cppcheck_command} VERBATIM)
    # make the ALL_LINT target depend on each and every *_LINT target
    add_dependencies(ALL_CPPCHECK ${target}_CPPCHECK)

endfunction(add_cppcheck)
