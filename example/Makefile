
include ../Makefile.flags
override CPPFLAGS += -I ../include -iquote ../include/winrt/yolort_impl
override LDLIBS   := -lole32 -loleaut32

srcs := $(wildcard *.cpp)
exes := $(srcs:.cpp=.exe)

.PHONY: examples
examples: $(exes)

$(exes): %.exe: %

naughtyfication.exe: ../include/winrt/Windows.Data.Xml.Dom.h ../include/winrt/Windows.UI.Notifications.h

.PHONY: clean
clean:
	$(RM) $(exes)
