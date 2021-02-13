
include ../Makefile.exe-rule
include ../Makefile.flags
override CPPFLAGS += -I ../include -iquote ../include/winrt/yolort_impl

apis := $(wildcard ../winrt/Windows.*.h)
api_exes := $(apis:../winrt/%.h=%.exe)
all_exes := intrin.exe $(api_exes)

bloatastic_apis := \
	$(wildcard ../winrt/Windows.ApplicationModel.Store.Preview*.h) \
	$(wildcard ../winrt/Windows.UI.Xaml*.h)
# bloatastic being roughly defined as "my 1-GB SBC catches fire compiling this"
bloatastic_exes := $(bloatastic_apis:../winrt/%.h=%.exe)

%.ok:
	for exe in $(filter %.exe, $?); do ./$$exe || exit 1; done
	touch $@

all.ok: nonbloated.ok $(bloatastic_exes)

nonbloated.ok: $(filter-out $(bloatastic_exes), $(all_exes))

$(api_exes): %.exe: ../include/winrt/%.h ../include/winrt/yolort_impl/winrt/%.h ../include/winrt/yolort_impl/yolo.ipp test.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) "-DHEADER=$(@:%.exe=<winrt/%.h>)" test.cpp -o $@ $(LDLIBS)

intrin.exe: ../include/winrt/yolort_impl/yolo.ipp

.PHONY: clean
clean:
	$(RM) all.ok nonbloated.ok $(all_exes)
