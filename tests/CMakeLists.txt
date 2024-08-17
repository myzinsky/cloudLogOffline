find_package(Qt6 REQUIRED COMPONENTS Test)

include_directories(BEFORE "${PROJECT_SOURCE_DIR}/src")

add_test(NAME maidenhead COMMAND maidenhead_t)
add_executable(maidenhead_t maidenhead_t.cpp)
target_link_libraries(maidenhead_t PRIVATE Qt::Test LibCloudLogOffline)
