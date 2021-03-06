PROJECT := __PROJECT__

###############################################################################
###############################################################################
## make: library
## make all: library + test
###############################################################################
###############################################################################

## DIRECTORIES
SRC_DIR := src
BUILD_DIR := build
DIST_DIR := dist

## SOURCES
CXX_SRC := $(shell find $(SRC_DIR) -name "*.cpp")
HXX_SRC := $(shell find $(SRC_DIR) -name "*.h")

## OBJECTS
CXX_OBJS := $(addprefix $(BUILD_DIR)/, $(patsubst $(SRC_DIR)/%,%,$(patsubst %.cpp,%.o,$(CXX_SRC))))
CXX_DEPS := $(CXX_OBJS:.o=.d)

###############################################################################
## DIST

## LIBRARIES OUTPUT
LIB_DIST_DIR := $(DIST_DIR)/lib
LIB_SHARED := $(LIB_DIST_DIR)/lib$(PROJECT).so
LIB_STATIC := $(LIB_DIST_DIR)/lib$(PROJECT).a

## HEADERS OUTPUT
HEADERS_API := $(shell find $(SRC_DIR) -name '*.h' -not -path "$(SRC_DIR)/internal/*")
HEADERS_DIST_DIR := $(DIST_DIR)/include/$(PROJECT)
HEADERS_DIST := $(addprefix $(HEADERS_DIST_DIR)/, $(patsubst $(SRC_DIR)/%,%,$(HEADERS_API)))

###############################################################################
## COMPILER

DEFINES +=

## INCLUDES
INCLUDE_DIRS +=

## LIBRARIES
LIBRARIES +=
LIBRARY_DIRS +=

## COMPILER
CXXFLAGS += -fPIC -std=c++11

## COMPILER WARNINGS
CXXFLAGS := -pedantic -Wall -Wextra -c -fmessage-length=0

## COMPILER FLAGS (DEBUG/RELEASE)
ifeq ($(DEBUG), 1)
	DEFINES += DEBUG
	CXXFLAGS += -g3 -O0
else
	DEFINES += NDEBUG
	CXXFLAGS +=-O2
endif

ifeq ($(COVERAGE), 1)
	CXXFLAGS += -p -pg --coverage
	LDFLAGS += --coverage
endif

CXXFLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))
CXXFLAGS += $(foreach define,$(DEFINES),-D$(define))

LDFLAGS += $(foreach librarydir,$(LIBRARY_DIRS),-L$(librarydir))
LDFLAGS += $(foreach library,$(LIBRARIES),-l$(library))

###############################################################################
## TARGETS

default: dist

## autogenerated dependencies
-include $(CXX_DEPS)

## build single object
## compile and generate dependencies tree http://stackoverflow.com/a/2045668/786186
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c -o $@ $<
	$(CXX) $(CXXFLAGS) -MF$(@:%.o=%.d) -MG -MM -MP -MT$(@:%.o=%.d) -MT$@ $<

## build shared library
$(LIB_SHARED): $(CXX_OBJS)
	@mkdir -p $(LIB_DIST_DIR)
	$(CXX) -shared -o $@ $(CXX_OBJS) $(LDFLAGS)

## build static library
$(LIB_STATIC): $(CXX_OBJS)
	@mkdir -p $(LIB_DIST_DIR)
	ar rcs $@ $(CXX_OBJS)

libraries: $(LIB_STATIC) $(LIB_SHARED)

## copy headers to dist/include
$(HEADERS_DIST_DIR)/%.h: $(SRC_DIR)/%.h
	mkdir -p $(dir $@)
	cp $< $@

## build libraries executables and miscellaneus
dist: libraries $(HEADERS_DIST)

###############################################################################
## TESTS

TEST_DIR := test
TEST_SRC := $(shell find $(TEST_DIR) -name "*.cpp")
TEST_BUILD_DIR := $(BUILD_DIR)/test
TEST_OBJS := $(addprefix $(TEST_BUILD_DIR)/, $(patsubst $(TEST_DIR)/%,%,$(patsubst %.cpp,%.o,$(TEST_SRC))))
TEST_EXE := $(TEST_BUILD_DIR)/$(PROJECT)_test

## autogenerated dependencies
-include $(wildcard $(TEST_BUILD_DIR)/**/*.d)

$(TEST_BUILD_DIR)/%.o: $(TEST_DIR)/%.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -I$(DIST_DIR)/include -c -o $@ $<
	$(CXX) $(CXXFLAGS) -I$(DIST_DIR)/include -MF$(@:%.o=%.d) -MG -MM -MP -MT$(@:%.o=%.d) -MT$@ $<

$(TEST_EXE): dist $(TEST_OBJS)
	$(CXX) -o $@ $(CXX_OBJS) $(TEST_OBJS) -lgtest -lgtest_main -lpthread $(LDFLAGS)

test_gdb: $(TEST_EXE)
	@./test/scripts/all_gdb

test: $(TEST_EXE)
	@./test/scripts/all

memcheck: $(TEST_EXE)
	@./test/scripts/all_memcheck

coverage: test
	@lcov -b . --capture --directory . --output-file build/coverage.info
	@genhtml build/coverage.info --output-directory build/coverage
	@echo
	@sleep 1
	@echo "xdg-open file://$(shell realpath build/coverage/index.html)"

###############################################################################
## build libraries, tests and documentaion
all: libraries $(TEST_EXE)

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf $(DIST_DIR)
