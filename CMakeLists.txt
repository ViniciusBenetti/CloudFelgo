cmake_minimum_required(VERSION 3.16)

project(CloudBuildsDemoFelgo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Felgo REQUIRED)

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
set(PRODUCT_IDENTIFIER "com.vinix.runApp")
set(PRODUCT_VERSION_NAME "1.0.0")
set(PRODUCT_VERSION_CODE 1)

# Set either "test" or "publish" stage:
set(PRODUCT_STAGE "test")


set(PRODUCT_LICENSE_KEY "BCD4F68FF1BFFA295C310DD188F313822ECB8968F4CB5D99BAD551EE8E3CFBE53ED8BCD2C46EA49B0670830641EC41E919C3CA9230D819A0756597DF9922ECFD4BBF3663139C177590F41F13A23C5D58C7F1557F0B4DC0368D3723DBCD0B553A297ECDC49D37E95202A358B48FE3AF4D1BFAE1EBA32CDA565A61EE02C7AC56144A593F64CC230FC461DE2126E67A3156C05393766ABAB0BC5DA1B67DA3A591BD6A8D350BFDBED0FA2207F073F3F05A1C5517E3BDA8B4134D0E4950CFA7DAC447DECF2E0CF5301D15927A625A1A6DFDB381AD5F7F1B3E509D8E0B7E48A3058B65DC6195CB64572A94B74C3A8943F1D682D5E256294E50A50E734C40793C312D999B87320E41C6070501E69CF3573A7215704AE231E2DBE2E1E2A6EEBC654217984685ABB436342D872EC77D746994194E")

set(FELGO_PLUGINS
)

# Find all QML/JS files for the QML compiler:
file(GLOB_RECURSE QmlFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.qml qml/*.js)

# Find all non-QML/JS files in the qml and assets folder to add as resources:
file(GLOB_RECURSE AssetsFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} assets/* qml/*)
list(REMOVE_ITEM AssetsFiles ${QmlFiles})

qt_add_executable(appCloudBuildsDemoFelgo
    main.cpp
    ${QmlFiles}
    ${AssetsFiles}
)

felgo_configure_executable(appCloudBuildsDemoFelgo)

# Deploy resources to build folder/package directly
# comment for publishing
deploy_resources("${QmlFiles};${AssetsFiles}")

# Add QML files and resources to QML module to included them via QRC automatically:
qt_add_qml_module(appCloudBuildsDemoFelgo
    URI CloudBuildsDemoFelgo
    VERSION 1.0
# uncomment for publishing:
    QML_FILES ${QmlFiles}
    RESOURCES ${AssetsFiles}
    NO_RESOURCE_TARGET_PATH
)

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the deploy_resources line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the QML_FILES and RESOURCES above; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the Felgo Documentation

# during development, use the deploy_resources because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted

target_compile_definitions(appCloudBuildsDemoFelgo
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(appCloudBuildsDemoFelgo PRIVATE Felgo)

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
#find_package(FelgoLive REQUIRED)
#target_link_libraries(appCloudBuildsDemoFelgo PRIVATE FelgoLive)
