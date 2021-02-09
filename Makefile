
CPPWINRT_INPUT = local
PREFIX         = /usr/local

rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) \
	$(filter $(subst *,%,$2),$d))

originals            := $(call rwildcard,winrt/,*.h)
copied_or_patched    := $(originals:%=include/winrt/yolort_impl/%)
patches              := $(wildcard *.patch)
patched              := $(patsubst %.patch, include/winrt/yolort_impl/winrt/%, \
	$(patches))
apis                 := $(wildcard winrt/*.h)
wrappers             := $(apis:%=include/%)

.PHONY: default
default: copied_or_patched wrappers
.PHONY: copied_or_patched
copied_or_patched: $(copied_or_patched)
.PHONY: wrappers
wrappers: $(wrappers)

$(patched):           include/winrt/yolort_impl/winrt/%: %.patch
$(copied_or_patched): include/winrt/yolort_impl/%: %
	mkdir --parents `echo "$@" | egrep --only-matching "^([^/]+/)+"`
	@if test -f "$(<:winrt/%=%.patch)"; then \
		echo patch "$<" "$(<:winrt/%=%.patch)" -o "$@"; \
		patch "$<" "$(<:winrt/%=%.patch)" -o "$@"; \
	else \
		echo cp "$<" "$@"; \
		cp "$<" "$@"; \
	fi
	@echo "[regex-fu censored to protect the innocent]"
	@egrep --only-matching "^WINRT_IMPL_LINK\([^,]+" "winrt/base.h" | \
		sed --regexp-extended "s/^.+\((.+)$$/-es\/WINRT_IMPL_\1\/\1\//" | \
		xargs sed "$@" --in-place

$(wrappers): include/%: %
	@echo "echo \$$cxx_code_here > $@"
	@echo -e "\
#define HEADER_IMPL <$(@:include/%=winrt/yolort_impl/%)>\n\
#include <winrt/yolort_impl/yolo.ipp>\n\
#undef HEADER_IMPL" > $@

.PHONY: clean
clean:
	$(RM) $(copied_or_patched) $(wrappers) *.html



.PHONY: originals
originals:
	PATH="bin:$$PATH" cppwinrt -verbose -overwrite -in "$(CPPWINRT_INPUT)" -out .

.PHONY: cleaner
cleaner: clean
	$(RM) -r winrt



bin/cppwinrt.exe: microsoft.windows.cppwinrt.x.x.x.x.nupkg bin
	unzip "$<" "$@"
	chmod +x "$@"

bin:
	mkdir bin

microsoft.windows.cppwinrt.x.x.x.x.nupkg:
	curl --location "https://www.nuget.org/api/v2/package/\
Microsoft.Windows.CppWinRT/$(CPPWINRT_VERSION)" > $@

.PHONY: pristine
pristine: cleaner
	$(RM) bin/cppwinrt.exe microsoft.windows.cppwinrt.x.x.x.x.nupkg
	rmdir --ignore-fail-on-non-empty bin



.PHONY: install
install:
	cp -r \
		include/winrt \
		include/WindowsNumerics.impl.h \
		"$PREFIX/include"



# development stuff

.PHONY: patches
patches: base.h-patch Windows.System.h-patch

.PHONY: %-patch
%-patch: winrt/%
	(diff --unified \
		--label="$<" "$<" \
		--label="include/winrt/yolort_impl/$<" "include/winrt/yolort_impl/$<"; \
		test $$? != 2) > $(@:-patch=.patch)


%.html: %.md
	markdown "$<" > "$@"
