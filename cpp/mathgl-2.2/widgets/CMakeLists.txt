include(GenerateExportHeader)
add_compiler_export_flags()

if(MGL_HAVE_FLTK)
	include_directories(${FLTK_INCLUDE_DIR})
	add_library(mgl-fltk SHARED fltk.cpp ../include/mgl2/fltk.h)
	add_library(mgl-fltk-static STATIC fltk.cpp ../include/mgl2/fltk.h)
	set_target_properties(mgl-fltk PROPERTIES SOVERSION ${MathGL_SOVERSION})
	set_target_properties(mgl-fltk PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-fltk PROPERTIES DEFINE_SYMBOL "mgl_EXPORTS")
	set_target_properties(mgl-fltk-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-fltk-static PROPERTIES COMPILE_FLAGS -DMGL_STATIC_DEFINE)
	target_link_libraries(mgl-fltk mgl)
	target_link_libraries(mgl-fltk ${FLTK_LIBRARIES})

	if(enable-mgl2)
		set_target_properties(mgl-fltk PROPERTIES OUTPUT_NAME "mgl2-fltk")
		set_target_properties(mgl-fltk-static PROPERTIES OUTPUT_NAME "mgl2-fltk")
	else(enable-mgl2)
		set_target_properties(mgl-fltk-static PROPERTIES OUTPUT_NAME "mgl-fltk")
	endif(enable-mgl2)

	install(
		TARGETS mgl-fltk mgl-fltk-static
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION ${MGL_LIB_INSTALL_DIR}
		LIBRARY DESTINATION ${MGL_LIB_INSTALL_DIR}
	)
endif(MGL_HAVE_FLTK)

if(MGL_HAVE_GLUT)
	include_directories(${GLUT_INCLUDE_DIR})
	add_library(mgl-glut SHARED glut.cpp ../include/mgl2/glut.h)
	add_library(mgl-glut-static STATIC glut.cpp ../include/mgl2/glut.h)
	set_target_properties(mgl-glut PROPERTIES SOVERSION ${MathGL_SOVERSION})
	set_target_properties(mgl-glut PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-glut PROPERTIES DEFINE_SYMBOL "mgl_EXPORTS")
	set_target_properties(mgl-glut-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-glut-static PROPERTIES COMPILE_FLAGS -DMGL_STATIC_DEFINE)
	target_link_libraries(mgl-glut mgl)
	target_link_libraries(mgl-glut ${GLUT_LIBRARIES} ${OPENGL_LIBRARIES})

	if(enable-mgl2)
		set_target_properties(mgl-glut PROPERTIES OUTPUT_NAME "mgl2-glut")
		set_target_properties(mgl-glut-static PROPERTIES OUTPUT_NAME "mgl2-glut")
	else(enable-mgl2)
		set_target_properties(mgl-glut-static PROPERTIES OUTPUT_NAME "mgl-glut")
	endif(enable-mgl2)

	install(
		TARGETS mgl-glut mgl-glut-static
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION ${MGL_LIB_INSTALL_DIR}
		LIBRARY DESTINATION ${MGL_LIB_INSTALL_DIR}
	)
endif(MGL_HAVE_GLUT)

if(MGL_HAVE_WX)
	include(${wxWidgets_USE_FILE})
	add_library(mgl-wx SHARED wx.cpp ../include/mgl2/wx.h)
	add_library(mgl-wx-static STATIC wx.cpp ../include/mgl2/wx.h)
	set_target_properties(mgl-wx PROPERTIES SOVERSION ${MathGL_SOVERSION})
	set_target_properties(mgl-wx PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-wx PROPERTIES DEFINE_SYMBOL "mgl_EXPORTS")
	set_target_properties(mgl-wx-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-wx-static PROPERTIES COMPILE_FLAGS -DMGL_STATIC_DEFINE)
	target_link_libraries(mgl-wx mgl)
	target_link_libraries(mgl-wx ${wxWidgets_LIBRARIES})

	if(enable-mgl2)
		set_target_properties(mgl-wx PROPERTIES OUTPUT_NAME "mgl2-wx")
		set_target_properties(mgl-wx-static PROPERTIES OUTPUT_NAME "mgl2-wx")
	else(enable-mgl2)
		set_target_properties(mgl-wx-static PROPERTIES OUTPUT_NAME "mgl-wx")
	endif(enable-mgl2)

	install(
		TARGETS mgl-wx mgl-wx-static
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION ${MGL_LIB_INSTALL_DIR}
		LIBRARY DESTINATION ${MGL_LIB_INSTALL_DIR}
	)
