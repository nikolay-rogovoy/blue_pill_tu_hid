TARGET = blue-pill
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Пути
SRC_DIR = Src
BUILD_DIR = build
CMSIS_DIR = libs/STM32CubeF1/Drivers
FREE_RTOS_SRC = libs/FreeRTOS
TU_SRC = libs/tinyusb

# Пути к HAL
HAL_DIR = $(CMSIS_DIR)/STM32F1xx_HAL_Driver
HAL_INC = $(HAL_DIR)/Inc
HAL_SRC = $(HAL_DIR)/Src


# Пути к заголовочным файлам
INCLUDES = -I./Inc \
           -I$(CMSIS_DIR)/CMSIS/Include \
           -I$(CMSIS_DIR)/CMSIS/Device/ST/STM32F1xx/Include \
           -I$(HAL_DIR)/Inc \
           -I$(HAL_DIR)/Inc/Legacy \
           -I$(TU_SRC)/src \
           -I$(FREE_RTOS_SRC)/include \
           -I$(FREE_RTOS_SRC)/portable/GCC/ARM_CM3


# Файлы
SOURCES = $(wildcard $(SRC_DIR)/*.c) \
          $(wildcard $(SRC_DIR)/*/*.c) \
          $(wildcard $(SRC_DIR)/*/*/*.c)

# Файлы HAL (подключаем только нужные модули!)
HAL_SOURCES = $(HAL_SRC)/stm32f1xx_hal.c \
              $(HAL_SRC)/stm32f1xx_hal_cortex.c \
              $(HAL_SRC)/stm32f1xx_hal_rcc.c \
              $(HAL_SRC)/stm32f1xx_hal_rcc_ex.c \
              $(HAL_SRC)/stm32f1xx_hal_gpio.c \
              $(HAL_SRC)/stm32f1xx_hal_pwr.c \
              $(HAL_SRC)/stm32f1xx_hal_uart.c \
              $(HAL_SRC)/stm32f1xx_hal_usart.c \
              $(HAL_SRC)/stm32f1xx_hal_dma.c \
              $(HAL_SRC)/stm32f1xx_hal_tim.c \
              $(HAL_SRC)/stm32f1xx_hal_tim_ex.c \
              $(HAL_SRC)/stm32f1xx_hal_adc.c \
              $(HAL_SRC)/stm32f1xx_hal_adc_ex.c \
              $(HAL_SRC)/stm32f1xx_hal_adc.c \
              $(HAL_SRC)/stm32f1xx_hal_adc_ex.c

USB_SOURCES =   $(TU_SRC)/src/tusb.c \
                $(TU_SRC)/src/common/tusb_fifo.c \
                $(TU_SRC)/src/device/usbd.c \
                $(TU_SRC)/src/class/hid/hid_device.c \
                $(TU_SRC)/src/portable/st/stm32_fsdev/dcd_stm32_fsdev.c \
                $(TU_SRC)/src/portable/st/stm32_fsdev/fsdev_common.c

FREERTOS_SOURCES = $(FREE_RTOS_SRC)/tasks.c \
                   $(FREE_RTOS_SRC)/queue.c \
                   $(FREE_RTOS_SRC)/list.c \
                   $(FREE_RTOS_SRC)/timers.c \
                   $(FREE_RTOS_SRC)/event_groups.c \
                   $(FREE_RTOS_SRC)/portable/GCC/ARM_CM3/port.c \
                   $(FREE_RTOS_SRC)/portable/MemMang/heap_4.c

STARTUP_FILE = $(CMSIS_DIR)/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_stm32f103xb.s
LINKER_SCRIPT = $(CMSIS_DIR)/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/linker/STM32F103XB_FLASH.ld


# Объединяем всё вместе
ALL_SOURCES = $(SOURCES) $(HAL_SOURCES) $(USB_SOURCES) $(FREERTOS_SOURCES) $(STARTUP_FILE)

# Объектные файлы
# OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ALL_SOURCES:.c=.o)))
OBJECTS = $(addprefix $(BUILD_DIR)/, $(ALL_SOURCES:.c=.o))
OBJECTS := $(OBJECTS:.s=.o)

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Флаги компилятора
CFLAGS = -mcpu=cortex-m3 \
         -mthumb \
         -mfloat-abi=soft \
         -DSTM32F103xB \
         -DUSE_HAL_DRIVER \
         $(INCLUDES) \
         -g \
         -Os \
         -Wall \
         -ffunction-sections \
         -fdata-sections

LDFLAGS = -T$(LINKER_SCRIPT) \
          --specs=nosys.specs \
          --specs=nano.specs \
          -nostartfiles \
          -Wl,--gc-sections


# Сборка
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) | $(BUILD_DIR)
	$(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS)
	$(OBJCOPY) -O ihex $@ $(BUILD_DIR)/$(TARGET).hex
	$(OBJCOPY) -O binary $@ $(BUILD_DIR)/$(TARGET).bin
	$(SIZE) $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(HAL_SRC)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# 5. Конкретное правило для startup (чтобы найти его в глубине папок)
# $(BUILD_DIR)/startup_stm32f411xe.o: $(STARTUP_FILE) | $(BUILD_DIR)
# 	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: clean flash

clean:
	rm -rf $(BUILD_DIR)

flash: $(BUILD_DIR)/$(TARGET).bin
	openocd -f interface/stlink.cfg \
                -c "set CPUTAPID 0x2ba01477" \
	        -f target/stm32f1x.cfg \
	        -c "program $(BUILD_DIR)/$(TARGET).bin 0x08000000 verify reset exit"


flash-elf: $(BUILD_DIR)/$(TARGET).elf
	openocd -f interface/stlink.cfg \
                -c "set CPUTAPID 0x2ba01477" \
	        -f target/stm32f1x.cfg \
	        -c "program $< verify reset exit"
