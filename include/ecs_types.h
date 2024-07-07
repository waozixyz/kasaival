// ecs_types.h
#ifndef ECS_TYPES_H
#define ECS_TYPES_H

#include <stdbool.h>
#include "config.h"

typedef enum {
    ENTITY_DOG,
    ENTITY_FROG,
    ENTITY_FOX,
    ENTITY_SAGUARO,
    ENTITY_KALI,
    ENTITY_OAK
} EntityName;

typedef struct Entity Entity;

#endif // ECS_TYPES_H
