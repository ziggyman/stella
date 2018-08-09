if(MGL_HAVE_QT)

set(json_src Backend.cpp MainWindow.cpp)
set(json_moc_hdr Backend.hpp MainWindow.hpp)

include(${QT_USE_FILE})
include_directories(${MathGL_BINARY_DIR}/json)

qt4_wrap_ui(json_ui_src MainWindow.ui)
qt4_wrap_cpp(json_moc_src ${json_moc_hdr} )
add_executable(MglForJsTestBench ${json_src} ${json_moc_src} ${json_ui_src})
target_link_libraries(MglForJsTestBench mgl-qt ${QT_LIBRARIES})

endif(MGL_HAVE_QT)