endif(MGL_HAVE_WX)

if(MGL_HAVE_QT)
	include(${QT_USE_FILE})
	qt4_wrap_cpp(MGL_MOC_FILES ../include/mgl2/qmathgl.h)
	add_library(mgl-qt SHARED qt.cpp ${MGL_MOC_FILES} ../include/mgl2/qt.h ../include/mgl2/qmathgl.h)
	add_library(mgl-qt-static STATIC qt.cpp ${MGL_MOC_FILES} ../include/mgl2/qt.h ../include/mgl2/qmathgl.h)
	set_target_properties(mgl-qt PROPERTIES SOVERSION ${MathGL_SOVERSION})
	set_target_properties(mgl-qt PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-qt PROPERTIES DEFINE_SYMBOL "mgl_EXPORTS")
	set_target_properties(mgl-qt-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-qt-static PROPERTIES COMPILE_FLAGS -DMGL_STATIC_DEFINE)
	target_link_libraries(mgl-qt mgl)
	target_link_libraries(mgl-qt ${QT_LIBRARIES})

	if(enable-mgl2)
		set_target_properties(mgl-qt PROPERTIES OUTPUT_NAME "mgl2-qt")
		set_target_properties(mgl-qt-static PROPERTIES OUTPUT_NAME "mgl2-qt")
	else(enable-mgl2)
		set_target_properties(mgl-qt-static PROPERTIES OUTPUT_NAME "mgl-qt")
	endif(enable-mgl2)

	install(
		TARGETS mgl-qt mgl-qt-static
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION ${MGL_LIB_INSTALL_DIR}
		LIBRARY DESTINATION ${MGL_LIB_INSTALL_DIR}
	)
endif(MGL_HAVE_QT)


if(MGL_HAVE_QT AND MGL_HAVE_FLTK)
	include_directories(${FLTK_INCLUDE_DIR})
	include(${QT_USE_FILE})

	set(MGL_WND_SRC qt.cpp ../include/mgl2/qt.h ../include/mgl2/qmathgl.h fltk.cpp ../include/mgl2/fltk.h)

	add_library(mgl-wnd SHARED ${MGL_WND_SRC} ${MGL_MOC_FILES})
	add_library(mgl-wnd-static STATIC ${MGL_WND_SRC} ${MGL_MOC_FILES})

	set_target_properties(mgl-wnd PROPERTIES SOVERSION ${MathGL_SOVERSION})
	set_target_properties(mgl-wnd PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-wnd PROPERTIES DEFINE_SYMBOL "mgl_EXPORTS")
	set_target_properties(mgl-wnd-static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	set_target_properties(mgl-wnd-static PROPERTIES COMPILE_FLAGS -DMGL_STATIC_DEFINE)

	if(enable-mgl2)
		set_target_properties(mgl-wnd PROPERTIES OUTPUT_NAME "mgl2-wnd")
		set_target_properties(mgl-wnd-static PROPERTIES OUTPUT_NAME "mgl2-wnd")
	else(enable-mgl2)
		set_target_properties(mgl-wnd-static PROPERTIES OUTPUT_NAME "mgl-wnd")
	endif(enable-mgl2)

	target_link_libraries(mgl-wnd mgl)
	target_link_libraries(mgl-wnd ${QT_LIBRARIES})
	target_link_libraries(mgl-wnd ${FLTK_LIBRARIES})

	install(
		TARGETS mgl-wnd mgl-wnd-static
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION ${MGL_LIB_INSTALL_DIR}
		LIBRARY DESTINATION ${MGL_LIB_INSTALL_DIR}
	)
endif(MGL_HAVE_QT AND MGL_HAVE_FLTK)
