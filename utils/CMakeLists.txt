
set(common_srcs
  parseargs.cc
)
set(common_libs
  poppler-katie
)

if (ENABLE_SPLASH)
  # pdftoppm
  set(pdftoppm_SOURCES ${common_srcs}
    pdftoppm.cc
  )
  add_executable(pdftoppm ${pdftoppm_SOURCES})
  target_link_libraries(pdftoppm ${common_libs})
  install(TARGETS pdftoppm DESTINATION bin)
  install(FILES pdftoppm.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)
endif ()

# pdfdetach
set(pdfdetach_SOURCES ${common_srcs}
  pdfdetach.cc
)
add_executable(pdfdetach ${pdfdetach_SOURCES})
target_link_libraries(pdfdetach ${common_libs})
install(TARGETS pdfdetach DESTINATION bin)
install(FILES pdfdetach.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdffonts
set(pdffonts_SOURCES ${common_srcs}
  pdffonts.cc
)
add_executable(pdffonts ${pdffonts_SOURCES})
target_link_libraries(pdffonts ${common_libs})
install(TARGETS pdffonts DESTINATION bin)
install(FILES pdffonts.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdfimages
set(pdfimages_SOURCES ${common_srcs}
  pdfimages.cc
  ImageOutputDev.cc
  ImageOutputDev.h
  JSInfo.cc
  JSInfo.h
)
add_executable(pdfimages ${pdfimages_SOURCES})
target_link_libraries(pdfimages ${common_libs})
install(TARGETS pdfimages DESTINATION bin)
install(FILES pdfimages.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdfinfo
set(pdfinfo_SOURCES ${common_srcs}
  pdfinfo.cc printencodings.cc
  JSInfo.cc
  JSInfo.h
)
add_executable(pdfinfo ${pdfinfo_SOURCES})
target_link_libraries(pdfinfo ${common_libs})
install(TARGETS pdfinfo DESTINATION bin)
install(FILES pdfinfo.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

if (ENABLE_NSS3)
  # pdfsig
  set(pdfsig_SOURCES ${common_srcs}
    pdfsig.cc
  )
  add_executable(pdfsig ${pdfsig_SOURCES})
  target_link_libraries(pdfsig ${common_libs})
  install(TARGETS pdfsig DESTINATION bin)
endif ()

# pdftops
set(pdftops_SOURCES ${common_srcs}
  pdftops.cc
)
add_executable(pdftops ${pdftops_SOURCES})
target_link_libraries(pdftops ${common_libs})
install(TARGETS pdftops DESTINATION bin)
install(FILES pdftops.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdftotext
set(pdftotext_SOURCES ${common_srcs}
  pdftotext.cc printencodings.cc
)
add_executable(pdftotext ${pdftotext_SOURCES})
target_link_libraries(pdftotext ${common_libs})
install(TARGETS pdftotext DESTINATION bin)
install(FILES pdftotext.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdftohtml
set(pdftohtml_SOURCES ${common_srcs}
  pdftohtml.cc
  HtmlFonts.cc
  HtmlLinks.cc
  HtmlOutputDev.cc
)
add_executable(pdftohtml ${pdftohtml_SOURCES})
target_link_libraries(pdftohtml ${common_libs})
install(TARGETS pdftohtml DESTINATION bin)
install(FILES pdftohtml.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdfseparate
set(pdfseparate_SOURCES ${common_srcs}
  pdfseparate.cc
)
add_executable(pdfseparate ${pdfseparate_SOURCES})
target_link_libraries(pdfseparate ${common_libs})
install(TARGETS pdfseparate DESTINATION bin)
install(FILES pdfseparate.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)

# pdfunite
set(pdfunite_SOURCES ${common_srcs}
  pdfunite.cc
)
add_executable(pdfunite ${pdfunite_SOURCES})
target_link_libraries(pdfunite ${common_libs})
install(TARGETS pdfunite DESTINATION bin)
install(FILES pdfunite.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)
