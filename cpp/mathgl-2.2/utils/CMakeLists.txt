
add_executable(mglconv mglconv.cpp)
target_link_libraries(mglconv mgl)
install(
	TARGETS mglconv
	RUNTIME DESTINATION bin
)

add_executable(mgl.cgi mglcgi.cpp)
target_link_libraries(mgl.cgi mgl)
install(
	TARGETS mgl.cgi
# should be /usr/lib/cgi-bin/
	RUNTIME DESTINATION ${MGL_CGI_PATH}
)

if(MGL_HAVE_QT)
	include(${QT_USE_FILE})
	add_executable(mglview mglview.cpp)
	target_link_libraries(mglview mgl-qt)
	install(
		TARGETS mglview
		RUNTIME DESTINATION bin
	)
endif(MGL_HAVE_QT)
