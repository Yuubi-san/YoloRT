
include ../Makefile.flags
override CXXFLAGS += -I ../include -iquote ../include/winrt/yolort_impl

apis := $(wildcard ../winrt/Windows.*.h)
exes := $(apis:../winrt/%.h=%.exe)

.PHONY: tests
tests: retaddr.exe $(exes)
	retaddr.exe
	for exe in $(exes); do ./$$exe || exit 1; done

$(exes): %.exe: ../include/winrt/%.h ../include/winrt/yolort_impl/winrt/%.h ../include/winrt/yolort_impl/yolo.ipp test.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) "-DHEADER=$(@:%.exe=<winrt/%.h>)" test.cpp -o $@ $(LDLIBS)

retaddr.exe: %.exe: %.cpp ../include/winrt/yolort_impl/yolo.ipp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) -fno-inline $< -o $@ $(LDLIBS)

.PHONY: clean
clean:
	$(RM) retaddr.exe $(exes)
