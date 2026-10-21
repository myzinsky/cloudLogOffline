find_package(Qt6 REQUIRED COMPONENTS Test Network)

include_directories(BEFORE "${PROJECT_SOURCE_DIR}/src")

add_test(NAME maidenhead COMMAND maidenhead_t)
add_executable(maidenhead_t maidenhead_t.cpp)
target_link_libraries(maidenhead_t PRIVATE Qt::Test LibCloudLogOffline)

add_test(NAME dxqso COMMAND dxqso_t)
add_executable(dxqso_t dxqso_t.cpp)
target_link_libraries(dxqso_t PRIVATE Qt::Test Qt::Network LibCloudLogOffline)
