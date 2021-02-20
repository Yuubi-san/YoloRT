
CPPWINRT_INPUT = local
PREFIX         = /usr/local

rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) \
	$(filter $(subst *,%,$2),$d))

originals            := $(call rwildcard,winrt/,*.h)
results              := $(originals:%=include/winrt/yolort_impl/%)
patches              := $(wildcard *.patch)
patched_intermediates := $(patches:%.patch=patched/%)
patched_results      := $(patsubst %.patch, include/winrt/yolort_impl/winrt/%, \
	$(patches))
apis                 := $(wildcard winrt/*.h)
wrappers             := $(apis:%=include/%)

.PHONY: default
default: results wrappers
.PHONY: results
results: $(results)
.PHONY: wrappers
wrappers: $(wrappers)

$(patched_results):   include/winrt/yolort_impl/winrt/%: patched/%
$(results):           include/winrt/yolort_impl/%: %
	mkdir --parents `echo "$@" | egrep --only-matching "^([^/]+/)+"`
	@if test -f "$(<:winrt/%=patched/%)"; then \
		echo cp "$(<:winrt/%=patched/%)" "$@"; \
		cp "$(<:winrt/%=patched/%)" "$@"; \
	else \
		echo cp "$<" "$@"; \
		cp "$<" "$@"; \
	fi
	@echo "[regex-fu censored to protect the innocent]"
	@egrep --only-matching "^WINRT_IMPL_LINK\([^,]+" "winrt/base.h" | \
		sed --regexp-extended "s/^.+\((.+)$$/-es\/WINRT_IMPL_\1\/\1\//" | \
		xargs sed "$@" --in-place

.PHONY: patched_intermediates
patched_intermediates: $(patched_intermediates)
$(patched_intermediates): patched/%: winrt/% %.patch
	@mkdir --parents `echo "$@" | egrep --only-matching "^([^/]+/)+"`
	patch "$<" "$(<:winrt/%=%.patch)" -o "$@"

$(wrappers): include/%: %
	@echo "echo \$$cxx_code_here > $@"
	@echo "#define HEADER_IMPL <$(@:include/%=winrt/yolort_impl/%)>" > "$@" && \
		echo "#include <winrt/yolort_impl/yolo.ipp>" >> "$@" && \
		echo "#undef HEADER_IMPL" >> "$@"

.PHONY: clean
clean:
	$(RM) $(results) $(patched_intermediates) $(wrappers) *.html
	rmdir --ignore-fail-on-non-empty patched



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
patches: $(patsubst patched/%, %-patch, $(wildcard patched/*))

.PHONY: %-patch
%-patch: winrt/%
	(diff --unified \
		--label="$<" "$<" \
		--label="patched/$(@:-patch=)" "patched/$(@:-patch=)"; \
		test $$? != 2) > $(@:-patch=.patch)


%.html: %.md
	markdown "$<" > "$@"
