GIT_SHA   = $(shell git rev-parse --short HEAD)
BUILD_TS  = $(shell date +%Y-%m-%dT%H:%M:%S)
BINARY    = els

SRCS      = $(wildcard src/*.c) $(wildcard src/tft/*.c) $(wildcard src/tft/drivers/*.c) $(wildcard src/tft/fonts/*.c)
SRCS     += $(wildcard src/bitmaps/*.c)
OBJS      = $(addprefix obj/, $(SRCS:.c=.o))
VERBOSE  ?= 0

STLINK   ?= 0

STM32F446 = 1

#CFLAGS   += -DELS_DEBUG=1

CFLAGS   += -DGIT_SHA=\"$(GIT_SHA)\" -DBUILD_TS=\"$(BUILD_TS)\"
CFLAGS   += -Isrc -DVERBOSE=$(VERBOSE)
CFLAGS   += -std=gnu99 -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS   += -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Os
#CFLAGS   += -ffast-math
#CFLAGS   += -frounding-math -fsignaling-nans -ffloat-store -ffp-contract=off

LDFLAGS  += -u _printf_float -lnosys --specs=nano.specs
LDFLAGS  += -Wl,--gc-sections,--sort-section=alignment
LDLIBS   += -lm
V       ?= 1

STM32F4xx  = 1
CFLAGS    += -DSTM32F446 -DSTM32F4xx
LDSCRIPT   = linker/stm32f446re.ld

include Makefile.include

.DEFAULT_GOAL := default

default: $(BINARY).hex size

ifeq ($(STLINK), 1)
flash: $(BINARY).hex
	st-flash --freq=4m --format=ihex write $(BINARY).hex
else
flash: $(BINARY).hex
	JLinkExe -if swd -device stm32f446re -speed 4000 jlink/flash.cmd
endif

ifneq ($(STLINK), 1)
reset:
	JLinkExe -if swd -device stm32f446re -speed 4000 jlink/reset.cmd
endif

size: $(BINARY).elf
	$(SIZE) $<

.PHONY: flash size default
