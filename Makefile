CC      := clang
CFLAGS  := -Wall -Wextra -std=c11 -I.
FFLAGS  := -framework ApplicationServices
TARGET  := neowarpd
SRCS    := main.c utils/debug.c utils/screen.c utils/move.c utils/keycode_map.c
OBJS    := $(SRCS:.c=.o)

.PHONY: all debug clean

all: CFLAGS += -O2
all: $(TARGET)

debug: CFLAGS += -g -DDEBUG
debug: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(FFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
