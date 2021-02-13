
include ../Makefile.exe-rule
include ../Makefile.flags
override CPPFLAGS += -I ../include -iquote ../include/winrt/yolort_impl

apis := $(wildcard ../winrt/Windows.*.h)
api_exes := $(apis:../winrt/%.h=%.exe)
all_exes := intrin.exe $(api_exes)

.PHONY: tests
tests: $(all_exes)
	for exe in $(all_exes); do ./$$exe || exit 1; done

$(api_exes): %.exe: ../include/winrt/%.h ../include/winrt/yolort_impl/winrt/%.h ../include/winrt/yolort_impl/yolo.ipp test.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) "-DHEADER=$(@:%.exe=<winrt/%.h>)" test.cpp -o $@ $(LDLIBS)

intrin.exe: ../include/winrt/yolort_impl/yolo.ipp

.PHONY: clean
clean:
	$(RM) $(all_exes)
