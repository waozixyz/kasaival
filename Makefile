CC = clang
CFLAGS = -std=c99 -Wall -Wextra -I$(RAYLIB_PATH)/include -Iinclude
LDFLAGS = -L$(RAYLIB_PATH)/lib -lraylib -lm

RAYLIB_PATH = $(shell pkg-config --variable=prefix raylib)

SRCS = $(wildcard src/*.c)
OBJS = $(SRCS:.c=.o)
TARGET = Kasaival

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
	