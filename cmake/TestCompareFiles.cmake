

execute_process(COMMAND ${TEST_APP} -f ${TEST_ARG1} -t UTF-8 ${TEST_COMPARE1} > ${TEST_COMPARE3}
                RESULT_VARIABLE HAD_ERROR
                )
if(HAD_ERROR)
    message(FATAL_ERROR "Test ${TEST_NAME} failed - ${HAD_ERROR}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files
    ${TEST_COMPARE1}
    ${TEST_COMPARE3}
    RESULT_VARIABLE DIFFERENT)
if(DIFFERENT)
    message(FATAL_ERROR "Test ${TEST_NAME} failed - files differ")
endif()

execute_process(COMMAND ${TEST_APP} -f UTF-8 -t ${TEST_ARG1} ${TEST_COMPARE2} > ${TEST_COMPARE3}
                RESULT_VARIABLE HAD_ERROR
                )
if(HAD_ERROR)
    message(FATAL_ERROR "Test ${TEST_NAME} failed - ${HAD_ERROR}")
endif()
